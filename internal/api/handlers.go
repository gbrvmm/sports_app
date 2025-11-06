package api

import (
	"context"
	"database/sql"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type PlayerDTO struct {
	ID        int    `json:"id"`
	FullName  string `json:"full_name"`
	LastName  string `json:"last_name"`
	FirstName string `json:"first_name"`
	Patronym  string `json:"patronymic"`

	Hometown string `json:"hometown"`
	Team     string `json:"team"`
	Sport    string `json:"sport"`

	HeightCM int `json:"height_cm"`
	WeightKG int `json:"weight_kg"`
}

type PlayersResponse struct {
	Items []PlayerDTO `json:"items"`
	Meta  struct {
		Page   int `json:"page"`
		Limit  int `json:"limit"`
		Count  int `json:"count"`
	} `json:"meta"`
}

func atoiDefault(s string, def int) int {
	if s == "" {
		return def
	}
	n, err := strconv.Atoi(s)
	if err != nil {
		return def
	}
	return n
}

func RegisterRoutes(r *gin.Engine, db *sql.DB) {
	// /api/players?field=name|city|team&q=...&height_min=&height_max=&weight_min=&weight_max=&page=&limit=
	r.GET("/api/players", func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 4*time.Second)
		defer cancel()

		q := strings.TrimSpace(c.Query("q"))
		field := strings.ToLower(strings.TrimSpace(c.Query("field")))
		if field == "" {
			field = "name"
		}
		// разрешённые поля
		if field != "name" && field != "city" && field != "team" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "field must be one of: name, city, team"})
			return
		}

		hmin := atoiDefault(c.Query("height_min"), 0)
		hmax := atoiDefault(c.Query("height_max"), 0)
		wmin := atoiDefault(c.Query("weight_min"), 0)
		wmax := atoiDefault(c.Query("weight_max"), 0)

		page := atoiDefault(c.Query("page"), 1)
		limit := atoiDefault(c.Query("limit"), 20)
		if limit <= 0 || limit > 100 {
			limit = 20
		}
		offset := (page - 1) * limit
		if offset < 0 {
			offset = 0
		}

		// Базовый SELECT
		sb := strings.Builder{}
		sb.WriteString(`
SELECT p.id,
       (f.last_name || ' ' || f.first_name || ' ' || f.patronymic) AS full_name,
       f.last_name, f.first_name, f.patronymic,
       c.name AS hometown, COALESCE(t.name,'—') AS team, COALESCE(t.sport,'') as sport,
       p.height_cm, p.weight_kg
FROM players p
JOIN full_names f ON f.id = p.full_name_id
JOIN cities c ON c.id = p.hometown_id
LEFT JOIN teams t ON t.id = p.team_id
WHERE 1=1
`)

		args := []any{}
		// условия по полю
		if q != "" {
			switch field {
			case "name":
				args = append(args, "%"+strings.ToLower(q)+"%")
				sb.WriteString(" AND lower(f.last_name || ' ' || f.first_name || ' ' || f.patronymic) LIKE $" + strconv.Itoa(len(args)))
			case "city":
				args = append(args, "%"+strings.ToLower(q)+"%")
				sb.WriteString(" AND lower(c.name) LIKE $" + strconv.Itoa(len(args)))
			case "team":
				args = append(args, "%"+strings.ToLower(q)+"%")
				sb.WriteString(" AND lower(t.name) LIKE $" + strconv.Itoa(len(args)))
			}
		}
		// числовые фильтры
		if hmin > 0 {
			args = append(args, hmin)
			sb.WriteString(" AND p.height_cm >= $" + strconv.Itoa(len(args)))
		}
		if hmax > 0 {
			args = append(args, hmax)
			sb.WriteString(" AND p.height_cm <= $" + strconv.Itoa(len(args)))
		}
		if wmin > 0 {
			args = append(args, wmin)
			sb.WriteString(" AND p.weight_kg >= $" + strconv.Itoa(len(args)))
		}
		if wmax > 0 {
			args = append(args, wmax)
			sb.WriteString(" AND p.weight_kg <= $" + strconv.Itoa(len(args)))
		}

		sb.WriteString(" ORDER BY f.last_name, f.first_name, f.patronymic ")

		// Подсчёт общего количества
		countSQL := "SELECT count(*) FROM (" + sb.String() + ") AS sub"
		var total int
		if err := db.QueryRowContext(ctx, countSQL, args...).Scan(&total); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "count failed", "details": err.Error()})
			return
		}

		// Лимиты
		argsWithLimit := append([]any{}, args...)
		argsWithLimit = append(argsWithLimit, limit, offset)
		sb.WriteString(" LIMIT $" + strconv.Itoa(len(argsWithLimit)-1) + " OFFSET $" + strconv.Itoa(len(argsWithLimit)))

		rows, err := db.QueryContext(ctx, sb.String(), argsWithLimit...)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "query failed", "details": err.Error()})
			return
		}
		defer rows.Close()

		var out []PlayerDTO
		for rows.Next() {
			var p PlayerDTO
			if err := rows.Scan(
				&p.ID, &p.FullName, &p.LastName, &p.FirstName, &p.Patronym,
				&p.Hometown, &p.Team, &p.Sport, &p.HeightCM, &p.WeightKG,
			); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "scan failed", "details": err.Error()})
				return
			}
			out = append(out, p)
		}
		if err := rows.Err(); err != nil && !errors.Is(err, context.Canceled) {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "rows error", "details": err.Error()})
			return
		}

		var resp PlayersResponse
		resp.Items = out
		resp.Meta.Page = page
		resp.Meta.Limit = limit
		resp.Meta.Count = total

		c.JSON(http.StatusOK, resp)
	})

	// простая проверка здоровья
	r.GET("/healthz", func(c *gin.Context) {
		if err := db.PingContext(c.Request.Context()); err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"status": "bad", "error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})
}
