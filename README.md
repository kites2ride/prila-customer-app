# Prila (Customer)

Flutter app for riders. App ID: `com.prila.customer`. Languages: EN + TE. **Production config only** (no staging/dev flavors yet).

```bash
flutter pub get
flutter run --dart-define-from-file=env/prod.json
flutter analyze
```

Place shared Firebase `google-services.json` / `GoogleService-Info.plist` when ready (do not commit).
