# MÉMOIRE DE FIN D’ÉTUDES
**Projet : MAAK – Application mobile de mise en relation entre élèves et étudiants tuteurs pour le soutien scolaire en Tunisie**
Réalisé par : [Prénom NOM] — Formation : [intitulé] — Établissement : [nom]
Présenté en vue de l’obtention du diplôme de : [Licence / Master / Ingénieur] — Soutenance : [date]
Jury : [président, rapporteur, examinateur]
Encadrant pédagogique : [nom] — Encadrant professionnel : [nom, si stage] — Année universitaire : [20XX/20XX]
---
## Dédicace
*[À mes parents, à ma famille et à tous ceux qui m’ont soutenu.]*
## Remerciements
Je remercie mon encadrant [nom] pour ses conseils, l’équipe pédagogique de [établissement] pour la qualité de la formation, ainsi que ma famille et mes camarades pour leur soutien tout au long de ce projet.
## Résumé
Ce mémoire présente MAAK, une application mobile (Flutter) accompagnée d’une API et d’un client web de démonstration, qui met en relation des élèves tunisiens, du primaire au Baccalauréat, avec des étudiants tuteurs. Les familles y recherchent un tuteur par matière, niveau et ville, réservent un créneau, échangent par messages et déposent un avis après la séance. Les tuteurs gèrent leurs demandes et leur profil. La solution repose sur une architecture trois niveaux : une application mobile Flutter, une API REST Node.js/Express sécurisée par jetons JWT, et une base relationnelle de sept tables. Le mémoire détaille l’analyse des besoins, la conception, la réalisation, le plan de tests, les risques, un modèle économique et les perspectives d’évolution.
**Mots-clés :** soutien scolaire, tutorat entre pairs, application mobile, API REST, JWT, SQLite, Tunisie.
**Abstract.** MAAK is a mobile web application connecting Tunisian pupils with student tutors. It provides search by subject, level and city, booking, messaging and reviews, on top of a secured Node.js REST API and a relational database.
**Sommaire**
[[TOC]]
## Liste des figures
[[LOF]]
## Liste des abréviations
| Sigle | Signification |
| API | Application Programming Interface |
| REST | Representational State Transfer |
| JWT | JSON Web Token |
| SQL | Structured Query Language |
| MCD | Modèle conceptuel des données |
| PWA | Progressive Web App |
| UI / UX | Interface utilisateur / Expérience utilisateur |
| XSS | Cross-Site Scripting |
| DT | Dinar tunisien |
## Introduction générale
Le soutien scolaire occupe une place importante dans le parcours des élèves tunisiens, notamment au collège et au lycée où la préparation du Baccalauréat est une échéance majeure. Les cours particuliers se trouvent pourtant surtout par le bouche-à-oreille : les familles ont du mal à comparer les offres, à vérifier le sérieux d’un tuteur et à organiser les séances, tandis que de nombreux étudiants compétents n’ont pas de canal simple pour proposer leurs services. MAAK répond à ce besoin en structurant la rencontre entre l’offre et la demande. Le mémoire s’organise en six chapitres : l’étude de l’existant et l’état de l’art, l’analyse des besoins, la conception, la réalisation (API, client web et application mobile Flutter), les tests, puis la gestion du projet, le modèle économique et les risques.
### Problématique
Comment faciliter, depuis un téléphone, la rencontre entre des élèves qui cherchent un appui et des étudiants prêts à enseigner, tout en instaurant la confiance entre des personnes qui ne se connaissent pas ?
### Objectifs
- Rechercher un tuteur par matière, niveau et ville, et trier par prix ou par note.
- Réserver un créneau et choisir le mode de séance (en ligne, à domicile, lieu public).
- Permettre au tuteur de confirmer, refuser et clôturer les séances.
- Échanger par messages et déposer un avis après une séance terminée.
- Garantir la sécurité des comptes et la protection des données.
### Méthodologie
Démarche itérative inspirée des méthodes agiles : recueil des besoins, maquettage, développement de l’API et de l’interface par incréments, puis tests. *[Préciser la méthode réellement suivie : Scrum, Kanban, cycle en V…]*
## Chapitre 1 – Étude de l’existant et état de l’art
*Ce chapitre situe le projet dans son contexte : il présente le paysage du soutien scolaire en Tunisie, compare les solutions existantes, puis justifie le choix des technologies mobiles.*
### 1.1 Panorama des solutions de soutien scolaire
Les solutions actuelles se répartissent en trois familles : les groupes de réseaux sociaux et annonces, les centres de soutien scolaire et les plateformes internationales de tutorat. Le tableau suivant les compare à MAAK ; les appréciations sont qualitatives et doivent être confirmées par votre propre benchmark.
| Critère | Groupes et annonces | Centres de soutien | Plateformes internationales | MAAK |
| Structuration de l’offre | Faible | Bonne | Bonne | Bonne |
| Programmes tunisiens | Variable | Oui | Rarement | Oui |
| Tarifs en dinars | Variable | Oui | Rarement | Oui |
| Vérification et avis | Aucune | Interne | Oui | Avis après séance |
| Flexibilité des horaires | Élevée | Limitée | Élevée | Élevée |
| Coût pour la famille | Variable | Généralement plus élevé | Généralement plus élevé | Tuteurs étudiants, plus accessible |
### 1.2 Le système éducatif tunisien et le besoin de soutien
Le système éducatif tunisien s’organise en cycles successifs. L’enseignement de base dure neuf ans : six années d’école primaire puis trois années de collège, et se conclut par un examen national de fin de neuvième année qui conditionne l’accès au secondaire. L’enseignement secondaire dure quatre ans et débouche sur le Baccalauréat, passé dans une section choisie à partir de la deuxième année (Lettres, Mathématiques, Sciences expérimentales, Économie et gestion, Sciences techniques, Informatique, Sport). Le Baccalauréat joue un rôle déterminant : la note finale pilote l’orientation vers l’enseignement supérieur.
Ces échéances nationales créent des moments de forte pression pour les élèves et leurs familles : examen de fin de neuvième année, entrée au lycée et, surtout, dernière année du secondaire. Les matières scientifiques (mathématiques, physique, sciences de la vie et de la Terre, informatique) et les langues (français, anglais, arabe) sont celles pour lesquelles un soutien extérieur est le plus souvent recherché. *[À compléter avec des données chiffrées issues de sources officielles : ministère de l’Éducation, Institut national de la statistique.]*
Dans ce contexte, un élève qui rencontre une difficulté dans un chapitre précis a besoin d’une aide ciblée, disponible rapidement et à un coût compatible avec le budget familial. C’est le créneau que vise MAAK.
### 1.3 Le tutorat entre pairs
Le tutorat entre pairs consiste à confier l’accompagnement d’un apprenant à une personne plus avancée dans le cursus, souvent proche en âge. Ses avantages généralement admis sont la proximité de langage entre le tuteur et l’élève, la connaissance récente des programmes et des examens, et un coût inférieur à celui d’un enseignant professionnel. Pour le tuteur étudiant, l’activité consolide ses propres acquis, car expliquer oblige à structurer sa pensée, et procure un revenu complémentaire.
Ses limites tiennent à l’absence de formation pédagogique formelle du tuteur, à la variabilité de la qualité et à la nécessité d’un cadre de confiance. C’est pourquoi MAAK intègre des avis après séance, un profil détaillé et, en perspective, la vérification de la carte d’étudiant et la modération. *[Appuyer ce paragraphe sur des références académiques relatives au tutorat entre pairs.]*
### 1.4 Cadre juridique et éthique
MAAK manipule des données personnelles, parfois de mineurs : noms, villes, niveaux scolaires, échanges de messages. En Tunisie, la protection des données à caractère personnel est encadrée par la loi organique n° 2004-63 du 27 juillet 2004 et supervisée par l’Instance nationale de protection des données personnelles (INPDP). *[Vérifier les textes en vigueur et leurs évolutions avant toute mise en production.]*
Les principes à respecter sont la collecte limitée aux données nécessaires, l’information claire des utilisateurs, leur consentement, la sécurité des données et la possibilité d’y accéder et de les supprimer. Pour les élèves mineurs, il est recommandé de faire valider l’inscription et les réservations par un parent ou tuteur légal, de privilégier les séances en ligne ou en lieu public, et de proposer un signalement des comportements inappropriés. Ces points figurent dans la feuille de route et dans le tableau des risques.
### 1.5 Technologies mobiles : état de l’art
Trois grandes approches existent pour livrer une application sur smartphone. Le choix de **Flutter** s’explique par un code unique pour Android et iOS, des performances proches du natif grâce à un rendu propre, une bibliothèque de composants Material 3 et une productivité élevée pour un projet mené seul.
| Approche | Avantages | Inconvénients |
| Natif (Kotlin, Swift) | Performances maximales, accès complet au système | Deux bases de code, coût élevé |
| Web / PWA | Un seul code, déploiement immédiat | Accès limité aux fonctions du téléphone, expérience moins fluide |
| Multiplateforme (Flutter, React Native) | Un code pour Android et iOS, bonnes performances | Dépendance au framework, taille de l’application |
### 1.6 Choix technologiques justifiés
| Composant | Choix | Justification | Alternative envisagée |
| Application mobile | Flutter (Dart) | Un seul code pour Android et iOS, composants Material 3, bonne productivité | React Native, natif |
| API | Node.js et Express | Écosystème riche, JSON natif, apprentissage rapide | Django, Spring Boot |
| Base de données | SQLite (better-sqlite3) | Aucune installation, SQL standard, adapté au prototype | PostgreSQL en production |
| Authentification | JWT et bcrypt | Sans état côté serveur, adapté au mobile | Sessions, OAuth |
| Client web | HTML, CSS, JavaScript | Démonstration rapide sans compilation | Flutter web |
| Hébergement | Render (offre gratuite) | Déploiement depuis GitHub, HTTPS inclus | Autres hébergeurs |
**Conclusion du chapitre.** L’étude de l’existant met en évidence un espace pour une solution structurée, accessible et adaptée aux programmes tunisiens ; le choix de Flutter répond aux contraintes de temps et de budget.
## Chapitre 2 – Analyse des besoins
*Ce chapitre formalise les besoins des utilisateurs : acteurs, personas, besoins fonctionnels et non fonctionnels, récits utilisateurs, règles de gestion et contraintes.*
### 2.1 Acteurs
L’**élève** (ou son parent) recherche, réserve, discute et évalue. Le **tuteur** est un étudiant qui publie son profil, traite les demandes et clôture les séances. L’**administrateur** (évolution prévue) modère les profils et les avis.
### 2.2 Personas
Trois profils types guident les choix de conception. *[Personas fictifs : à remplacer ou compléter par vos entretiens avec des élèves, parents et étudiants.]*
| Persona | Profil | Besoins | Frustrations actuelles |
| Yassmine, 17 ans | Élève en dernière année du secondaire, section Mathématiques, à Tunis | Préparer le Baccalauréat, comprendre les chapitres de physique | Peu de temps, difficulté à trouver un tuteur fiable |
| Mme Karray, 42 ans | Parent d’un élève de 8e année de base, à Sfax | Comparer les prix, savoir qui est le tuteur, choisir un lieu sûr | Tarifs flous, aucun avis, appels répétés |
| Aymen, 21 ans | Étudiant en génie informatique, souhaite donner des cours | Trouver des élèves, fixer ses horaires et son tarif | Pas de canal structuré, organisation par messages dispersés |
### 2.3 Besoins fonctionnels
| Acteur | Cas d’utilisation | Priorité |
| Visiteur | S’inscrire, se connecter | Haute |
| Élève | Rechercher, filtrer et trier les tuteurs | Haute |
| Élève | Consulter un profil et ses avis | Haute |
| Élève | Réserver un créneau, annuler une séance | Haute |
| Élève | Écrire à un tuteur | Moyenne |
| Élève | Noter une séance terminée | Moyenne |
| Tuteur | Accepter ou refuser une demande | Haute |
| Tuteur | Marquer une séance comme terminée | Haute |
| Tuteur | Modifier matières, tarif, présentation et disponibilité | Haute |
| Administrateur | Modérer profils et avis (évolution) | Basse |
### 2.4 Besoins non fonctionnels
| Catégorie | Exigence |
| Ergonomie | Utilisation mobile d’abord, navigation par onglets, interface en français (arabe en perspective) |
| Sécurité | Mots de passe hachés, authentification par jeton, contrôle des droits, protection contre l’injection SQL et le XSS |
| Performance | Réponses rapides sur connexion limitée, requêtes indexées |
| Maintenabilité | Code organisé par couches, schéma SQL versionné, documentation de l’API |
| Portabilité | Fonctionnement sur navigateur mobile et ordinateur, base migrable vers PostgreSQL |
### 2.5 Récits utilisateurs
| N° | Récit | Priorité |
| US1 | En tant que visiteur, je veux créer un compte afin d’accéder à la plateforme | Haute |
| US2 | En tant qu’utilisateur, je veux rester connecté afin de ne pas ressaisir mes identifiants | Haute |
| US3 | En tant qu’élève, je veux rechercher un tuteur par matière afin de trouver une aide ciblée | Haute |
| US4 | En tant qu’élève, je veux filtrer par ville et trier par prix ou note afin de comparer | Haute |
| US5 | En tant qu’élève, je veux consulter le profil et les avis d’un tuteur afin de choisir en confiance | Haute |
| US6 | En tant qu’élève, je veux réserver un créneau et un mode de séance afin d’organiser mon soutien | Haute |
| US7 | En tant qu’élève, je veux annuler une séance afin de gérer les imprévus | Moyenne |
| US8 | En tant qu’élève, je veux écrire à un tuteur afin de préciser mon besoin | Moyenne |
| US9 | En tant qu’élève, je veux noter une séance terminée afin d’aider les autres élèves | Moyenne |
| US10 | En tant que tuteur, je veux publier mon profil, mes matières et mon tarif afin d’être trouvé | Haute |
| US11 | En tant que tuteur, je veux gérer mes créneaux afin d’indiquer mes disponibilités | Haute |
| US12 | En tant que tuteur, je veux accepter ou refuser une demande afin de contrôler mon planning | Haute |
| US13 | En tant que tuteur, je veux marquer une séance comme terminée afin d’ouvrir la possibilité d’un avis | Haute |
| US14 | En tant que tuteur, je veux répondre aux messages des élèves afin de préparer les séances | Moyenne |
| US15 | En tant qu’utilisateur, je veux être notifié des événements importants afin de réagir rapidement | Moyenne |
| US16 | En tant qu’administrateur, je veux modérer profils et avis afin de garantir la qualité | Basse |
### 2.6 Règles de gestion
| Code | Règle |
| RG1 | Une adresse e-mail ne peut servir qu’à un seul compte |
| RG2 | Un mot de passe comporte au moins six caractères et n’est jamais stocké en clair |
| RG3 | Un compte a un rôle unique : élève ou tuteur |
| RG4 | Seul un élève peut créer une réservation, auprès d’un tuteur existant |
| RG5 | Toute nouvelle réservation est au statut « en attente » |
| RG6 | Seul le tuteur concerné peut confirmer, refuser ou terminer une réservation |
| RG7 | Seul l’élève concerné peut annuler sa réservation |
| RG8 | Un avis n’est possible que pour une réservation terminée, et une seule fois |
| RG9 | La note est comprise entre 1 et 5 ; la moyenne du tuteur est recalculée après chaque avis |
| RG10 | Un tuteur en pause n’apparaît plus dans les résultats de recherche |
| RG11 | Un message ne peut dépasser 1 000 caractères |
| RG12 | Un tuteur peut publier au plus 40 créneaux |
### 2.7 Contraintes du projet
- **Techniques :** connexion mobile parfois lente, terminaux Android variés dont des modèles d’entrée de gamme, interface en français.
- **Organisationnelles :** projet mené par une seule personne dans un délai académique limité.
- **Financières :** budget quasi nul, d’où le recours à des outils libres et à des offres d’hébergement gratuites pour la démonstration.
- **Juridiques :** protection des données personnelles et des mineurs.
- **Pédagogiques :** l’application met en relation, mais n’évalue pas la qualité pédagogique des tuteurs.
**Conclusion du chapitre.** Les besoins recensés fixent le périmètre de la première version et servent de référence pour la conception et les tests.
## Chapitre 3 – Conception
*Ce chapitre présente la conception : architecture, cas d’utilisation, modèle de données, cycle de vie des réservations, séquence principale, interface et sécurité.*
### 3.1 Architecture
L’application suit une architecture trois niveaux séparant la présentation, la logique métier et les données.
![Architecture trois niveaux de MAAK|figures/architecture.png|560|168]
### 3.2 Diagramme des cas d’utilisation
![Diagramme des cas d’utilisation de MAAK|figures/usecase.png|560|375]
Le diagramme distingue trois acteurs : le visiteur, qui s’inscrit ou se connecte, l’élève et le tuteur. Les notifications et la messagerie sont partagées par les deux rôles. Le cas central, la réservation d’une séance, est décrit ci-dessous.
| Élément | Contenu |
| Cas d’utilisation | Réserver une séance |
| Acteur principal | Élève |
| Acteur secondaire | Tuteur |
| Préconditions | L’élève est connecté ; le tuteur est disponible et propose au moins un créneau |
| Scénario nominal | 1. L’élève ouvre le profil d’un tuteur. 2. Il choisit un créneau et un mode de séance. 3. Il valide. 4. Le système crée la réservation au statut « en attente » et notifie le tuteur. 5. Le tuteur accepte. 6. Le système met à jour le statut et notifie l’élève. |
| Scénarios alternatifs | A1 : le tuteur refuse et l’élève est notifié. A2 : l’élève annule avant ou après confirmation. A3 : le serveur est injoignable et l’application affiche un message d’erreur. |
| Postconditions | Une réservation existe avec un statut cohérent ; les deux parties ont été notifiées |
Second cas détaillé :
| Élément | Contenu |
| Cas d’utilisation | Laisser un avis |
| Acteur principal | Élève |
| Préconditions | La séance a été marquée « terminée » par le tuteur ; aucun avis n’existe pour cette séance |
| Scénario nominal | 1. L’élève ouvre « Séances ». 2. Il choisit « Laisser un avis ». 3. Il indique une note de 1 à 5 et un commentaire facultatif. 4. Le système enregistre l’avis et recalcule la note moyenne du tuteur. |
| Scénarios alternatifs | A1 : séance non terminée, l’avis est refusé. A2 : avis déjà déposé, le bouton n’est plus proposé. |
| Postconditions | L’avis apparaît sur le profil du tuteur |
### 3.3 Modèle de données
Le modèle comprend sept tables : les comptes, les profils tuteurs, le catalogue de matières, l’association tuteur–matières, les disponibilités, les réservations, les messages et les avis.
![Modèle conceptuel des données|figures/mcd.png|560|300]
| Table | Rôle | Champs clés |
| users | Comptes élèves et tuteurs | email unique, rôle, ville |
| tutor_profiles | Profil public du tuteur | tarif horaire, niveaux, modes, note moyenne |
| subjects, tutor_subjects | Matières et association n-n | identifiant matière, tuteur |
| availabilities | Créneaux proposés | tuteur, créneau |
| bookings | Réservations | élève, tuteur, créneau, mode, statut |
| messages | Échanges entre utilisateurs | expéditeur, destinataire, texte |
| reviews | Avis après séance | réservation unique, note de 1 à 5 |
### 3.4 Dictionnaire de données
Les tables sont décrites ci-dessous ; les types sont ceux de SQLite.
**Table users** : comptes des élèves et des tuteurs.
| Champ | Type | Contraintes | Description |
| id | INTEGER | Clé primaire, auto-incrément | Identifiant du compte |
| name | TEXT | Obligatoire | Nom affiché |
| email | TEXT | Obligatoire, unique | Identifiant de connexion |
| password_hash | TEXT | Obligatoire | Mot de passe haché (bcrypt) |
| role | TEXT | student ou tutor | Rôle de l’utilisateur |
| city, level, phone | TEXT | Facultatifs | Ville, niveau scolaire, téléphone |
| created_at | DATETIME | Valeur par défaut : maintenant | Date de création |
**Table tutor_profiles** : profil public d’un tuteur.
| Champ | Type | Contraintes | Description |
| user_id | INTEGER | Clé primaire et étrangère | Lien vers users |
| university | TEXT | Facultatif | Établissement |
| bio | TEXT | Facultatif | Présentation |
| hourly_rate | INTEGER | Obligatoire, défaut 15 | Tarif en dinars par heure |
| levels, modes | TEXT | Listes séparées par des virgules | Niveaux et modes de séance proposés |
| is_available | INTEGER | 0 ou 1 | Visible dans les recherches |
| rating_avg, rating_count | REAL, INTEGER | Défaut 0 | Note moyenne et nombre d’avis |
**Tables subjects et tutor_subjects** : catalogue de matières et association plusieurs-à-plusieurs.
| Champ | Type | Contraintes | Description |
| subjects.id, subjects.name | INTEGER, TEXT | Clé primaire, nom unique | Matière |
| tutor_subjects.tutor_id | INTEGER | Clé étrangère, clé primaire composite | Tuteur |
| tutor_subjects.subject_id | INTEGER | Clé étrangère, clé primaire composite | Matière |
**Table availabilities** : créneaux proposés par un tuteur.
| Champ | Type | Contraintes | Description |
| id | INTEGER | Clé primaire | Identifiant |
| tutor_id | INTEGER | Clé étrangère, suppression en cascade | Tuteur |
| slot | TEXT | Obligatoire | Créneau, par exemple « Lun 17h » |
**Table bookings** : réservations.
| Champ | Type | Contraintes | Description |
| id | INTEGER | Clé primaire | Identifiant |
| student_id, tutor_id | INTEGER | Clés étrangères | Élève et tuteur concernés |
| subject_id | INTEGER | Clé étrangère, facultatif | Matière de la séance |
| slot, mode | TEXT | Obligatoires | Créneau et mode de séance |
| status | TEXT | pending, confirmed, declined, cancelled, done | Statut |
| created_at | DATETIME | Défaut : maintenant | Date de la demande |
**Tables messages, reviews et notifications.**
| Champ | Type | Contraintes | Description |
| messages.sender_id, receiver_id | INTEGER | Clés étrangères | Expéditeur et destinataire |
| messages.body | TEXT | Obligatoire, 1 000 caractères au plus (API) | Contenu |
| reviews.booking_id | INTEGER | Unique, clé étrangère | Une seule évaluation par séance |
| reviews.rating | INTEGER | Entre 1 et 5 | Note |
| notifications.user_id | INTEGER | Clé étrangère, suppression en cascade | Destinataire |
| notifications.body, read_at | TEXT, DATETIME | read_at vide tant que non lue | Texte et date de lecture |
### 3.5 Normalisation et choix de conception
Le schéma respecte globalement la troisième forme normale : chaque table décrit une seule entité, les attributs dépendent de la clé primaire et les associations plusieurs-à-plusieurs (tuteurs et matières) passent par une table de jonction. Deux compromis assumés ont été faits pour garder un prototype simple. D’abord, la note moyenne et le nombre d’avis sont dénormalisés dans `tutor_profiles` afin d’éviter un calcul d’agrégat à chaque affichage de la liste ; ils sont recalculés après chaque nouvel avis. Ensuite, les niveaux et les modes de séance sont stockés comme listes séparées par des virgules, ce qui déroge à la première forme normale ; en production, ils deviendraient des tables dédiées.
Les clés étrangères sont activées, les suppressions en cascade protègent l’intégrité (profil, créneaux, notifications) et des index accélèrent les recherches de réservations par élève, par tuteur et les conversations. La migration vers PostgreSQL ne demande que des adaptations de types (clés auto-incrémentées, horodatages).
### 3.6 Cycle de vie d’une réservation
| État | Déclencheur | Acteur |
| pending | Demande de réservation | Élève |
| confirmed | Acceptation de la demande | Tuteur |
| declined | Refus de la demande | Tuteur |
| cancelled | Annulation | Élève |
| done | Séance effectuée, ouvre le droit à l’avis | Tuteur |
### 3.7 Diagramme de séquence : réserver une séance
![Diagramme de séquence de la réservation d’une séance|figures/sequence.png|560|347]
Le diagramme montre que l’application mobile ne contient aucune règle sensible : elle transmet la demande avec le jeton d’authentification, et c’est l’API qui vérifie les droits, écrit en base et crée les notifications. L’actualisation périodique permet à l’élève de découvrir la confirmation sans action de sa part.
### 3.8 Conception de l’interface
Quatre principes ont guidé le dessin des écrans : lisibilité sur petit écran, navigation par onglets accessible au pouce, retours d’information immédiats (messages d’erreur et de confirmation) et cohérence entre les rôles élève et tuteur.
| Élément | Choix | Raison |
| Couleur principale | Bleu profond (#1B56C4) | Identité sobre, bon contraste |
| Système de design | Material 3, thème clair et sombre | Composants accessibles et familiers |
| Navigation | Barre inférieure : 5 onglets élève, 4 onglets tuteur | Accès rapide aux fonctions principales |
| Retours | Messages temporaires, badge de notifications | L’utilisateur sait toujours ce qui s’est passé |
![Plan de navigation de l’application mobile|figures/navigation.png|560|329]
### 3.9 Sécurité
| Menace | Mesure mise en œuvre |
| Vol de mots de passe | Hachage bcrypt, aucun mot de passe en clair |
| Usurpation de session | Jetons JWT signés, durée limitée à 7 jours |
| Accès à des données d’autrui | Vérification du rôle et de la propriété de chaque ressource |
| Injection SQL | Requêtes préparées et paramétrées |
| Injection de code (XSS) | Échappement des textes saisis avant affichage |
| Force brute sur la connexion | Limitation à 20 tentatives par minute et par adresse |
| Attaques par détournement d’affichage | En-têtes de sécurité (nosniff, X-Frame-Options) |
**Conclusion du chapitre.** La conception retenue sépare clairement la présentation, la logique métier et les données, ce qui facilite la réalisation et l’évolution du système.
## Chapitre 4 – Réalisation
*Ce chapitre décrit la réalisation : technologies, interfaces, application mobile, API, notifications, client web et déploiement.*
### 4.1 Technologies
Flutter (Dart) pour l’application mobile, Node.js et Express pour l’API, better-sqlite3 pour l’accès à la base, bcryptjs et jsonwebtoken pour la sécurité, HTML/CSS/JavaScript sans framework pour le client web de démonstration, ce qui limite les dépendances et facilite la maintenance.
### 4.2 Interface
- **Accueil :** connexion, inscription (élève ou tuteur, ville) et accès démonstration.
- **Explorer :** recherche textuelle, filtres matière, niveau et ville, tri par prix ou par note.
- **Profil d’un tuteur :** présentation, matières, avis, choix du créneau et du mode, réservation, message.
- **Séances :** suivi des statuts, annulation, dépôt d’un avis après une séance terminée.
- **Messages :** conversations avec les tuteurs.
- **Espace tuteur :** demandes à traiter, gains prévus, clôture des séances, profil (matières, tarif, présentation, pause).
### 4.3 Application mobile Flutter
L’application mobile est un client de l’API REST : elle ne contient aucune règle métier sensible, celles-ci restant côté serveur.
| Fichier | Rôle |
| lib/main.dart | Point d’entrée, thème Material 3 clair et sombre, aiguillage selon le rôle |
| lib/api.dart | Client HTTP, ajout du jeton JWT, gestion des erreurs, mémorisation du jeton |
| lib/state.dart | État global (ChangeNotifier) : utilisateur, tuteurs, réservations, messages |
| lib/screens.dart | Écrans élève et tuteur, boîtes de dialogue |
- **Gestion d’état :** une classe unique `AppState` notifie les écrans qui l’écoutent ; ce choix volontairement simple évite une dépendance supplémentaire.
- **Navigation :** barre de navigation Material 3 (Explorer, Séances, Messages, Profil pour l’élève ; Demandes, Profil pour le tuteur).
- **Session :** le jeton JWT est conservé sur l’appareil et réutilisé au démarrage.
- **Robustesse :** délai maximal de 15 secondes par requête et message d’erreur clair si le serveur est injoignable.
- **Écrans élève :** recherche et filtre par matière, fiche tuteur avec avis, réservation, suivi et annulation des séances, avis, messagerie.
- **Écrans tuteur :** demandes à accepter ou refuser, clôture des séances, gains prévus, messagerie avec les élèves, gestion de ses créneaux, profil (tarif, présentation, matières, disponibilité).
- **Filtre par ville** dans l’exploration des tuteurs.
- **Notifications :** table `notifications` côté serveur (nouvelle demande, changement de statut, nouveau message), centre de notifications avec compteur de non-lus et actualisation automatique toutes les 20 secondes.
### 4.4 API REST
| Méthode | Route | Accès | Description |
| POST | /api/auth/register, /api/auth/login | Public | Création de compte et connexion |
| GET | /api/me | Connecté | Compte et profil de l’utilisateur |
| GET | /api/tutors | Public | Liste filtrée des tuteurs |
| GET | /api/tutors/:id/reviews | Public | Avis d’un tuteur |
| PUT | /api/tutor/profile | Tuteur | Mise à jour du profil |
| POST, GET | /api/bookings | Élève, connecté | Créer et lister les réservations |
| PATCH | /api/bookings/:id | Tuteur, élève | Changer le statut |
| GET, POST | /api/messages | Connecté | Lire et envoyer des messages |
| POST | /api/reviews | Élève | Déposer un avis sur une séance terminée |
### 4.5 Structure du projet
```
maak/
├── server/index.js        API REST (Express)
├── database/schema.sql    Schéma relationnel
├── database/seed.sql      Données de démonstration
├── public/index.html      Client web de démonstration
├── mobile/                Application Flutter
│   ├── pubspec.yaml
│   └── lib/               main, api, state, screens
├── docs/                  Mémoire et figures
├── render.yaml            Déploiement (Render)
└── DEPLOY.md              Guide de mise en ligne
```
### 4.6 Documentation détaillée de l’API
Toutes les routes échangent du JSON. Les routes protégées exigent l’en-tête `Authorization: Bearer <jeton>`. Voici les échanges principaux.
**Inscription** (POST /api/auth/register) :
```
{ "name": "Amine K.", "email": "amine@example.tn", "password": "secret1", "role": "student", "city": "Tunis" }
```
Réponse 201 :
```
{ "token": "eyJ...", "user": { "id": 8, "name": "Amine K.", "role": "student", "city": "Tunis" } }
```
**Liste des tuteurs** (GET /api/tutors?subject=Maths&city=Tunis), extrait de la réponse :
```
[ { "id": 1, "n": "Yassine B.", "u": "ENIT – Génie informatique", "c": "Tunis", "p": 15,
    "r": 4.9, "rv": 32, "m": ["Maths", "Physique", "Informatique"],
    "l": ["Lycée", "Bac"], "md": ["En ligne", "À domicile"], "s": ["Lun 17h", "Mer 18h"] } ]
```
**Réservation** (POST /api/bookings) :
```
{ "tutor_id": 1, "slot": "Lun 17h", "mode": "En ligne" }
```
Réponse 201 :
```
{ "id": 12, "status": "pending" }
```
**Changement de statut** (PATCH /api/bookings/12) par le tuteur : `{ "status": "confirmed" }`. Réponse 200 : `{ "id": 12, "status": "confirmed" }`.
**Avis** (POST /api/reviews) : `{ "booking_id": 12, "rating": 5, "comment": "Très clair" }`.
**Profil tuteur** (PUT /api/tutor/profile) :
```
{ "hourly_rate": 18, "bio": "Étudiant en 3e année", "is_available": true,
  "subjects": ["Maths", "Physique"], "slots": ["Lun 17h", "Mer 18h"] }
```
### 4.7 Gestion des erreurs
Les erreurs sont renvoyées au format `{ "error": "message" }` avec un code HTTP adapté.
| Code | Cas | Exemple de message |
| 400 | Données invalides | Champs invalides ; Réservation invalide |
| 401 | Absence ou invalidité du jeton, identifiants incorrects | Non authentifié ; Identifiants incorrects |
| 403 | Action interdite pour ce rôle ou cette ressource | Action non autorisée |
| 404 | Ressource introuvable | Introuvable |
| 409 | Conflit | E-mail déjà utilisé |
| 429 | Trop de tentatives de connexion | Trop de tentatives, réessayez dans une minute |
| 500 | Erreur interne | Erreur serveur |
### 4.8 Notifications et messagerie
Les notifications sont stockées dans la table `notifications`. Elles sont créées côté serveur lors de trois événements : une nouvelle demande de réservation (le tuteur est notifié), un changement de statut d’une séance (l’autre partie est notifiée) et un nouveau message. L’application les récupère à l’ouverture puis toutes les vingt secondes ; un compteur de non-lus s’affiche sur l’onglet « Alertes », et un bouton permet de tout marquer comme lu.
Ce choix de l’interrogation périodique évite toute dépendance à un service externe et fonctionne sur un hébergement gratuit. Sa limite est le délai d’affichage de l’ordre de vingt secondes et la consommation de données. L’évolution naturelle consiste à utiliser les notifications push de Firebase Cloud Messaging et une connexion temps réel (WebSocket) pour la messagerie.
La messagerie enregistre chaque message avec son expéditeur et son destinataire. L’API renvoie les noms des deux parties afin que le tuteur, comme l’élève, puisse afficher la liste de ses conversations.
### 4.9 Client web de démonstration
Un client web écrit en HTML, CSS et JavaScript sans framework reproduit les fonctions principales et consomme la même API. Il sert de démonstration rapide, sans installation de Flutter, et de point de comparaison pour valider que l’API est indépendante du client. Les textes saisis par les utilisateurs y sont systématiquement échappés avant affichage pour éviter l’injection de code.
### 4.10 Spécifications des écrans
Le tableau suivant récapitule les écrans de l’application mobile, leurs fonctions et les routes de l’API qu’ils utilisent.
| Écran | Utilisateur | Fonctions | Routes de l’API |
| Connexion et inscription | Visiteur | Choix du mode, du rôle et de la ville, validation des champs, messages d’erreur | POST /auth/login, POST /auth/register |
| Explorer | Élève | Recherche, filtre par matière et par ville, actualisation par glissement | GET /tutors |
| Fiche tuteur | Élève | Profil, créneaux, mode, avis, réservation, accès à la messagerie | GET /tutors/:id/reviews, POST /bookings |
| Séances | Élève | Suivi des statuts, annulation, dépôt d’un avis | GET /bookings, PATCH /bookings/:id, POST /reviews |
| Messages | Élève, tuteur | Liste des conversations | GET /messages |
| Conversation | Élève, tuteur | Lecture et envoi de messages | POST /messages |
| Alertes | Élève, tuteur | Liste des notifications, compteur, marquage comme lu | GET /notifications, POST /notifications/read |
| Profil élève | Élève | Identité, déconnexion | GET /me |
| Demandes | Tuteur | Acceptation, refus, clôture des séances, gains prévus | GET /bookings, PATCH /bookings/:id |
| Profil tuteur | Tuteur | Tarif, présentation, matières, créneaux, disponibilité | GET /me, PUT /tutor/profile |
### 4.11 Analyse commentée du code de l’API
Le serveur tient en un seul fichier organisé par fonctionnalités. Les extraits suivants illustrent les mécanismes essentiels.
**Authentification.** Le middleware `auth` lit le jeton de l’en-tête, le vérifie avec la clé secrète et place l’identité de l’utilisateur dans la requête ; en cas d’échec il répond 401. La fonction `sign` fabrique un jeton valable sept jours.
```
const auth=(req,res,next)=>{try{req.u=jwt.verify((req.headers.authorization||'').slice(7),SECRET);next()}catch{res.status(401).json({error:'Non authentifié'})}};
const sign=u=>({token:jwt.sign({id:u.id,role:u.role},SECRET,{expiresIn:'7d'}),user:{id:u.id,name:u.name,role:u.role,city:u.city}});
```
**Création d’une réservation.** La route vérifie le rôle de l’appelant, contrôle que le tuteur existe, enregistre la réservation avec des requêtes paramétrées, puis crée la notification destinée au tuteur.
```
app.post('/api/bookings',auth,(req,res)=>{
  const{tutor_id,slot,mode,subject}=req.body||{};
  if(req.u.role!='student')return bad(res,'Réservé aux élèves',403);
  if(!tutor_id||!slot||!mode||!db.prepare("select 1 from users where id=? and role='tutor'").get(tutor_id))return bad(res,'Réservation invalide');
  const s=subject&&db.prepare('select id from subjects where name=?').get(subject);
  const id=db.prepare('insert into bookings(student_id,tutor_id,subject_id,slot,mode) values(?,?,?,?,?)').run(req.u.id,tutor_id,s?s.id:null,slot,mode).lastInsertRowid;
  notify(tutor_id,'Nouvelle demande de '+uname(req.u.id)+' : '+slot+' ('+mode+')');
  res.status(201).json({id,status:'pending'});
});
app.get('/api/bookings',auth,(req,res)=>res.json(db.prepare('select b.id,b.tutor_id,b.student_id,b.slot,b.mode,b.status,su.name student_name,su.level student_level,s.name subject,(select 1 from reviews r where r.booking_id=b.id) rated from bookings b join users su on su.id=b.student_id left join subjects s on s.id=b.subject_id where b.student_id=? or b.tutor_id=? order by b.id desc').all(req.u.id,req.u.id)));
app.patch('/api/bookings/:id',auth,(req,res)=>{
```
**Changement de statut.** La règle de gestion RG6 et RG7 est appliquée en une expression : le tuteur concerné peut confirmer, refuser ou terminer, l’élève concerné peut annuler, et toute autre combinaison renvoie 403.
```
app.patch('/api/bookings/:id',auth,(req,res)=>{
  const b=db.prepare('select * from bookings where id=?').get(req.params.id),st=(req.body||{}).status;
  if(!b)return bad(res,'Introuvable',404);
  const ok=(b.tutor_id==req.u.id&&['confirmed','declined','done'].includes(st))||(b.student_id==req.u.id&&st=='cancelled');
  if(!ok)return bad(res,'Action non autorisée',403);
  db.prepare('update bookings set status=? where id=?').run(st,b.id);
  const L={confirmed:'confirmée',declined:'refusée',cancelled:'annulée',done:'terminée'};notify(req.u.id==b.tutor_id?b.student_id:b.tutor_id,'Séance '+L[st]+' : '+b.slot+' ('+uname(req.u.id)+')');
  res.json({id:b.id,status:st});
});
app.get('/api/messages',auth,(req,res)=>res.json(db.prepare('select m.*,su.name sender_name,ru.name receiver_name from messages m join users su on su.id=m.sender_id join users ru on ru.id=m.receiver_id where m.sender_id=? or m.receiver_id=? order by m.id').all(req.u.id,req.u.id)));
```
### 4.12 Analyse commentée du code Flutter
**Client HTTP.** La méthode `call` centralise tous les appels : elle ajoute le jeton, encode le corps en JSON, applique un délai maximal de quinze secondes, décode la réponse et transforme les erreurs du serveur en exceptions lisibles. Les écrans n’ont donc jamais à manipuler directement le protocole HTTP.
```
  static Future<dynamic> call(String method, String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final b = body == null ? null : jsonEncode(body);
    try {
      final http.Response r = switch (method) {
        'POST' => await http.post(uri, headers: h, body: b),
        'PUT' => await http.put(uri, headers: h, body: b),
        'PATCH' => await http.patch(uri, headers: h, body: b),
        _ => await http.get(uri, headers: h),
      }.timeout(const Duration(seconds: 15));
      final data = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
      if (r.statusCode >= 400) throw ApiError((data is Map ? data['error'] : null) ?? 'Erreur ${r.statusCode}');
      return data;
    } on ApiError {
      rethrow;
    } catch (_) {
      throw ApiError('Serveur injoignable. Vérifiez la connexion.');
    }
  }

  static Future<void> saveToken(String? t) async {
    token = t;
    final p = await SharedPreferences.getInstance();
```
**État global.** La classe `AppState` hérite de `ChangeNotifier`. Les méthodes `refresh` et `auth` mettent à jour les listes et préviennent les écrans abonnés, qui se redessinent automatiquement.
```
  Future<void> refresh() async {
    tutors = await Api.call('GET', '/tutors');
    bookings = await Api.call('GET', '/bookings');
    messages = await Api.call('GET', '/messages');
    notifs = await Api.call('GET', '/notifications');
    notifyListeners();
  }

```
```
  Future<void> auth(bool register, Map<String, dynamic> body) async {
    final r = await Api.call('POST', register ? '/auth/register' : '/auth/login', body);
    await Api.saveToken(r['token']);
    await _boot();
    notifyListeners();
```
**Aides d’interface.** `live` reconstruit un morceau d’écran à chaque changement de l’état global, et `guard` exécute une action en affichant un message en cas d’erreur ; ces deux fonctions réduisent fortement la répétition dans les écrans.
```
Widget live(Widget Function() b) => ListenableBuilder(listenable: app, builder: (_, __) => b());
```
```
Future<void> guard(BuildContext c, Future<void> Function() f, [String? ok]) async {
  try {
    await f();
    if (ok != null && c.mounted) toast(c, ok);
  } catch (e) {
    if (c.mounted) toast(c, '$e');
  }
}
```
**Choix de conception.** Ce découpage sépare nettement trois responsabilités : l’accès au réseau (`api.dart`), l’état de l’application (`state.dart`) et la présentation (`screens.dart`). Il facilite les tests et l’évolution vers une bibliothèque de gestion d’état plus riche si le projet grandit.
### 4.13 Intégration, build et déploiement
Le projet se lance avec `npm install` puis `npm start`. La base est créée au premier démarrage à partir du schéma et des données de démonstration. Le comportement du serveur se règle par des variables d’environnement.
| Variable | Rôle | Valeur par défaut |
| PORT | Port d’écoute | 3000 |
| JWT_SECRET | Clé de signature des jetons, obligatoire en production | Valeur de développement |
| DB_FILE | Chemin du fichier SQLite | database/maak.db |
| CORS_ORIGIN | Origine autorisée pour les appels depuis un navigateur | * |
| NODE_ENV | Mode d’exécution | Non défini |
| API_URL (Flutter) | Adresse de l’API, passée avec --dart-define | Adresse de l’émulateur Android |
Le fichier `render.yaml` décrit le déploiement sur l’offre gratuite de Render. Le guide `DEPLOY.md` détaille la compilation de l’application Android, la publication et les limites de l’hébergement gratuit.
**Conclusion du chapitre.** La réalisation couvre les parcours essentiels des deux rôles et repose sur une API unique consommée par plusieurs clients.
## Chapitre 5 – Tests et validation
*Ce chapitre présente la démarche de validation : stratégie, environnement, scénarios fonctionnels, sécurité, performance et utilisabilité.*
### 5.1 Stratégie de test
La stratégie combine plusieurs niveaux : tests fonctionnels de l’API par scénarios, tests des droits d’accès, tests de sécurité, essais manuels de l’interface sur appareil et tests d’utilisabilité auprès d’utilisateurs. Les scénarios sont exécutés avec un outil de requêtes HTTP comme Postman ou curl, puis sur l’application mobile. Les résultats sont consignés dans les tableaux de ce chapitre.
### 5.2 Environnement de test
| Élément | Configuration |
| Serveur | Node.js 18 ou supérieur, base SQLite locale réinitialisée avant chaque campagne |
| Appareils mobiles | [à compléter : modèles et versions d’Android ou d’iOS] |
| Émulateur | [à compléter : version de Flutter et de l’émulateur] |
| Outils | Postman ou curl, outils de développement de Flutter |
### 5.3 Scénarios de test fonctionnels
Le tableau ci-dessous propose les scénarios à exécuter avec un outil comme Postman puis sur smartphone ; la dernière colonne est à renseigner avec vos résultats et captures.
| N° | Scénario | Résultat attendu | Résultat obtenu |
| T1 | Inscription avec un e-mail déjà utilisé | Erreur 409 | [à compléter] |
| T2 | Connexion avec un mauvais mot de passe | Erreur 401 | [à compléter] |
| T3 | Recherche par matière et ville | Seuls les tuteurs correspondants | [à compléter] |
| T4 | Réservation par un élève | Statut pending | [à compléter] |
| T5 | Confirmation par le tuteur concerné | Statut confirmed | [à compléter] |
| T6 | Confirmation par un autre utilisateur | Erreur 403 | [à compléter] |
| T7 | Avis sur une séance non terminée | Refus | [à compléter] |
| T8 | Avis après séance terminée | Note moyenne du tuteur mise à jour | [à compléter] |
| T9 | Saisie contenant du code HTML | Texte affiché sans exécution | [à compléter] |
| T10 | Plus de 20 connexions en une minute | Erreur 429 | [à compléter] |
| T11 | Application Flutter : connexion, puis redémarrage | Session conservée | [à compléter] |
| T12 | Application Flutter : serveur arrêté | Message d’erreur clair | [à compléter] |
| T13 | Application Flutter : réservation puis acceptation côté tuteur | Statut mis à jour après actualisation | [à compléter] |
### 5.4 Tests de sécurité
| N° | Test | Résultat attendu | Résultat obtenu |
| S1 | Appel de /api/bookings sans jeton | Erreur 401 | [à compléter] |
| S2 | Appel avec un jeton modifié | Erreur 401 | [à compléter] |
| S3 | Modification d’une réservation d’un autre utilisateur | Erreur 403 | [à compléter] |
| S4 | Saisie d’une injection SQL dans les champs de connexion | Aucune fuite, identifiants refusés | [à compléter] |
| S5 | Nom d’utilisateur contenant du code HTML | Texte affiché tel quel, sans exécution | [à compléter] |
| S6 | Inspection de la base | Mots de passe hachés | [à compléter] |
| S7 | Inspection des en-têtes de réponse | En-têtes de sécurité présents | [à compléter] |
### 5.5 Tests de performance
Un test léger de charge est prévu : mesure du temps de réponse de la liste des tuteurs et de la création de réservations avec plusieurs requêtes simultanées. *[Indiquer l’outil utilisé, le nombre de requêtes et les temps relevés.]*
### 5.6 Tests d’utilisabilité
L’utilisabilité est évaluée avec le questionnaire SUS (System Usability Scale), composé de dix affirmations notées de 1 (pas du tout d’accord) à 5 (tout à fait d’accord). Pour chaque réponse, on retire 1 à la note des items impairs et on soustrait la note de 5 pour les items pairs ; la somme est multipliée par 2,5 pour obtenir un score sur 100. Un score proche de 68 est généralement considéré comme moyen.
| N° | Affirmation |
| 1 | Je pense que j’utiliserais cette application fréquemment |
| 2 | Je trouve cette application inutilement complexe |
| 3 | Je trouve l’application facile à utiliser |
| 4 | Je pense avoir besoin de l’aide d’un technicien pour utiliser cette application |
| 5 | Les fonctions de l’application sont bien intégrées |
| 6 | Je trouve qu’il y a trop d’incohérences dans l’application |
| 7 | Je pense que la plupart des gens apprendraient très vite à utiliser cette application |
| 8 | Je trouve l’application très lourde à utiliser |
| 9 | Je me sens très confiant en utilisant l’application |
| 10 | J’ai dû apprendre beaucoup de choses avant de pouvoir utiliser l’application |
*[Indiquer le nombre de participants, leur profil et le score obtenu.]*
### 5.7 Critères d’acceptation
- Les parcours élève et tuteur principaux (inscription, recherche, réservation, confirmation, avis) fonctionnent de bout en bout.
- Aucun test de sécurité critique ne réussit à contourner les droits d’accès.
- Les messages d’erreur sont compréhensibles par un utilisateur non technique.
- Le score SUS atteint au moins la moyenne usuelle. *[Fixer vos seuils définitifs.]*
### 5.8 Matrice de traçabilité
La matrice relie les récits utilisateurs aux tests qui les couvrent. Les cases « à définir » signalent les tests encore à écrire.
| Récit | Tests associés |
| US1 – Créer un compte | T1 |
| US2 – Rester connecté | T2, T11 |
| US3 – Rechercher un tuteur | T3 |
| US4 – Filtrer et trier | T3 |
| US5 – Consulter profil et avis | T3, T8 |
| US6 – Réserver | T4, T13 |
| US7 – Annuler une séance | [à définir] |
| US8 – Écrire à un tuteur | [à définir] |
| US9 – Noter une séance | T7, T8 |
| US10 – Publier son profil | [à définir] |
| US11 – Gérer ses créneaux | [à définir] |
| US12 – Accepter ou refuser | T5, T6, T13 |
| US13 – Terminer une séance | T5 |
| US14 – Répondre aux messages | [à définir] |
| US15 – Notifications | [à définir] |
| US16 – Modération | Hors périmètre de la version actuelle |
### 5.9 Bilan des tests
*[À rédiger après exécution : anomalies trouvées, corrections apportées, points restant à traiter.]*
**Conclusion du chapitre.** La campagne de tests permet de vérifier la conformité aux besoins ; les résultats seront consignés dans les tableaux prévus.
## Chapitre 6 – Gestion de projet, modèle économique et risques
*Ce chapitre traite de la conduite du projet : planification, modèle économique, analyse stratégique, coûts et risques.*
### 6.1 Planification
Planning type à adapter à votre calendrier réel.
| Phase | Durée indicative | Livrable |
| Analyse et cahier des charges | 2 semaines | Besoins, cas d’utilisation |
| Conception | 2 semaines | Architecture, modèle de données, maquettes |
| Développement de l’API | 3 semaines | Routes, sécurité, base de données |
| Développement de l’interface | 3 semaines | Écrans élève et tuteur |
| Tests et corrections | 2 semaines | Rapport de tests |
| Rédaction du rapport | 2 semaines | Rapport et soutenance |
### 6.2 Méthode de travail et sprints
Le travail est organisé en itérations courtes, chacune livrant une fonctionnalité utilisable et testable. Cette organisation limite le risque de dérive et permet d’ajuster le périmètre en fonction du temps disponible. *[Adapter les dates à votre calendrier réel.]*
| Sprint | Durée | Objectifs | Livrables |
| S0 | 1 semaine | Cadrage, besoins, choix techniques | Cahier des charges |
| S1 | 2 semaines | Base de données et authentification | Schéma SQL, inscription, connexion |
| S2 | 2 semaines | Recherche et profils | Liste et fiche des tuteurs |
| S3 | 2 semaines | Réservations et statuts | Cycle de vie complet d’une réservation |
| S4 | 2 semaines | Messagerie et avis | Messages, notes, moyenne |
| S5 | 3 semaines | Application Flutter | Écrans élève et tuteur |
| S6 | 2 semaines | Notifications, créneaux, filtres | Centre de notifications, gestion des créneaux |
| S7 | 2 semaines | Tests, sécurité, déploiement | Rapport de tests, mise en ligne |
![Diagramme de Gantt prévisionnel|figures/gantt.png|560|202]
### 6.3 Modèle économique (hypothèses à valider)
- Commission prélevée sur chaque séance payée en ligne, à fixer après étude de marché.
- Mise en avant optionnelle des profils de tuteurs.
- Abonnement pour les centres ou établissements partenaires.
- Partenariats avec des facultés pour recruter et valoriser les tuteurs.
### 6.4 Analyse SWOT
| Catégorie | Éléments |
| Forces | Réponse à un besoin concret ; coût faible pour les familles ; application unique pour deux plateformes ; architecture simple et évolutive |
| Faiblesses | Équipe réduite ; pas de vérification automatique des étudiants ; base de données de prototype ; pas de paiement intégré |
| Opportunités | Forte demande de soutien avant les examens nationaux ; partenariats avec des facultés ; essor des paiements mobiles locaux |
| Menaces | Concurrence des groupes informels et des centres de soutien ; défiance envers les inconnus ; contraintes légales sur les données de mineurs |
### 6.5 Modèle d’affaires
| Bloc | Contenu |
| Segments de clientèle | Élèves du primaire au Baccalauréat et leurs parents ; étudiants souhaitant donner des cours |
| Proposition de valeur | Trouver un tuteur vérifié, comparer, réserver et échanger depuis le téléphone |
| Canaux | Application mobile, bouche-à-oreille, réseaux sociaux, partenariats avec des facultés et des établissements |
| Relation client | Avis, notifications, assistance par message |
| Sources de revenus | Commission sur les séances payées en ligne, profils mis en avant, abonnements partenaires *[à valider]* |
| Ressources clés | Plateforme technique, base de tuteurs, réputation |
| Activités clés | Développement, modération, animation de la communauté |
| Partenaires clés | Facultés, établissements scolaires, solutions de paiement locales |
| Structure de coûts | Hébergement, comptes de publication, maintenance, assistance |
### 6.6 Estimation des coûts
Les montants ci-dessous sont indicatifs et doivent être vérifiés au moment du lancement.
| Poste | Coût indicatif | Remarque |
| Compte développeur Google Play | 25 $, une seule fois | Test fermé obligatoire pour un compte personnel récent |
| Compte développeur Apple | 99 $ par an | Nécessaire pour l’App Store |
| API en démonstration | 0 | Offre gratuite avec mise en veille et base non persistante |
| API en production | À partir d’environ 14,5 $ par mois selon un exemple tarifaire de mi-2026 (service web et base PostgreSQL de base) | À vérifier chez l’hébergeur retenu |
| Nom de domaine | [à estimer] | Facultatif au départ |
| Temps de développement | Non facturé | Projet académique |
### 6.7 Risques et mesures
| Risque | Impact | Mesure |
| Faux profils ou tuteurs peu sérieux | Perte de confiance | Vérification de la carte d’étudiant, avis, signalement |
| Sécurité des mineurs | Élevé | Compte parent, séances en ligne ou en lieu public, modération |
| Faible adoption initiale | Moyen | Lancement par ville et par faculté partenaire |
| Paiement en ligne limité | Moyen | Paiement en espèces au départ, puis intégration D17 ou Flouci |
| Données personnelles | Élevé | Minimisation des données, HTTPS, conformité à la loi tunisienne sur la protection des données personnelles |
### 6.8 Difficultés rencontrées
Choix d’un périmètre réaliste pour un premier produit, modélisation du cycle de vie des réservations, conception d’une interface lisible sur petit écran, gestion des droits selon le rôle et protection contre les injections de code. *[Adapter à votre expérience.]*
### 6.9 Déploiement et mise en ligne
L’API peut être hébergée gratuitement pour la démonstration sur l’offre gratuite de Render (service qui s’endort après 15 minutes d’inactivité, système de fichiers éphémère : la base SQLite est recréée à chaque redémarrage). Une utilisation réelle exige une base persistante (PostgreSQL géré ou offre payante). Côté diffusion, Google Play demande des frais uniques de 25 $ et, pour un compte personnel récent, un test fermé de 12 testeurs pendant 14 jours ; l’App Store d’Apple coûte 99 $ par an. Des alternatives gratuites existent : APK partagé directement et version web Flutter (PWA) sur un hébergeur statique. La procédure complète figure dans le fichier `DEPLOY.md`.
**Conclusion du chapitre.** La maîtrise du périmètre et des risques conditionne le passage du prototype à un service en production.
## Chapitre 7 – Guide d’utilisation
*Ce chapitre est un guide pratique pour installer et utiliser l’application.*
### 7.1 Installation de l’API
- Installer Node.js (version 18 ou supérieure).
- Dans le dossier du projet, exécuter `npm install` puis `npm start`.
- Ouvrir http://localhost:3000 pour le client web ; l’API répond sur /api.
- Comptes de démonstration : eleve@maak.tn et tuteur@maak.tn, mot de passe demo123.
### 7.2 Installation de l’application mobile
- Installer Flutter, puis dans le dossier `mobile`, exécuter `flutter create . --project-name maak`.
- Exécuter `flutter pub get` puis `flutter run`. Avec un téléphone réel, ajouter `--dart-define=API_URL=http://ADRESSE_DU_PC:3000/api`.
- Sur Android, autoriser le trafic HTTP en développement (usesCleartextTraffic) ; en production, utiliser HTTPS.
### 7.3 Parcours de l’élève
- Créer un compte en choisissant le rôle « Élève » et sa ville, ou se connecter.
- Dans « Explorer », saisir une recherche, choisir une matière et une ville.
- Ouvrir la fiche d’un tuteur, consulter les avis, choisir un créneau et un lieu, puis réserver.
- Suivre la demande dans « Séances » ; annuler si nécessaire.
- Écrire au tuteur depuis sa fiche ; retrouver les échanges dans « Messages ».
- Une fois la séance terminée par le tuteur, laisser une note et un commentaire.
- Consulter l’onglet « Alertes » pour les confirmations et les messages.
### 7.4 Parcours du tuteur
- Créer un compte en choisissant le rôle « Étudiant tuteur ».
- Dans « Profil », renseigner le tarif, la présentation, les matières et les créneaux, puis enregistrer.
- Dans « Demandes », accepter ou refuser les nouvelles réservations.
- Après la séance, la marquer comme terminée pour permettre l’avis de l’élève.
- Répondre aux élèves dans « Messages » et suivre les « Alertes ».
### 7.5 Dépannage
| Symptôme | Cause probable | Solution |
| Message « Serveur injoignable » | L’API n’est pas lancée ou l’adresse est incorrecte | Démarrer l’API, vérifier API_URL |
| Connexion refusée sur Android | Trafic HTTP bloqué | Autoriser usesCleartextTraffic en développement |
| Données de démonstration réapparues | Base SQLite recréée (hébergement gratuit) | Utiliser une base persistante en production |
| Erreur 429 | Trop de tentatives de connexion | Attendre une minute |
**Conclusion du chapitre.** Ces procédures permettent à un nouvel utilisateur ou à un développeur de prendre en main le projet rapidement.
## Conclusion générale et perspectives
**Limites de la version actuelle :** pas de paiement en ligne ; notifications uniquement dans l’application (pas de notification push système) ; messagerie sans temps réel (actualisation toutes les 20 secondes) ; vérification des étudiants non implémentée ; l’application mobile doit encore être testée sur appareils réels.
**Perspectives :** vérification de la carte d’étudiant ; paiement local (D17, Flouci) ; notifications push ; messagerie temps réel (WebSocket) ; application installable (PWA) ou native ; interface en arabe ; visioconférence intégrée ; tableau de bord d’administration ; migration vers PostgreSQL et déploiement sécurisé en HTTPS.
### Feuille de route
| Horizon | Évolutions prévues |
| Court terme | Validation par un parent pour les élèves mineurs, signalement d’un profil, tests sur appareils réels |
| Moyen terme | Notifications push, messagerie temps réel, paiement local, vérification de la carte d’étudiant |
| Long terme | Version en arabe, visioconférence intégrée, tableau de bord d’administration, recommandations de tuteurs |
### Compétences acquises
| Domaine | Compétences mobilisées dans le projet |
| Analyse et conception | Recueil des besoins, personas, récits utilisateurs, diagrammes de cas d’utilisation et de séquence, modèle de données |
| Bases de données | Modélisation relationnelle, normalisation, requêtes SQL paramétrées, index et contraintes |
| Développement back-end | API REST avec Node.js et Express, authentification par jeton, gestion des erreurs |
| Développement mobile | Flutter et Dart, gestion d’état, navigation, appels réseau, thème clair et sombre |
| Sécurité | Hachage des mots de passe, contrôle des droits, protection contre l’injection SQL et le XSS, limitation de débit |
| Qualité | Plan de tests, tests de sécurité, évaluation de l’utilisabilité |
| Gestion de projet | Organisation en sprints, planification, analyse des risques et des coûts |
| Déploiement | Configuration d’un hébergement, variables d’environnement, publication d’une application Android |
| Compétences transversales | Autonomie, rédaction technique, veille technologique, respect des délais |
### Bilan du projet
MAAK propose une base fonctionnelle de plateforme de soutien scolaire adaptée au contexte tunisien : inscription, recherche, réservation, messagerie, avis et gestion des demandes reposent sur une API sécurisée et un schéma de données évolutif. Ce projet m’a permis de mettre en pratique la conception d’une application complète, de l’analyse des besoins à la réalisation, et ouvre la voie à une mise en production progressive.
## Glossaire
| Terme | Définition |
| API | Interface permettant à deux logiciels d’échanger des données |
| REST | Style d’architecture d’API fondé sur le protocole HTTP et des ressources identifiées par des adresses |
| JWT | Jeton signé contenant l’identité d’un utilisateur, utilisé pour l’authentifier |
| bcrypt | Algorithme de hachage de mots de passe |
| Hachage | Transformation irréversible d’une donnée en une empreinte |
| SQL | Langage d’interrogation des bases de données relationnelles |
| SQLite | Moteur de base de données relationnelle stocké dans un seul fichier |
| Flutter | Boîte à outils de Google pour créer des applications mobiles, web et bureau avec le langage Dart |
| Dart | Langage de programmation utilisé par Flutter |
| Widget | Élément d’interface dans Flutter |
| ChangeNotifier | Classe Flutter permettant de prévenir les écrans d’un changement d’état |
| PWA | Application web installable se comportant comme une application mobile |
| CORS | Mécanisme du navigateur contrôlant les appels entre domaines |
| XSS | Attaque consistant à injecter du code dans une page web |
| Injection SQL | Attaque consistant à glisser des instructions SQL dans une saisie |
| Interrogation périodique (polling) | Technique où le client demande régulièrement au serveur s’il y a du nouveau |
| Push | Notification envoyée par le serveur vers l’appareil sans demande préalable |
| MCD | Modèle conceptuel de données : représentation des entités et de leurs relations |
| SUS | Questionnaire standard de mesure de l’utilisabilité |
| Sprint | Itération courte d’une méthode agile |

## Bibliographie et webographie
- Windmill E., *Flutter in Action*, Manning, 2020.
- Documentation Flutter : https://docs.flutter.dev
- Documentation Dart : https://dart.dev
- Material Design 3 : https://m3.material.io
- Documentation Node.js : https://nodejs.org
- Documentation Express : https://expressjs.com
- Documentation SQLite : https://www.sqlite.org
- RFC 7519, JSON Web Token : https://www.rfc-editor.org/rfc/rfc7519
- OWASP Top 10 : https://owasp.org/www-project-top-ten/
## Annexe A – Schéma de la base de données
Script SQL complet de la base de données (fichier database/schema.sql).
[[CODE:/home/claude/maak/database/schema.sql|database/schema.sql]]
## Annexe B – Données de démonstration
Jeu de données chargé au premier démarrage (fichier database/seed.sql).
[[CODE:/home/claude/maak/database/seed.sql|database/seed.sql]]
## Annexe C – Code source de l’API
Fichier server/index.js : authentification, tuteurs, réservations, messages, avis, notifications.
[[CODE:/home/claude/maak/server/index.js|server/index.js]]
## Annexe D – Code source de l’application Flutter
Le code est réparti en quatre fichiers : point d’entrée, client HTTP, état global et écrans.
### Fichier lib/main.dart
[[CODE:/home/claude/maak/mobile/lib/main.dart|mobile/lib/main.dart]]
### Fichier lib/api.dart
[[CODE:/home/claude/maak/mobile/lib/api.dart|mobile/lib/api.dart]]
### Fichier lib/state.dart
[[CODE:/home/claude/maak/mobile/lib/state.dart|mobile/lib/state.dart]]
### Fichier lib/screens.dart
[[CODE:/home/claude/maak/mobile/lib/screens.dart|mobile/lib/screens.dart]]
## Annexe E – Guide de déploiement
Contenu du fichier DEPLOY.md.
[[CODE:/home/claude/maak/DEPLOY.md|DEPLOY.md]]
## Annexe F – Captures d’écran
*[À ajouter : captures des écrans principaux de l’application mobile, côtés élève et tuteur.]*
## Annexe G – Résultats détaillés des tests
*[À ajouter : tableaux de résultats, captures Postman, relevés de performance, résultats du questionnaire SUS.]*