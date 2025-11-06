package main

import (
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/gbrvmm/sports-app/internal/api"
	"github.com/gbrvmm/sports-app/internal/db"
	"github.com/gin-gonic/gin"
)

func main() {
	d, err := db.Open()
	if err != nil {
		log.Fatalf("db open: %v", err)
	}
	defer d.Close()

	// gin router
	r := gin.Default()

	// CORS
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	// API
	api.RegisterRoutes(r, d)

	// Шаблоны (смена разделителей, чтобы не конфликтовать с JSX/{})
	tmpl := template.Must(template.New("").Delims("[[", "]]").ParseGlob("templates/*.tmpl.html"))
	r.SetHTMLTemplate(tmpl)

	// Рендер React-страницы
	r.GET("/", func(c *gin.Context) {
		apiBase := os.Getenv("API_BASE")
		if apiBase == "" {
			apiBase = "" // тот же хост
		}
		c.HTML(http.StatusOK, "index.tmpl.html", gin.H{
			"Title":   "Поиск игроков — SportsDB",
			"APIBase": apiBase,
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8082"
	}
	log.Printf("server listening on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
