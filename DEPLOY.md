# Déployer MAAK

L'application Flutter Android/iOS est le produit principal. Le client HTML/CSS/JS servi à la racine de l'API reste une expérience web secondaire et de démonstration.

## 1. Préparer et héberger l'API

Déployer l'API avant de compiler l'application mobile : l'appareil doit joindre une URL HTTPS publique.

Le fichier `render.yaml` configure un service Render gratuit pour une démonstration :
1. Publier le projet sur GitHub puis choisir **New → Blueprint** dans Render.
2. Définir `JWT_SECRET` (Render le génère avec le blueprint) et noter l'URL de l'API, par exemple `https://maak-api.onrender.com`.
3. Vérifier `https://maak-api.onrender.com/api/tutors`.

**Cette configuration n'est pas adaptée aux vrais utilisateurs.** L'offre gratuite peut mettre le service en veille et son disque local est éphémère : la base SQLite peut être perdue au redémarrage ou au redéploiement. Pour une mise en production, utiliser une base persistante (par exemple PostgreSQL géré), configurer et tester les sauvegardes, et définir `CORS_ORIGIN` pour le domaine du client web si celui-ci est hébergé séparément. Les clients mobiles natifs n'utilisent pas CORS.

## 2. Publier le site sur Firebase Hosting

Le site vitrine est `public/index.html`; l'application web existante reste accessible sur `/app.html`. Le projet Firebase doit avoir l'identifiant `maak` pour utiliser l'adresse `https://maak.web.app` configurée dans `.firebaserc`.

1. Créer ou sélectionner le projet Firebase `maak` dans la console Firebase et activer Hosting.
2. Installer Firebase CLI, puis depuis la racine du dépôt exécuter :

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only hosting
```

Le client web appelle l'API Render à `https://maak-api.onrender.com/api` depuis `maak.web.app`. Si Render fournit une autre URL, modifier `API_BASE` dans `public/app.html` avant le déploiement. Pour limiter les origines web autorisées, configurer `CORS_ORIGIN=https://maak.web.app` dans Render.

## 3. Générer les projets de plateforme Flutter

Le dépôt contient le code Dart et `pubspec.yaml`, mais pas les projets natifs Android/iOS. Installer Flutter (3.22 ou ultérieur), puis, une seule fois depuis `mobile/` :

```powershell
flutter create . --platforms=android,ios --project-name maak --org tn.maak
flutter pub get
```

Cette commande génère `android/` et `ios/` en conservant `lib/`. Vérifier ensuite les identifiants d'application avant de publier.

## 4. Compiler l'application Android

Utiliser l'URL HTTPS de l'API :

```powershell
cd mobile
flutter build apk --release --dart-define=API_URL=https://maak-api.onrender.com/api
flutter build appbundle --release --dart-define=API_URL=https://maak-api.onrender.com/api
```

L'APK (`build/app/outputs/flutter-apk/app-release.apk`) peut être distribué directement ; le bundle (`build/app/outputs/bundle/release/app-release.aab`) est destiné à Google Play. Pour rendre l'APK téléchargeable depuis le site, copier l'APK dans `public/downloads/maak.apk`, puis exécuter `firebase deploy --only hosting`. Le bouton de téléchargement du site reste désactivé tant que ce fichier n'est pas publié. Pour Google Play, configurer une clé de signature dans `android/key.properties` et Gradle (guide officiel Flutter), modifier l'identifiant `tn.maak.maak`, puis préparer l'icône, les captures, la politique de confidentialité et le formulaire « Sécurité des données ». La publication Play implique des frais et peut exiger un test fermé selon le type et l'ancienneté du compte développeur.

## 5. Compiler l'application iOS

Sur macOS avec Xcode et les certificats/profils Apple configurés :

```powershell
cd mobile
flutter build ipa --release --dart-define=API_URL=https://maak-api.onrender.com/api
```

Le build iOS ne peut pas être produit depuis Windows. La distribution via l'App Store nécessite un compte Apple Developer et la configuration de la signature.

## 6. Client Flutter Web (facultatif)

Le client HTML/CSS/JS existant est servi par l'API. Pour compiler la version Flutter Web à la place :

```powershell
cd mobile
flutter build web --release --dart-define=API_URL=https://maak-api.onrender.com/api
```

Publier `build/web` sur un hébergeur statique et restreindre `CORS_ORIGIN` au domaine web. Le déploiement web est facultatif et ne remplace pas l'application mobile principale.

## 7. Avant toute mise en production

Configurer une base persistante et ses sauvegardes, rédiger la politique de confidentialité et les conditions d'utilisation (notamment pour les données de mineurs), définir la vérification des tuteurs, tester les applications sur de vrais appareils et décider du service de notifications push (Firebase Cloud Messaging).
