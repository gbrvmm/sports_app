-- demo.sql

-- Города
INSERT INTO cities (name) VALUES
('Москва'),('Санкт-Петербург'),('Новосибирск'),('Екатеринбург'),('Казань'),
('Нижний Новгород'),('Челябинск'),('Самара'),('Омск'),('Ростов-на-Дону'),
('Уфа'),('Красноярск'),('Пермь'),('Воронеж'),('Волгоград')
ON CONFLICT (name) DO NOTHING;

-- ФИО с уникальным ограничением
INSERT INTO full_names (last_name, first_name, patronymic) VALUES
('Иванов','Иван','Иванович'),
('Петров','Пётр','Сергеевич'),
('Сидоров','Алексей','Михайлович'),
('Кузнецов','Дмитрий','Андреевич'),
('Смирнов','Николай','Петрович'),
('Попов','Сергей','Владимирович'),
('Васильев','Михаил','Олегович'),
('Новиков','Артём','Евгеньевич'),
('Фёдоров','Кирилл','Игоревич'),
('Морозов','Андрей','Викторович'),
('Волков','Илья','Александрович'),
('Алексеев','Роман','Денисович'),
('Лебедев','Максим','Николаевич'),
('Семёнов','Павел','Романович'),
('Егоров','Данил','Павлович')
ON CONFLICT (last_name, first_name, patronymic) DO NOTHING;

-- Команды привязываем к городам по имени
INSERT INTO teams (name, home_city_id, sport) VALUES
('Титаны',            (SELECT id FROM cities WHERE name='Москва'),             'Футбол'),
('Орлы',              (SELECT id FROM cities WHERE name='Санкт-Петербург'),    'Баскетбол'),
('Молнии',            (SELECT id FROM cities WHERE name='Новосибирск'),        'Хоккей'),
('Северные Волки',    (SELECT id FROM cities WHERE name='Екатеринбург'),       'Футбол'),
('Шторм',             (SELECT id FROM cities WHERE name='Казань'),             'Баскетбол'),
('Ракеты',            (SELECT id FROM cities WHERE name='Нижний Новгород'),    'Хоккей'),
('Медведи',           (SELECT id FROM cities WHERE name='Челябинск'),          'Футбол'),
('Дельфины',          (SELECT id FROM cities WHERE name='Самара'),             'Баскетбол'),
('Львы',              (SELECT id FROM cities WHERE name='Омск'),               'Хоккей'),
('Феникс',            (SELECT id FROM cities WHERE name='Ростов-на-Дону'),     'Футбол'),
('Пантеры',           (SELECT id FROM cities WHERE name='Уфа'),                'Баскетбол'),
('Соколы',            (SELECT id FROM cities WHERE name='Красноярск'),         'Хоккей')
ON CONFLICT (name) DO NOTHING;

-- Игроки – безопасная привязка по подзапросам
INSERT INTO players (full_name_id, hometown_id, team_id, height_cm, weight_kg) VALUES
((SELECT id FROM full_names WHERE last_name='Иванов'   AND first_name='Иван'    AND patronymic='Иванович'),
 (SELECT id FROM cities     WHERE name='Москва'),
 (SELECT id FROM teams      WHERE name='Титаны'),
 185, 78),

((SELECT id FROM full_names WHERE last_name='Петров'   AND first_name='Пётр'    AND patronymic='Сергеевич'),
 (SELECT id FROM cities     WHERE name='Санкт-Петербург'),
 (SELECT id FROM teams      WHERE name='Орлы'),
 192, 88),

((SELECT id FROM full_names WHERE last_name='Сидоров'  AND first_name='Алексей' AND patronymic='Михайлович'),
 (SELECT id FROM cities     WHERE name='Новосибирск'),
 (SELECT id FROM teams      WHERE name='Молнии'),
 180, 80),

((SELECT id FROM full_names WHERE last_name='Кузнецов' AND first_name='Дмитрий' AND patronymic='Андреевич'),
 (SELECT id FROM cities     WHERE name='Екатеринбург'),
 (SELECT id FROM teams      WHERE name='Северные Волки'),
 187, 82),

((SELECT id FROM full_names WHERE last_name='Смирнов'  AND first_name='Николай' AND patronymic='Петрович'),
 (SELECT id FROM cities     WHERE name='Казань'),
 (SELECT id FROM teams      WHERE name='Шторм'),
 190, 90),

((SELECT id FROM full_names WHERE last_name='Попов'    AND first_name='Сергей'  AND patronymic='Владимирович'),
 (SELECT id FROM cities     WHERE name='Нижний Новгород'),
 (SELECT id FROM teams      WHERE name='Ракеты'),
 182, 83),

((SELECT id FROM full_names WHERE last_name='Васильев' AND first_name='Михаил'  AND patronymic='Олегович'),
 (SELECT id FROM cities     WHERE name='Челябинск'),
 (SELECT id FROM teams      WHERE name='Медведи'),
 195, 95),

((SELECT id FROM full_names WHERE last_name='Новиков'  AND first_name='Артём'   AND patronymic='Евгеньевич'),
 (SELECT id FROM cities     WHERE name='Самара'),
 (SELECT id FROM teams      WHERE name='Дельфины'),
 178, 76),

((SELECT id FROM full_names WHERE last_name='Фёдоров'  AND first_name='Кирилл'  AND patronymic='Игоревич'),
 (SELECT id FROM cities     WHERE name='Омск'),
 (SELECT id FROM teams      WHERE name='Львы'),
 188, 85),

((SELECT id FROM full_names WHERE last_name='Морозов'  AND first_name='Андрей'  AND patronymic='Викторович'),
 (SELECT id FROM cities     WHERE name='Ростов-на-Дону'),
 (SELECT id FROM teams      WHERE name='Феникс'),
 193, 92),

((SELECT id FROM full_names WHERE last_name='Волков'   AND first_name='Илья'    AND patronymic='Александрович'),
 (SELECT id FROM cities     WHERE name='Уфа'),
 (SELECT id FROM teams      WHERE name='Пантеры'),
 184, 79),

((SELECT id FROM full_names WHERE last_name='Алексеев' AND first_name='Роман'   AND patronymic='Денисович'),
 (SELECT id FROM cities     WHERE name='Красноярск'),
 (SELECT id FROM teams      WHERE name='Соколы'),
 181, 78),

((SELECT id FROM full_names WHERE last_name='Лебедев'  AND first_name='Максим'  AND patronymic='Николаевич'),
 (SELECT id FROM cities     WHERE name='Пермь'),
 (SELECT id FROM teams      WHERE name='Титаны'),
 199, 98),

((SELECT id FROM full_names WHERE last_name='Семёнов'  AND first_name='Павел'   AND patronymic='Романович'),
 (SELECT id FROM cities     WHERE name='Воронеж'),
 (SELECT id FROM teams      WHERE name='Орлы'),
 176, 72),

((SELECT id FROM full_names WHERE last_name='Егоров'   AND first_name='Данил'   AND patronymic='Павлович'),
 (SELECT id FROM cities     WHERE name='Волгоград'),
 (SELECT id FROM teams      WHERE name='Молнии'),
 186, 81);
