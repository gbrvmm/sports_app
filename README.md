# ⚽ Поиск игроков спортивных команд

![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat&logo=go)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791?style=flat&logo=postgresql)
![React](https://img.shields.io/badge/React-18+-61DAFB?style=flat&logo=react)
![Gin](https://img.shields.io/badge/Gin-Framework-0099E1?style=flat&logo=go)
![Made with Love](https://img.shields.io/badge/Made%20with-❤️-red) 


![Демонстрация работы](demo.gif)


---

## 📋 Требования

| Компонент | Версия |
|-----------|--------|
| Go | 1.22+ |
| PostgreSQL | 14+ |
| Make | опционально |

---

## 🚀 Быстрый старт

### 1️⃣ Инициализация БД

По умолчанию БД: `postgres://myuser:mypassword@127.0.0.1:5432/sportsdb?sslmode=disable`

Переопределить через переменную окружения: `DATABASE_URL`

#### Через Make (рекомендуется)

```bash
make db-create    # создаст роль myuser, БД sportsdb
make migrate      # применит schema.sql
make seed         # загрузит demo.sql
```

Если суперпользователь защищён паролем:

```bash
PGSUPERPASS=secret make db-create
```

#### Ручной способ через psql

```sql
CREATE DATABASE sportsdb;
CREATE USER myuser WITH PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE sportsdb TO myuser;
\c sportsdb
ALTER SCHEMA public OWNER TO myuser;
```

### 2️⃣ Запуск сервера

```bash
make tidy
make run
```

Сервер поднимется на: **http://localhost:8080/**

### 3️⃣ Проверка API

```bash
# Поиск по ФИО
curl "http://localhost:8080/api/players?field=name&q=Иванов"

# Поиск по городу с фильтром роста
curl "http://localhost:8080/api/players?field=city&q=Москва&height_min=180"

# Поиск по команде с фильтром веса
curl "http://localhost:8080/api/players?field=team&q=Титаны&weight_max=85"
```

Откройте UI: **http://localhost:8080/**

---

## Структура проекта

```
sports-app/
├── go.mod                      # Go модули
├── Makefile                    # Команды автоматизации
├── README.md                   # Документация
├── schema.sql                  # Схема БД
├── demo.sql                    # Демо-данные
├── cmd/
│   └── server/
│       └── main.go             # Точка входа
├── internal/
│   ├── api/
│   │   └── handlers.go         # REST обработчики
│   └── db/
│       └── db.go               # Логика БД
└── templates/
    └── index.tmpl.html         # Go-шаблон с React
```

---

## Архитектура

### Бэкенд
- **Фреймворк**: Gin Web Framework
- **БД**: PostgreSQL с индексами для быстрого поиска
- **Шаблонизация**: Go `html/template`

### Фронтенд
- **Библиотека**: React (ES-модули через CDN `esm.sh`)
- **Сборка**: не требуется
- **Переменные**: `Title`, `APIBase` из Go-шаблона

### БД структура

| Таблица | Назначение |
|---------|-----------|
| `cities` | Города (индексированы) |
| `full_names` | ФИО (индексированы регистронезависимо) |
| `teams` | Команды (индексированы) |
| `players` | Игроки с ссылками на другие таблицы |

---

## Примеры использования

### Найти игроков из Санкт-Петербурга ростом более 185 см

```bash
curl "http://localhost:8080/api/players?field=city&q=Санкт-Петербург&height_min=185"
```

### Найти игроков команды "Спартак" весом до 80 кг

```bash
curl "http://localhost:8080/api/players?field=team&q=Спартак&weight_max=80"
```

### Найти игрока по ФИО

```bash
curl "http://localhost:8080/api/players?field=name&q=Петров&height_min=170&height_max=190"
```


