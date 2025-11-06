-- schema.sql

CREATE TABLE IF NOT EXISTS cities (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS full_names (
  id SERIAL PRIMARY KEY,
  last_name  TEXT NOT NULL,
  first_name TEXT NOT NULL,
  patronymic TEXT NOT NULL,
  UNIQUE (last_name, first_name, patronymic)
);

CREATE TABLE IF NOT EXISTS teams (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  home_city_id INT REFERENCES cities(id) ON DELETE RESTRICT,
  sport TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS players (
  id SERIAL PRIMARY KEY,
  full_name_id INT NOT NULL REFERENCES full_names(id) ON DELETE CASCADE,
  hometown_id  INT NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
  team_id      INT REFERENCES teams(id) ON DELETE SET NULL,
  height_cm INT NOT NULL CHECK (height_cm BETWEEN 150 AND 230),
  weight_kg INT NOT NULL CHECK (weight_kg BETWEEN 50 AND 150)
);

-- Индексы под поиск (регистронезависимо)
CREATE INDEX IF NOT EXISTS idx_full_names_full
  ON full_names ((lower(last_name || ' ' || first_name || ' ' || patronymic)));
CREATE INDEX IF NOT EXISTS idx_cities_name ON cities (lower(name));
CREATE INDEX IF NOT EXISTS idx_teams_name  ON teams  (lower(name));
