INSERT INTO subjects(id,name) VALUES(1,'Maths'),(2,'Physique'),(3,'SVT'),(4,'Français'),(5,'Arabe'),(6,'Anglais'),(7,'Informatique'),(8,'Éco-gestion'),(9,'Philo');
INSERT INTO users(id,name,email,password_hash,role,city,level) VALUES
(1,'Yassine B.','tuteur@maak.tn','x','tutor','Tunis',NULL),(2,'Ines M.','ines@maak.tn','x','tutor','Tunis',NULL),
(3,'Mohamed A.','mohamed@maak.tn','x','tutor','Ariana',NULL),(4,'Rym S.','rym@maak.tn','x','tutor','Sfax',NULL),
(5,'Karim T.','karim@maak.tn','x','tutor','Sousse',NULL),(6,'Sarra N.','sarra@maak.tn','x','tutor','Bizerte',NULL),
(7,'Amine K.','eleve@maak.tn','x','student','Tunis','Bac Math');
INSERT INTO tutor_profiles(user_id,university,bio,hourly_rate,levels,modes,rating_avg,rating_count) VALUES
(1,'ENIT – Génie informatique','Étudiant en 3e année, mention très bien au Bac Math. Je rends les exercices de bac concrets.',15,'Lycée,Bac','En ligne,À domicile',4.9,32),
(2,'Faculté de Médecine de Tunis','Fiches claires et quiz à chaque séance. Spécialiste Bac Sciences expérimentales.',20,'Collège,Lycée,Bac','En ligne,Lieu public',4.8,47),
(3,'IHEC Carthage','Patient et méthodique, je m’adapte au rythme de chaque élève.',12,'Collège,Lycée','En ligne,À domicile',4.6,18),
(4,'ISLT – Langues','Lecture, expression écrite et préparation du brevet.',14,'Primaire,Collège,Lycée','En ligne,Lieu public',4.9,25),
(5,'ENSI – Informatique','Algorithmique et bases de données pour le Bac Info.',18,'Lycée,Bac','En ligne',4.7,21),
(6,'Faculté des Sciences de Bizerte','Soutien régulier de la 6e à la 9e année de base.',10,'Primaire,Collège','À domicile,Lieu public',4.5,12);
INSERT INTO tutor_subjects VALUES(1,1),(1,2),(1,7),(2,3),(2,4),(2,2),(3,8),(3,1),(3,6),(4,4),(4,6),(4,5),(5,7),(5,1),(6,1),(6,3),(6,5);
INSERT INTO availabilities(tutor_id,slot) VALUES(1,'Lun 17h'),(1,'Mer 18h'),(1,'Sam 10h'),(2,'Mar 16h'),(2,'Jeu 17h'),(2,'Dim 11h'),
(3,'Lun 18h'),(3,'Ven 17h'),(3,'Sam 15h'),(4,'Mar 17h'),(4,'Mer 16h'),(4,'Sam 9h'),(5,'Jeu 18h'),(5,'Ven 18h'),(5,'Dim 14h'),(6,'Lun 16h'),(6,'Mer 17h'),(6,'Sam 11h');
