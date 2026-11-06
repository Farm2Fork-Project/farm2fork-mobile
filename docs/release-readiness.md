# Mobile release readiness — 2026-10-29

## Changes
- Quality responses independently fail closed unless `needsReview` and `lowConfidence` are explicitly false, crop is supported, model trained, confidence >=0.7, grade is A/B/C, nullable reviewReason is explicitly present/null and photoSimilarity is finite in [-1,1]. Unsafe mapped results discard suggestedListingGrade. Widget independently gates Apply and hides raw grade/confidence recommendations on review; EN/Urdu offer retake/manual-grade recovery.
- Price consumes official_wholesale with positive ordered PKR ranges, exact requested unit, valid YYYY-MM-DD observed date, positive integer marketCount, required commodity/modelVersion/source/scope/predictionId and http(s) source URL without credentials. Historical observation/source/date/market/currency and wholesale/farm-gate/live distinction are shown in EN/Urdu. No confidence is manufactured. Farmer explicitly applies midpoint or enters their own price. Missing/unsupported data has manual-price recovery; offline mocks do not fabricate official observations. Input changes invalidate current/pending suggestions.
- Four auth analyzer warnings were real async catch bugs: awaited the three `_requireIdToken` futures and refresh token future within their FirebaseAuthException catch blocks. Async token-failure tests cover Google sign-in, email login, registration and refresh.
- Android release now requires actual `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`) or `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Missing fields/file fail clearly; debug signing remains solely debug. Existing maps guard retained; signing credentials are already ignored by android/.gitignore.

## Proof
- Red regression reproduced: old mapper recommended A when needsReview was absent.
- Focused widget/repository tests cover review/raw-grade/Apply safety, missing flags, untrained/low confidence/unsupported/D, missing/invalid similarity, official provenance, manual recovery, and photo replacement/in-flight invalidation. Final execution receipts below.
- First full suite: 304 passed, 2 skipped. First analyzer: no issues. Strengthened safety matrix and final run tracked separately below.
- Android debug build succeeded: build/app/outputs/flutter-apk/app-debug.apk.
- Android release preflight intentionally failed: missing MAPS_API_KEY and missing real release signing configuration; both diagnostics emitted. No signed release artifact or credential validity claimed.

## Native/config audit and release gates
- Android namespace/application ID is existing com.farm2fork.app; iOS existing bundle ID com.farm2fork.app and existing team C3ZMVSNLSA preserved, not independently authenticated or invented. Real signing identity/provisioning and store ownership remain operator validation.
- Firebase config files exist for Android/iOS; presence does not prove Firebase project access, production OAuth certificate fingerprints, APNs credential setup, or real login/push delivery. Android release certificate SHA fingerprints must be registered for Google/Firebase auth.
- Android declares Internet, foreground fine/coarse location, notification, vibration and optional camera; no background location permission. iOS has camera/photo/location usage descriptions and remote-notification background mode. Real camera/GPS/push permission flows remain physical-device acceptance.
- Existing maps configuration guards/fallbacks preserved. Provide restricted native Maps keys. No real map/network/device validation claimed.
- API_BASE_URL still defaults to local Android-emulator HTTP. Distribution MUST pass the actual HTTPS API URL; a default build is not production API configuration. USE_MOCKS and PAYMENT_SIMULATOR_ENABLED default false. PUBLIC_TRACE_ORIGIN/TRACE_LINK_HOST must match web/backend and deployed association files with real signing certificate/team identity. These values and identities were not fabricated.
- iOS release entitlement uses production APNs and associated domain; debug uses development APNs. Simulator build cannot validate distribution signing, APNs delivery or associated-domain authorization.
- No server access, deployment, payment execution, field-accuracy claim, commit or push performed. Existing dirty maps/QR/native/order/shipment/localization changes preserved.

## Final verification receipts
- `flutter test`: **306 passed, 2 skipped**, all tests passed (42 seconds); includes the strengthened missing similarity/reason safety matrix and auth regressions.
- `flutter analyze`: **No issues found** (14.6 seconds); all four original async warnings resolved.
- `git diff --check`: clean.
- `flutter build ios --simulator --debug`: succeeded, Runner.app (Xcode 86.4 seconds); warns google_maps_flutter_ios lacks Swift Package Manager support, currently supported via existing integration. This is a future tooling migration concern, not a failed build.
- Final incremental native rebuilds on the final runtime source: Android debug APK succeeded (15.6 seconds), iOS simulator Runner.app succeeded (27.5 seconds).
- Added fourth Google ID-token failure regression after the full suite: focused auth suite **4 passed**. This added test does not change runtime source. Final analyzer repeated: no issues.

## Final source review follow-up
- Reproduced three adversarial red groups before fixing: mismatching/missing crop, nonfinite/>1 confidence and suggested/model grade mismatch; direct-model invalid confidence/grade mismatch; future wholesale observations.
- Mapper now requires response crop equal the requested crop, finite confidence in [0.7,1], and suggestedListingGrade equal modelGrade. QualityCheck independently enforces finite confidence <=1 and matching grades. Price rejects observedOn later than current UTC date.
- Follow-up `flutter test test/ai`: **20 passed**. `flutter analyze`: **No issues found**. `git diff --check`: clean. Earlier full-suite/native receipts precede this narrow guard-only follow-up; no native settings changed.

## Distribution configuration command and runtime gate
- Added `python3 scripts/build_release.py android|ios [--preflight-only]`, documented in mobile README. Requires explicit HTTPS API/public trace configuration, matching native trace host and disabled mock/payment simulator. Android environment-only path requires actual keystore fields/file and Maps key; conflicting key.properties is rejected to avoid silent local credential precedence. iOS checks effective literal native host and Maps configuration; genuine Xcode signing remains external.
- `main()` now invokes pure AppConfig release validation before bootstrap only in release mode. Direct release builds without explicit API/trace Dart defines fail at startup rather than shipping a silently local/mock backend. Debug defaults preserved.
- Red run failed for absent validator; green Dart validator suite **4 passed** and Python preflight suite **4 passed**. Analyzer **no issues** (10.2 seconds), diff-check clean. Missing-environment Android preflight exits 2 with field-name diagnostics and no credentials printed. No distribution build/signing attempted in this follow-up.

## Resumed final verification — 2026-11-06

The final full suite before interruption passed **313 tests, 2 skipped**. The subsequent analyzer is clean (8.3s), and Android debug APK rebuilt successfully (48.5s). Durable receipts are `mobile-analyze.log`, `android-build.log` and `ios-build.log` beside this report. Signed release builds remain gated on the documented operator configuration.

Final iOS simulator build succeeded on 2026-11-06: Runner.app, Xcode152.8s. The existing google_maps_flutter_ios Swift Package Manager adoption warning remains nonblocking with the current Flutter toolchain; native signed/device acceptance remains separate.
