# Mobile Safepay checkout and return

Buyer checkout and pending Orders open the existing order's Payment screen.
The initial screen load, browser resume and return link only read persisted
payment status. An explicit Continue/Retry action calls `POST /payments` with
`gateway: safepay` and `client: mobile`, then opens the hosted URL using
`url_launcher` in the external browser. Retry uses the same order ID.

The repository accepts both the initiation envelope `{ payment, checkoutUrl }`
and the bare payment DTO returned by `GET /payments/:id`. Cold-start recovery
searches the authenticated, paginated payment list for the requested order.
Status-read failures discard cached status and show a retryable error.
Only HTTPS checkout URLs on `sandbox.api.getsafepay.com` or `getsafepay.com`
are launchable. Missing links and failed launches show localized EN/UR errors.
Safepay never invokes the local payment simulator.

## Return contract

Keep the backend's existing deployed web-origin configuration:

```dotenv
SAFEPAY_REDIRECT_URL=https://your-web-origin/order/complete
SAFEPAY_CANCEL_URL=https://your-web-origin/order/cancel
```

The backend appends `mobileOrderId` only when `client: mobile` is supplied.
The web return pages validate the order ID and offer an Open app link:

```text
farm2fork://app/payments?orderId=<existing-order-id>&result=complete
farm2fork://app/payments?orderId=<existing-order-id>&result=cancel
```

Android and iOS register this scheme. A cold-start or resumed authenticated
buyer reads backend payment status; `result` changes explanatory copy only.
A forged `status=success` never marks a payment paid. Logged-out users follow
the existing auth guard and can resume through Orders after signing in.
Normal web returns and invalid mobile markers retain the web Orders redirect.
No custom app URL needs to be accepted by Safepay itself.

## Automated verification

From `farm2fork-mobile`:

```sh
flutter test --no-pub
flutter analyze lib/features/payments lib/features/orders/presentation/screens/orders_screen.dart lib/app/router.dart test/payments
flutter build apk --debug --no-pub
flutter build ios --simulator --debug --no-codesign
```

From `farm2fork-backend`:

```sh
pnpm exec ts-node --compiler-options '{"rootDir":"."}' scripts/test/web-checkout-e2e.ts --mobile
pnpm exec jest --runInBand src/modules/payment/mobile-checkout-return.spec.ts src/modules/payment/payment.service.spec.ts
pnpm exec jest --config test/jest-e2e.json --runInBand
pnpm exec tsc -p tsconfig.build.json --noEmit --rootDir .
```

The live mobile harness starts disposable MongoDB transactions and real Nest
HTTP/JWT/role/CSRF handling, with local HTTP fixtures for Safepay tracker/passport
responses. It runs the real Dart repository/controller against that backend.
It verifies two farmer orders, server totals, initial reads without initiation,
hosted return destinations, status refresh, intentional resume, ownership
rejection, signed success/replay, failure/retry, cold-start recovery and depleted
stock. It ends with exactly two paid orders, two successful payments and two
outbox records. It does not deliver those records to a live Fabric network.

Verified on 2026-10-11: full mobile suite 102 passed, two live tests skipped
without harness configuration; mobile checkout harness passed separately.
Payment screen/launcher tests cover browser resume and launch failures in EN/UR.
The real router test rejects forged success status. Scoped analysis passes;
whole-app analysis retains four existing Firebase auth warnings. Backend payment
unit tests: 22 passed; HTTP integration: four suites, 15 passed. Backend production
source/harness checking passes with the command above; the default broad config
still includes scripts outside rootDir and test files with typing errors.
Web: 77 passed, two live tests skipped, live checkout harness passed separately,
TypeScript/build passed; built return routes passed HTTP handoff/redirect checks.

Android debug APK and iOS Simulator builds passed. The SDK-generated iOS SwiftPM package lock is
retained to pin the resolved native dependencies. Flutter migrated the project
minimum iOS target from 13 to 15, matching the already installed
`firebase_core 4.13.0` Swift package requirement. The resolved url_launcher
packages require Flutter 3.44 or later.

## Runtime verification still required

Test the merchant's real Safepay sandbox checkout and actual callback payloads,
Firebase login/session acquisition, signed-in browser-to-app handoff on Android
and iOS, EN/UR phone visuals, and live Fabric delivery. The automated harness
uses seeded JWT identities and synthetic signed callbacks. It cannot prove
provider acceptance of return URL query parameters or native browser handoff.
The backend's original Safepay implementation remains pre-existing uncommitted
work; this flow adds the mobile client marker without replacing that work.
