# MAAK – application mobile Flutter
Application principale de MAAK, cliente mobile Flutter de l'API (dossier `../server`). Fonctions : inscription/connexion, recherche et filtres, profil tuteur et avis, réservation, annulation, messagerie, avis après séance et notifications intégrées. Côté tuteur : demandes, clôture des séances, messagerie, profil et gestion des disponibilités.

## Lancer
1. Depuis la racine du projet, démarrer l'API avec `npm install` puis `npm start` (port 3000). La laisser tourner dans ce terminal.
2. Dans un second terminal, ouvrir `mobile/` et installer Flutter (≥ 3.22). Si les dossiers de plateforme ne sont pas présents, les générer une seule fois depuis ce dossier. Cette commande crée `android/` et `ios/` sans remplacer `lib/` :
```
flutter create . --platforms=android,ios --project-name maak --org tn.maak
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api   # émulateur Android
flutter run --dart-define=API_URL=http://IP_DU_PC:3000/api   # téléphone réel, même Wi-Fi
```
Pour l'émulateur iOS, utiliser une URL de développement joignable par le simulateur et autoriser HTTP uniquement dans la configuration de développement iOS si nécessaire. Android : pour HTTP en développement uniquement, ajouter `android:usesCleartextTraffic="true"` à `<application>` dans `android/app/src/main/AndroidManifest.xml`. En production, utiliser HTTPS.

Comptes démo : `eleve@maak.tn` / `tuteur@maak.tn` (mot de passe `demo123`).

## Structure
`lib/main.dart` (thème Material 3, aiguillage selon le rôle) · `lib/api.dart` (client HTTP + jeton) · `lib/state.dart` (état global `ChangeNotifier`) · `lib/screens.dart` (écrans). Le site web à la racine est un client secondaire de l'API.
