-- MAAK – schéma relationnel (SQLite ; adaptable PostgreSQL : INTEGER PK -> SERIAL, DATETIME -> TIMESTAMP)
CREATE TABLE users(
 id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL,
 role TEXT NOT NULL CHECK(role IN('student','tutor')), city TEXT, level TEXT, phone TEXT,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE tutor_profiles(
 user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE, university TEXT, bio TEXT,
 hourly_rate INTEGER NOT NULL DEFAULT 15, levels TEXT DEFAULT 'Lycée', modes TEXT DEFAULT 'En ligne',
 is_available INTEGER NOT NULL DEFAULT 1, rating_avg REAL DEFAULT 0, rating_count INTEGER DEFAULT 0);
CREATE TABLE subjects(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE);
CREATE TABLE tutor_subjects(
 tutor_id INTEGER REFERENCES users(id) ON DELETE CASCADE, subject_id INTEGER REFERENCES subjects(id),
 PRIMARY KEY(tutor_id,subject_id));
CREATE TABLE availabilities(id INTEGER PRIMARY KEY AUTOINCREMENT, tutor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, slot TEXT NOT NULL);
CREATE TABLE bookings(
 id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER NOT NULL REFERENCES users(id), tutor_id INTEGER NOT NULL REFERENCES users(id),
 subject_id INTEGER REFERENCES subjects(id), slot TEXT NOT NULL, mode TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN('pending','confirmed','declined','cancelled','done')),
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE messages(
 id INTEGER PRIMARY KEY AUTOINCREMENT, sender_id INTEGER NOT NULL REFERENCES users(id), receiver_id INTEGER NOT NULL REFERENCES users(id),
 body TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE reviews(
 id INTEGER PRIMARY KEY AUTOINCREMENT, booking_id INTEGER NOT NULL UNIQUE REFERENCES bookings(id),
 rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5), comment TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE notifications(
 id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 body TEXT NOT NULL, read_at DATETIME, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX idx_bookings_student ON bookings(student_id);
CREATE INDEX idx_bookings_tutor ON bookings(tutor_id);
CREATE INDEX idx_messages_pair ON messages(sender_id,receiver_id);
