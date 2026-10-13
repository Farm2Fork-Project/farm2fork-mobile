# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-10-11. The earlier maturity snapshot and slice entries below are historical; see the dated verification entry at the end for this change.

---

## Repo maturity snapshot

| Repo | State | Notes |
|------|-------|-------|
| **farm2fork-backend** (Nest.js) | `develop` contains Auth + Profiles + 17 schemas + **Marketplace** + **Orders** + persisted payment initiation/read/refund/simulated settlement + Fabric outbox lease coverage + complete Swagger contract annotations | Loan/community/notification/ai are otherwise schema-only scaffolds; real gateway callbacks remain intentionally unimplemented |
| **farm2fork-mobile** (Flutter) | `develop` contains the network layer + Marketplace + **Checkout** + buyer payment status + shipment self-claim/tracking flow; `feature/firebase-auth` adds Firebase sign-in/onboarding | Firebase/FCM work is not yet merged; real gateway polling, notifications, and loans are not built |
| **farm2fork-web** (Next.js) | `develop` contains buyer login/registration, marketplace/product detail, farmer-grouped cart/checkout, orders/payment/shipment-status views, transporter self-claim and tracked delivery transitions, farmer/transporter onboarding, and farmer product creation; standalone Docker runtime is defined | Browser/user-flow smoke remains open; temporary `sessionStorage` token is not the final session security model |
| **farm2fork-blockchain** (Fabric/Go) | Local Fabric network and immutable payment/product shipment records, with a verified backend Gateway/outbox integration | Network is local-development only; production Fabric operations and traceability UI are not built |
| **farm2fork-ai** (Python ML pipeline) | Dataset manifests, multi-task EfficientNet model, training/evaluation scripts, and 9 test modules exist | No FastAPI service code, generated manifests, trained checkpoint, or deployed inference API |

---

## Slices completed (merged to `develop`)

### Slice 1 — Marketplace (real `/products`)
- **Backend** (PRs #1, #2): real Mongoose `MarketplaceService` — create + QR PNG, search/filter/sort/pagination, ownership 403s, soft-delete. 8-case spec.
- **Mobile** (PR #1): built the missing `lib/core/network` Dio layer (client, Auth/Locale/Error interceptors, secure token storage, typed `ApiException`, `AppConfig` with `USE_MOCKS` toggle). Wired marketplace to `/products` via an adapter repo. 9-case adapter spec.
- **Known gap:** `/products` returns only `farmerId`, no embedded farmer detail → mobile synthesises an empty `FarmerSummary` stub. Resolve when a profiles endpoint exists.

### Slice 2 — Orders (real `/orders`, one-order-one-farmer)
- **Backend** (PR #4): real `OrderService` — **enforces One-Order-One-Farmer** (product lookup, mixed-farmer → 400), price snapshot from DB, stock/inactive/missing/duplicate validation (stock validated, **not** decremented — deferred to payment), role-scoped `findAll`/`findOne`/`cancel`. New **`SystemConfigService`** reads `platform_fee_percent` (fallback 5%). 50/50 tests.
- **Backend** (PR #3, earlier): merged the order/payment API contracts (resolved a conflict from branching before marketplace merged).
- **Mobile** (PR #2): farmer-grouped **checkout flow** → `POST /orders` (one order per farmer group, partial-success retry). `CheckoutScreen` + `CheckoutController`, orders API repo, `/checkout?farmerId=` route, EN+UR localization. 55/55 tests.

---

## Already done by the team (do NOT rebuild)
- **Auth** (backend): register farmer/buyer/transporter, login, JWT, verify-email, password-reset, `/auth/me`. bcrypt, duplicate checks.
- **Profiles** (backend): all 5 profile schemas; farmer/buyer/transporter profiles created at registration.
- **All 17 Mongoose schemas** — real, rule-compliant (`initialBlockchainRecordId`, exact role enums).

---

## Active slices and remaining validation

**Slice 3 — Local runtime, simulated payment, and Fabric persistence.**

- **Runtime** — backend `develop`: `e0f1aef` removes Compose `env_file`, requires `DATABASE_URL` for Atlas, and runs local Redis only. `docker compose --env-file .env.example config` passed. No Atlas-backed `docker compose up` was run because only placeholder credentials are available.
- **Backend payment write/read/refund path** — `15f585a`, `f8355f6`, `4b87ae3`, `021aa91`, `ccf4f00`, `07b5dca`: buyer-owned pending orders create/reuse a persisted payment whose amount comes from `Order.grandTotal`; buyer/admin list and individual reads are database-backed and ownership-scoped; admin refunds persist without restocking inventory. The guarded local simulator settles success idempotently in a MongoDB transaction, decrements stock once, marks zero stock `sold_out`, sets the order `paid`, and creates one pending blockchain outbox record. A public webhook now returns 501 until a real provider signature design exists. `pnpm run build`, `pnpm test` (64 tests), and `pnpm test:e2e --runInBand` (2 tests) passed.
- **Fabric backend integration** — backend `develop`: `2ecd364`, `7af5659`, `a253b97`, `3d30a29`, `a1c45b5`, `5d83198`, `d811162`, `16d3ff5` add the Fabric Gateway client, durable leased outbox worker, per-product shipment-event fan-out, an isolated Docker worker, and replica-set outbox lease coverage. The worker configuration is namespaced correctly, defaults align with the deployed `farm2fork-chaincode`, and submissions target `Farm2ForkMSP` explicitly. The e2e cases prove that one of two concurrent workers claims/submits an eligible record and that an existing immutable ledger key confirms without resubmission. An approved Atlas/Fabric synthetic payment smoke was confirmed in Atlas and independently read back from Fabric; no production order, payment, shipment, or product was used.
- **Mobile flow** — mobile `develop`: `be0ff8f`, `5574a6e`, `025b460`, `9d85daf` add typed payment API/mock repositories, a payment controller, a localized buyer status screen, checkout-to-payment navigation, and a persisted payment-status adapter. The test-completion action is visible only in mock mode or with `PAYMENT_SIMULATOR_ENABLED=true`; normal API builds create a pending payment and do not call the simulator. `flutter analyze` and `flutter test` passed (60 tests).
- **Still open in this slice** — real JazzCash/Stripe and provider signature validation; mobile polling after a real-gateway redirect; a normal payment/shipment-flow Fabric smoke; automatic refund restocking. The full backend e2e suite remains unverified because its Jest runtime currently conflicts with the Fabric SDK's ESM dependency path.

**Slice 4 — Shipment self-claim and tracking (implementation complete; live smoke pending).**

- **Backend** — `develop`: `3d5600f`, `5300e4c`, `82a2da7`, `7af5659` add a privacy-preserving paid/unclaimed delivery list; an atomic first-claim transaction that creates the assigned shipment, updates the order, and writes one typed supply-chain outbox record per distinct product; role-scoped shipment reads; and guarded transporter transitions (`assigned → picked_up → in_transit → delivered`, with terminal failure). The replica-set e2e test proves one concurrent claimant wins and duplicate-key conflicts return 409. Fresh `pnpm run build` and `pnpm test` passed on the merged branch (**85 tests**); the full e2e suite still has the Fabric SDK ESM/Jest limitation.
- **Mobile data and transporter flow** — `develop`: `62edbe5`, `769b59a`, `5418f22`, `6d87f9a` add typed real/mock shipment repositories, redacted available-delivery cards, atomic claim UI, a read-only `/shipments/:id` tracking route, buyer/farmer order-card entry when `shipmentId` exists, and complete EN/UR shipment-screen copy. The real client sends only `orderId` to claim and only `{status, note}` to transition. `flutter test test/shipments` (**5 tests**) and `flutter analyze` passed.
- **Web transporter and buyer flow** — web `develop`: `ae39b4d`, `dcf63a0`, `8ed9bf1`, `b1f6b8f`, `ed2c3a8` replace seeded transporter shipments with privacy-preserving available deliveries, atomic `{ orderId }` claims, server-owned full routes after claim, required-note delivery transitions, status-history timelines, and claim/update conflict regression coverage. Buyer real orders load scoped shipments and join only matching `orderId` records; no farmer mock order data was connected. `CI=true pnpm test` passed (**16 files, 32 tests**), `CI=true pnpm run build` passed, and `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api docker compose build` passed.
- **Still open before this slice is complete** — run full `flutter test`; user-owned browser/physical-device smoke checks; a normal payment/shipment-flow Fabric smoke. Maps/GPS, notifications, bids/fees, buyer offer selection, proof of delivery, and reassignment remain deferred.

**Slice 5 — Web buyer API integration (implementation complete on `develop`).**

- **Web buyer path** — web `develop`: `455632f`, `44cacce`, `e213c04`, `cd28264`, `ba4de79`, `1e2f489`, `bce5220`, `847dfc0`, `3d8f5af`, `30e3cf0`, `51fd82b`, `8b081ac`, `b9d4530`, `3f8dee5`, `f189267` add exact backend DTO contracts and product mapping without fabricated farmer data; a versioned `sessionStorage` buyer session; buyer registration/login; live marketplace, farmer-grouped checkout, orders and payment statuses; real farmer/transporter onboarding; and farmer product creation. `pnpm test` passed (**14 tests**) and `pnpm run build` passed with the standalone Next output.
- **Web Docker runtime** — the web `Dockerfile`, Compose definition, `.dockerignore`, and runtime documentation use an explicitly required `NEXT_PUBLIC_API_BASE_URL`, build the standalone Next server, expose web on port `3001`, and do not use `env_file` or carry secrets into the image. `bce5220` adds a BuildKit-only pnpm-store cache, a lockfile-only fetch with bounded longer retries, and an offline frozen-lockfile install. This preserves partial registry downloads across build attempts and keeps the cache out of the final image. `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api docker compose config` passed; a full image build completed, and `f2f-web` served `GET /` with HTTP **200** on `localhost:3001` after startup. The first request immediately after `docker compose up -d` reset during startup; container logs showed Next ready and the second request confirmed the runtime. Backend Compose must set `CORS_ORIGIN=http://localhost:3001` for this runtime.
- **Backend Swagger contract** — backend `develop`: `78203c0` moves document construction into a testable factory and annotates all current health, auth, marketplace, order, payment, and shipment endpoints with success, authentication/authorization, validation, not-found/conflict, and current `501` webhook responses. The generated OpenAPI contract test covers every route, verifies the public webhook does not require bearer auth, and confirms that the unsupported gateway callback is not advertised as successful. Fresh `nest build` and the complete unit suite passed after integration.
- **Still open in this slice** — user-owned browser/device smoke checks against a live backend, including new buyer registration followed by login, marketplace, multi-farmer checkout, and pending-payment visibility. Full repository lint still reports pre-existing errors outside the changed buyer path; scoped lint of the buyer changes is clean. The security target remains HTTP-only cookie sessions, not the temporary `sessionStorage` token used for this first integration model.

**Slice 6 — Firebase authentication migration (feature branches; implementation complete, integration pending).**

- **Backend Firebase boundary** — `feature/firebase-auth`: `c0db388`, `f0dfdef`, `d1f5d62`, `d70b545` add Firebase Admin initialization from externally supplied credentials, verified ID-token sign-in, first-time farmer/buyer/transporter onboarding, `firebaseUid` and provider linkage, Swagger contract coverage, and a strict verified-email requirement before a legacy email-matched account can be linked. Backend roles, backend-issued JWTs, JWT guards, and KYC profile ownership remain authoritative. Legacy password/reset endpoints are intentionally retained until every client migrates. `CI=true pnpm run build` and the complete Jest suite passed (**12 suites, 92 tests**).
- **Mobile Firebase flow** — `feature/firebase-auth`: `f225e89`, `8655c13`, `fb8cc9f`, `f31815a`, `af2cdcd`, `38711a3` initialize Firebase natively, use Firebase Google or email/password credentials, exchange the ID token for the backend JWT, securely persist that JWT, and provide self-service farmer/buyer/transporter onboarding. Standard Android-emulator builds now use `http://10.0.2.2:3000/api` and the real repository by default; mocks require `--dart-define=USE_MOCKS=true`. The repository correctly handles the `DioException(error: ApiException)` shape for onboarding-required (409) and stale sessions (401). Payment tests now request simulated settlement explicitly rather than relying on mock mode. `flutter analyze` passed and the complete suite passed (**78 tests**).
- **Still open before integration** — Firebase runtime configuration must enable `FIREBASE_AUTH_ENABLED` and point to the external service-account key; no secret was copied or inspected. User-owned Android/iOS Firebase account smoke remains open. Web Firebase auth with an HTTP-only backend cookie is next; FCM tokens, notification delivery, admin/financial allowlisting UI, and retirement of legacy credential/Redis flows remain deferred.

Next after Firebase branch integration: **web Firebase sign-in + HTTP-only backend-cookie session → FCM token/notification delivery → Loans → Community → AI predictions → blockchain traceability screens**. The backend-to-Fabric foundation is now in place; the later traceability screens still need web/mobile API integration.

Backlog item to slot in: a **profiles endpoint** so the marketplace farmer-detail stub can be replaced with real farm name/location/rating.

---

## Engineering workflow and environment notes
- `pnpm` on PATH via corepack shim at `~/.local/bin` (in `.zshrc`/`.zprofile`). Backend/web use **pnpm**, never commit `package-lock.json`.
- `gh` CLI installed (Homebrew), authed as `junii03`.
- Backend dep added this work: `qrcode`. No new mobile deps.
- In non-interactive shells, prefix: `export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"`.
- Work only from `develop` or a focused `feature/...` branch. Never push directly to `main`; do not push unless explicitly requested.
- Make small, focused commits for related files. Commit and branch names must not mention Codex.
- Record completed work, verification performed, and remaining known gaps in this tracker.

## Verification commands
- Backend Compose configuration: `docker compose --env-file .env.example config` (in farm2fork-backend)
- Backend: `pnpm run build && pnpm test` (in farm2fork-backend)
- Backend e2e: `pnpm test:e2e --runInBand` (in farm2fork-backend)
- Mobile: `flutter analyze && flutter test` (in farm2fork-mobile)
- Mobile against a live backend: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
- Web: `CI=true pnpm test && CI=true pnpm run build` (in farm2fork-web)
- Web Compose configuration: `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api docker compose config` (in farm2fork-web)


## 2026-10-11 — Mobile farmer listing lifecycle

- Normal mobile builds now use a real authenticated listing repository for
  `GET /products/mine`, `POST /products`, `PATCH /products/:id`, and
  `DELETE /products/:id`. Own-list pagination is consumed fully; owner IDs and
  persisted product IDs remain server-owned. Explicit mock mode is retained.
- Buyer marketplace browsing on both web and mobile requests active listings;
  inactive/soft-deleted products no longer appear in browse/search results.
- Creation uses the returned server product immediately. Failed writes retain
  form input, show a localized inline error, and allow retry without losing
  existing listings. Navigation occurs only after successful persistence.
  Fabricated farmer names, location, rating and sales were removed from this flow.
- English and Urdu phone-sized widget checks cover save failure/retry/navigation
  and the corrected responsive step heading.
- Added an isolated cross-client harness: mobile Dart repository -> real Nest
  HTTP controller/service, JWT strategy and role checks -> disposable MongoDB ->
  mobile and web buyer repositories. Verified persisted reload, ownership,
  buyer create rejection, deactivation/reactivation and soft-delete visibility.
- Run instructions and device smoke checklist:
  `docs/testing/farmer-listings-e2e.md`.
- Scope boundary: the harness seeds test identities after authentication; it does
  not verify Firebase account acquisition, browser cookies, native device visuals,
  AI inference, or listing ledger events. QR URLs come from the existing backend;
  traceability integration is still pending.
- Verification: full mobile suite passed (92 tests; 1 live test skipped without
  harness configuration); full web suite passed (60 tests; 1 live test skipped).
  Both live tests passed when run through the real-backend harness. Changed
  mobile files passed static analysis; changed web files passed ESLint and web
  TypeScript checking passed. Full mobile analysis still reports four existing
  `unawaited_return_in_try_block` warnings in Firebase auth code.

### 2026-10-11 — Safepay ledger compatibility

- Fixed the chaincode payment gateway allowlist to accept the backend's `safepay`
  value alongside Stripe and JazzCash, preserving all other input validation.
- Added contract regression checks for Safepay write/read-back, identical retries
  and immutable-content conflicts; added backend gateway argument checks for all
  three gateways. Full Go tests and 12 backend blockchain tests passed.
- Existing uncommitted Safepay implementation was preserved. No live Fabric
  deployment or peer smoke ran because Docker is unavailable on this host.
  Existing networks require a chaincode upgrade; failed outbox records require
  separate review/retry. The blockchain README documents this boundary.
- Safepay client checkout/return handling remains pending.

### 2026-10-11 — Signed payment settlement integration

- Repaired the backend payment integration fixture to inject the real Safepay
  client with a test-only webhook secret and safely clean up disposable services.
- Added HTTP callback checks backed by real MongoDB transactions: concurrent
  success/replay, missing/invalid/tampered signatures, authorization-only events,
  payment failure, unknown trackers and multi-item stock rollback.
- Verified payment/order/inventory/outbox persistence, including one pending
  Safepay ledger record after successful repeated callbacks.
- Replaced the health fixture's infrastructure imports with an isolated real HTTP
  health-route check. Full backend E2E suite passed: four suites, 15 tests.
- Run instructions and scope: backend `docs/testing/safepay-settlement-e2e.md`.
  Real Safepay sandbox checkout/event shapes, web/mobile return handling and live
  Fabric delivery remain pending; synthetic signed events do not verify them.

### 2026-10-11 — Web Safepay handoff and return

- Web checkout now requests Safepay, preserves the hosted checkout URL for each
  farmer order and keeps the receipt visible after clearing saved cart groups.
- Orders supports payment initiation/resume/retry against the existing order ID,
  including saved orders whose first payment handoff failed. Missing or invalid
  hosted links show errors; pending requests disable repeated clicks.
- Added `/order/complete` and `/order/cancel` return pages matching the backend
  examples. Returns open Orders and read persisted status; return parameters
  never mark an order paid. Status can be refreshed manually and on focus.
- Local JazzCash/Stripe placeholders and simulator actions require an explicit
  development flag; Safepay does not show local settlement controls.
- Added a real web component/repository -> Nest HTTP/JWT/CSRF -> MongoDB harness
  with local Safepay tracker/passport fixtures. Verified two farmer orders,
  authoritative totals, cancel/resume, failed-payment retry, ownership rejection,
  signed callback/replay, stock depletion and exactly two payment/outbox records.
- Full web suite passed: 72 tests, two live tests skipped without harness config.
  The checkout live harness passed separately. TypeScript/build passed; scoped
  ESLint had no errors and five existing unused-variable warnings. Built return
  redirects were verified over HTTP. Instructions: web
  `docs/testing/safepay-checkout.md`.
- Mobile Safepay handoff/return, real provider sandbox event/checkout verification,
  Firebase cookie acquisition, browser/device visuals and live Fabric delivery
  remain pending. Existing backend Safepay implementation was preserved.

### 2026-10-11 — Mobile Safepay handoff and return

- Mobile uses Safepay hosted checkout and retains the initiation URL. Fixed
  payment reads to accept the backend's bare DTO. Added localized EN/UR launch
  failures and explicit resume/retry actions for existing pending buyer orders.
- Initial reads, browser resume and cold-start return refresh persisted status
  without creating a new tracker. Safepay does not invoke the simulator. Retry
  keeps the order ID; launch/read failures remain recoverable.
- Backend accepts an optional validated web/mobile client marker and appends
  the existing order ID to its configured return URLs for mobile only. Web
  return pages offer an app link; Android/iOS register the scheme. Return query
  parameters never mark a payment successful; ordinary web returns are retained.
- Real Dart repository/controller -> Nest HTTP/JWT/role/CSRF -> MongoDB harness
  passed: two farmer orders, authoritative totals, intentional resume, ownership
  rejection, signed success/replay, failure/retry, cold-start reads, sold-out stock
  and exactly two paid orders/payment/outbox records. Both web and mobile live
  checkout harnesses pass. Safepay tracker/passport responses are local fixtures.
- Mobile: 102 tests passed, two live tests skipped without harness config;
  changed files pass static analysis. Six payment screen/router tests pass after
  the final state-reset adjustment. Whole-app analysis retains four existing
  Firebase auth warnings. Backend: 22 payment unit tests and 15 HTTP integration
  tests passed; production source/harness TypeScript checking passed with the
  build config and rootDir override. Web: 77 tests passed, two live skips;
  TypeScript/build and built return-page HTTP checks pass.
- Android debug APK and iOS Simulator builds passed; compiled Android intent
  and iOS callback scheme verified. Retained
  resolved iOS SwiftPM dependency pins. Flutter migrated the iOS target to 15,
  matching the already installed Firebase package requirement.
- Instructions and runtime checks: `docs/testing/safepay-checkout.md`. Real
  merchant sandbox checkout/event formats, Firebase acquisition, signed-in
  native handoff/phone visuals and deployed Fabric delivery remain unverified.
  Existing backend Safepay edits were preserved. No deployment or push ran.


### 2026-10-11 — Delivery checkout contract repair

- Web/mobile now submit validated buyer map coordinates and review authoritative
  backend quotes per farmer before creating orders. Quotes include delivery fees;
  address/cart edits invalidate the review. Saved mobile orders show delivery fees.
- Farmers configure pickup address/pin from Listings on both clients. New signup
  defers location to this complete form, replacing rejected address-only payloads.
- Real web and mobile checkout harnesses pass against the rebased backend,
  including farmer pickup PATCH, delivery pricing, gateway amounts, signed payment
  settlement/replay, stock depletion and exactly two paid orders/outbox records.
- Web: 81 tests passed, two harness skips, TypeScript/production build passed.
  Mobile: 105 tests passed, two harness skips, scoped analysis passed; final
  Android debug APK and iOS Simulator builds passed.
- Merchant Safepay, Firebase sign-in, authenticated device handoff, real transport
  dispatch/notifications and deployed Fabric remain outside these local fixtures.
  See `docs/testing/safepay-checkout.md`. No push or deployment ran.

### 2026-10-11 — Transporter availability and delivery completion

- Web/mobile transporters now load server availability, explicitly enter current
  coordinates, go online/offline, refresh location, decline or accept priced
  nearby offers and advance assigned shipments through pickup, transit and
  delivery. One active shipment and role/ownership checks stay server-enforced.
- Mobile catches failed claim/status actions, disables repeated requests and
  keeps failed actions retryable. Fixed long shipment ID header overflow and
  mapping of shipments without an ETA; delivery fees and address pins are kept.
  Availability controls and errors are localized in English and Urdu.
- Both real HTTP checkout-to-delivery harnesses pass with actual transport
  services: two delivered orders, two payments, two delivered shipments with four
  timeline entries each, depleted stock and ten persisted ledger outbox records.
  Web also exercises transporter controls and the buyer delivered-shipment UI.
- Mobile: 109 tests pass, two harness skips, scoped static analysis passes;
  final Android debug APK and iOS Simulator builds pass. Web: 86 tests pass,
  two harness skips, TypeScript, production build and scoped ESLint pass.
- Coordinates are entered and refreshed manually. Automatic GPS/background
  tracking, merchant Safepay, Firebase acquisition, real push delivery and
  deployed Fabric write/readback remain separate runtime checks. Instructions:
  `../farm2fork-backend/docs/testing/transporter-delivery.md`. No deployment or
  push ran.

### 2026-10-11 — Notification clients and live Fabric verification

- Replaced local-only notification toggles with real inbox/refresh/read-all and
  explicit push opt-in/disable on web/mobile. Native FCM handles token refresh,
  foreground notices and background/cold-start taps. Sign-out cleans up the
  binding before clearing auth. EN/UR controls and recoverable errors are tested.
- Added Android notification permission/channel and iOS push entitlements plus
  remote-notification mode. Pinned Messaging/Core to match existing Firebase
  Auth native SDKs; Android debug and iOS Simulator builds pass.
- Both real checkout/delivery harnesses now verify notification persistence for
  buyers, farmers and transporters, unread/ownership checks, payment replay
  deduplication and single-device token handover/cleanup. The actual Fabric worker
  commits ten payment/shipment records and independently reads them back.
  No network reset or chaincode upgrade was needed.
- Web: 92 tests pass + two harness skips. Mobile: 113 tests pass + two harness
  skips. Backend: 171 unit tests pass. Scoped lint, type checks and native static
  analysis pass. The two extended live Fabric harnesses pass separately.
- Actual FCM/APNs receipt requires a registered device; only an iOS Simulator and
  macOS are connected. Web VAPID configuration is missing locally. Merchant
  Safepay/Firebase acquisition remain separate runtime checks. Full instructions:
  `../farm2fork-backend/docs/testing/notifications-and-fabric.md`. No deployment
  or Git push ran; new changes remain uncommitted.

- Follow-up: the supplied public VAPID key is now configured in the ignored web
  `.env.local`. Production build passes, the key reaches the browser bundle and
  the built messaging worker returns HTTP 200 with root scope. The user confirmed
  no device is available, so real FCM/APNs receipt remains unverified. Configure
  the same public key in the deployment environment before deploying web push.

### 2026-10-13 — Web: auth, profile and inline-confirm redesign (not committed)

- Sign-in and sign-up are real pages shared by every role: `/login`, `/signup`,
  `/signup/buyer`, `/signup/farmer` (three short steps, draft kept in
  `sessionStorage` without the password), `/verify-email`, `/forgot-password`.
  After sign-in the role from `GET /auth/me` decides the landing page (buyer `/`,
  farmer `/farmer`, financial partner `/financial`, admin `/admin/dashboard`,
  transporter the mobile-app page); the "wrong role" dead end is gone. Admin and
  financial use the same Firebase flow, so there is no separate staff login. The
  overlay stack on `/` is removed; `/?auth=login`, `/?auth=signup`,
  `/farmer?signup=true` and `/admin/login` redirect, and `/farmer`, `/financial`
  and `/admin/*` send signed-out visitors to `/login?next=`. English and Urdu
  (RTL), plain-language Firebase/API errors, live CNIC and phone checks (phone
  sent as E.164). Buyers who choose Individual skip the business name.
- `/account` and `/account/edit` replace `ProfileScreen` for every role: photo,
  name, phone, role details, language and text size, notifications, help links,
  sign out. Edit uses `PATCH /auth/me/profile` and `PATCH /farmers/me/farm-location`
  with a dirty guard and API field errors; the photo is cropped inline
  (`react-easy-crop`) to a 512px JPEG and sent with `PUT /auth/me/avatar`
  (`DELETE` to remove). Sign out, delete listing and discard changes are inline
  two-step confirms; the farmer listing detail opens in place. Admin, financial and
  transporter modals are untouched (second pass).
- Web checks: new unit and component tests pass (role routing, step validation,
  edit dirty/save, avatar upload happy/error path with a mocked fetch, i18n key
  parity). Nine older tests fail on this branch for reasons outside this slice
  (`AiListingAssistant`, `FarmFeed`, `LoanScreens`, `contracts` farm identity), and
  the production build stops on the same files: the merge of `develop` into this
  branch dropped the AI-assistant contract types and left duplicate methods in
  `lib/farmer/farmer-repository.ts`. Browser-checked against a mock API at desktop
  and mobile widths; no live backend or Firebase sign-in was run.

### 2026-10-13 — Mobile: login, stepped sign-up and profile redesign (not committed)

- **Login** is a compact light screen (leaf mark, "Welcome back", Google, email +
  password with inline validation, visibility toggle, forgot password, Login,
  Create account as the secondary action, guest browsing as a quiet link). It
  scrolls instead of jumping when the keyboard opens, with keyboard actions and
  autofill hints. The password-reset confirmation is no longer styled as an error.
- **Sign-up** is one stepped flow at `/auth/onboarding` (the per-role screens and
  `OnboardingScaffold` are gone): Role -> Account (new email accounts; strength
  hint) -> About you / your farm / your vehicle -> Pickup (farmers) -> Identity
  (CNIC formatted live to 13 digits, phone normalised to E.164). Google users skip
  Account and see a "Signed in with Google" chip. Individual buyers skip the
  business name; their name is sent as the business name the API still requires.
  Drafts live in `OnboardingSession.draft`, so Back and re-entering keep them. An
  "email already in use" failure returns to the Account step. `submitOnboarding`
  and the onboarding session/API calls are unchanged. Email verification gained a
  45 s resend cooldown, clear info/success/error states and "Use a different email".
- **Farmer sign-up now sends `farmLocation`** (address, city, province, lat, lng).
  The backend DTO has required it since 2026-09-24, and the previous mobile form
  omitted it, so farmer sign-up would have been rejected with a 400. Coordinates are
  still typed by hand (no GPS dependency was added).
- **The name** is not part of the onboarding DTOs, so it is saved straight after
  sign-up with `PATCH /auth/me/profile`; a failure there does not undo the sign-up.
- **Profile**: header with avatar (initials fallback), name, role badge, email,
  verified state; Account / Preferences / Help sections; sign-out confirms inline
  (no dialog). **Edit profile** (`/settings/profile`): name, phone, buyer business,
  farmer farm details (+ link to the existing pickup-location screen), transporter
  vehicle; email and masked CNIC read-only; only changed fields are sent; dirty
  guard, API field errors, pinned Save bar. Photo: gallery/camera -> square crop ->
  512 px JPEG q85 -> `PUT /auth/me/avatar` (field `file`); remove with `DELETE`. New
  `lib/features/profile` data layer (Freezed `UserProfile`, API + mock repositories,
  `ProfileController`); saving refreshes the auth user so headers update. New shared
  `AppAvatar`, `AppNoticeBanner`; `AppTextField` takes input action, autofill,
  formatters and server error text. `AuthUser` has `fullName`, `avatarUrl`, `phone`.
- **Route guard fix**: `canAccessRouteForRole` rejected every `/settings/*` path for
  signed-in users, so they were bounced home (notification and language screens
  included). Settings pages are now open to all signed-in roles; `/settings/profile`
  stays closed to guests.
- Added `image_picker` and `image_cropper`; Android `UCropActivity` and camera query,
  iOS camera/photo usage strings. Cloudinary keys stay in the backend only.
- Checks: 203 tests pass (90 new: identity helpers, login, stepped sign-up per role,
  verification, profile header and sign-out, edit dirty/save/field errors/photo
  upload/remove with fake repositories, multipart request shape, router access;
  Urdu at 1.3x text scale on every new screen). `flutter analyze` is clean apart from
  the four existing `firebase_auth_gateway` warnings. Android debug APK and the iOS
  Simulator (iPhone 11, `USE_MOCKS`) builds pass; screens checked on the simulator in
  English and Urdu. Not run: a real camera/gallery/UCrop pass, a live backend with
  Cloudinary, and Android devices (none connected).
