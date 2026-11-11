INSERT OR IGNORE INTO subjects (name) VALUES ('Theatre');

INSERT OR IGNORE INTO users (name, email, password_hash, role, city, level)
VALUES ('Ghofrane Sayari', 'ghofrane.sayari@maak.invalid', '!disabled!', 'tutor', NULL, NULL);

INSERT INTO tutor_profiles (user_id, university, bio, hourly_rate, levels, modes, is_available, rating_avg, rating_count)
SELECT id,
       'Professional actress and theatre trainer',
       'Ghofrane Sayari is a professional actress and theatre trainer. She offers sessions for all age groups, focusing on body expression, self-confidence, improvisation and performing arts.',
       25, 'جميع الأعمار', 'يُحدّد لاحقًا', 1, 0, 0
FROM users
WHERE email = 'ghofrane.sayari@maak.invalid'
ON CONFLICT (user_id) DO UPDATE SET
  university = excluded.university,
  bio = excluded.bio,
  hourly_rate = excluded.hourly_rate,
  levels = excluded.levels,
  modes = excluded.modes,
  is_available = excluded.is_available;

INSERT OR IGNORE INTO tutor_subjects (tutor_id, subject_id)
SELECT u.id, s.id
FROM users u CROSS JOIN subjects s
WHERE u.email = 'ghofrane.sayari@maak.invalid' AND s.name = 'Theatre';

INSERT OR IGNORE INTO availabilities (tutor_id, slot)
SELECT id, 'يُحدّد لاحقًا'
FROM users
WHERE email = 'ghofrane.sayari@maak.invalid';