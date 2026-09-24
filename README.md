# farm2fork_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running against the backend

```bash
# Android emulator, backend from farm2fork-backend/docker-compose.local.yml
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002/api \
            --dart-define=PAYMENT_SIMULATOR_ENABLED=true
# In-memory data, no backend:
flutter run --dart-define=USE_MOCKS=true
```

See `farm2fork-backend/docs/TESTING.md` for the whole-flow test script.

## Google Maps key

Farm pins, the checkout drop-off pin and the transporter maps use the Maps SDK
for Android/iOS. The key is never committed:

1. In Google Cloud, enable **Maps SDK for Android** (and **Maps SDK for iOS**
   for iOS builds) and create an API key restricted to the app's package name
   `com.farm2fork.app` and your signing certificate's SHA-1.
2. Android: add `MAPS_API_KEY=your-key` to `android/local.properties`
   (git-ignored), or export `MAPS_API_KEY` in CI.
3. iOS: create `ios/Flutter/Secrets.xcconfig` (git-ignored) containing
   `MAPS_API_KEY=your-key`.

Without a key the app still runs, but maps render blank. Turn-by-turn
navigation opens the Google Maps app, which needs no key.

## Location and notifications

- Location is **foreground only**: transporters share it while they are
  online with the app open, farmers and buyers use it to pin a spot. No
  background location permission is requested.
- Push notifications use Firebase Cloud Messaging. Android 13+ asks for the
  notification permission after sign-in; the device token is registered with
  the backend and cleared on sign-out.
