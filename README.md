# MAAK – Soutien scolaire entre élèves et étudiants tuteurs (Tunisie)
Application full-stack MAAK, avec une API REST Node.js/Express, une base SQLite, une application mobile Flutter et un site vitrine hébergé par Firebase Hosting.

## Applications
Le client Flutter Android/iOS est dans `mobile/` (voir `mobile/README.md`). Il propose les espaces élève et tuteur, notamment la recherche, les réservations, les messages, les notifications intégrées et la gestion du profil et des disponibilités.

Le site public (`public/index.html`) présente MAAK et renvoie vers l'application web (`public/app.html`). Il inclut aussi un bouton de téléchargement Android qui s'active lorsque `public/downloads/maak.apk` est présent. Voir `DEPLOY.md` pour publier le site et préparer l'APK.

## Lancer
```
npm install
npm start        # API et site : http://localhost:3000
npm test         # tests d'intégration API
```
Variables : `PORT`, `JWT_SECRET` (à changer en production), `DB_FILE`. La base est créée au premier démarrage (`database/schema.sql` + `seed.sql`). Supprimez `database/maak.db` pour la réinitialiser.

Comptes démo (mot de passe `demo123`) : élève `eleve@maak.tn`, tuteur `tuteur@maak.tn`.

## API (JWT : en-tête `Authorization: Bearer <token>`)
| Méthode | Route | Rôle |
|---|---|---|
| POST | /api/auth/register, /api/auth/login | public |
| GET | /api/tutors?subject=&level=&city=&q= | public |
| PUT | /api/tutor/profile | tuteur |
| POST | /api/bookings | élève |
| GET | /api/bookings | élève / tuteur |
| PATCH | /api/bookings/:id (confirmed, declined, done, cancelled) | tuteur / élève |
| GET, POST | /api/messages | connecté |
| POST | /api/reviews | élève (séance terminée) |
| GET | /api/me | connecté |
| GET | /api/tutors/:id/reviews | public |

## Limites actuelles
Pas de paiement ni de notifications push système ; les messages et notifications intégrées sont actualisés périodiquement. La vérification des tuteurs reste manuelle et les conditions de mise en production (base persistante, politique de confidentialité et tests sur appareils réels) restent à traiter. Le client web est secondaire ; voir `DEPLOY.md` pour le déploiement mobile.
