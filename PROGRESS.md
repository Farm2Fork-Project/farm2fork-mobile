# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-09-24 (Slice 8)

---

## Repo maturity snapshot

| Repo | State | Notes |
|------|-------|-------|
| **farm2fork-backend** (Nest.js) | `develop` contains Auth + Profiles + 17 schemas + **Marketplace** + **Orders** + persisted payment initiation/read/refund/simulated settlement + Fabric outbox lease coverage + complete Swagger contract annotations | Loan/community/notification/ai are otherwise schema-only scaffolds; real gateway callbacks remain intentionally unimplemented |
| **farm2fork-mobile** (Flutter) | `develop` contains the network layer + Marketplace + **Checkout** + buyer payment status + shipment self-claim/tracking flow; `feature/firebase-auth` adds Firebase sign-in/onboarding | Firebase/FCM work is not yet merged; real gateway polling, notifications, and loans are not built |
| **farm2fork-web** (Next.js) | `develop` contains buyer login/registration, marketplace/product detail, farmer-grouped cart/checkout, orders/payment/shipment-status views, transporter self-claim and tracked delivery transitions, farmer/transporter onboarding, and farmer product creation; standalone Docker runtime is defined | Browser/user-flow smoke remains open; temporary `sessionStorage` token is not the final session security model |
| **farm2fork-blockchain** (Fabric/Go) | Local Fabric network and immutable payment/product shipment records, with a verified backend Gateway/outbox integration | Network is local-development only; production Fabric operations and traceability UI are not built |
| **farm2fork-ai** (Python ML pipeline) | Dataset manifests, crop-conditioned EfficientNet grade model, training/evaluation scripts, and a FastAPI inference service (`/health`, `/predict/quality`, `/predict/price`) on branch `claude/stoic-dirac-oz2ola` | No trained checkpoint yet: the service runs in a labelled untrained preview mode; prices are rule-based from illustrative values |

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

**Slice 7 — Public traceability and live farmer listings (branch `claude/stoic-dirac-oz2ola` on backend, web, mobile; not merged).**

- **Backend** — `GET /products`, `/products/:id` and `/products/:id/qr` are public, so guests browse real listings; the public list never returns deactivated listings. Creating a product now enqueues its `listed` supply-chain event in the same MongoDB transaction and links it as `initialBlockchainRecordId` (master context 6.4); the Fabric gateway submits Product-referenced events, which the chaincode already accepted. QR codes encode `PUBLIC_TRACE_ORIGIN` (falls back to `WEB_APP_ORIGIN`) instead of a hardcoded domain. New public `GET /trace/products/:id` (TraceabilityModule, EP-03) returns product, farm name/city and the listed, payment and shipment events, each with its Fabric ledger state. It never returns amounts, buyer/transporter identity or street addresses. Unit suite **93 tests**, including one that checks nothing sensitive leaks. New replica-set e2e `test/traceability.e2e-spec.ts` covers listing → payment → real transporter claim → trace, plus rollback when the outbox write fails. `app.e2e-spec.ts` still fails with the known Fabric SDK ESM/Jest limitation, identical on untouched `develop`.
- **Web** — The fabricated scan result (fake batch ID, hashes and a public payment amount) is replaced by the real journey. Public `/trace/[id]` (the QR target) and `/trace` search pages work without an account, in EN/UR with RTL. The in-app ScanScreen accepts an id or a pasted QR link and has separate invalid, not-found and retryable network-error states; the transporter copy now re-exports it. The landing page shows live listings with "Sign in to buy" / "Trace origin", and its traceability CTA opens `/trace`. Buyer product detail links to the journey. Four missing Urdu logout strings were added. **70 tests** pass and `pnpm run build` passes. Verified in a browser against the real API at desktop and 390px, EN and UR.
- **Mobile** — Farmer listings now use the real `/products/mine` and `POST/PATCH/DELETE /products` (the mock is used only with `USE_MOCKS`). The fabricated farmer (name, farm, rating, sales) is gone from both listing creation and the My Listings header, which now shows active / sold out / hidden counts. A failed publish keeps the form and the list instead of silently popping. The trace screen now uses the real `/trace/products/:id`: id or QR-link input, honest "camera scanning coming soon" copy instead of a fake viewfinder, and a new public route `/trace/products/:id` opened from product detail and each listing card. Listing-card actions are now 48dp with tooltips. The stub farmer card with "?" / 0.0 / 0 sales is hidden in API mode. Urdu times use قبل دوپہر/بعد دوپہر because intl's Urdu data prints a bare "a"/"p". `flutter analyze` shows only the 4 pre-existing warnings; **99 tests** pass.
- **Still open** — Camera QR scanning (needs a scanner package plus Android camera permission, testable only on a device); a farmer-profiles endpoint so product and listing screens can show real farm identity; per-listing ledger state on My Listings; a Fabric read-back check (the trace currently trusts the outbox's confirmed state, which the worker sets only after a successful commit); rate limiting on the new public endpoints.

**Slice 8 — Test readiness: security, AI, farm identity and a runnable stack (branch `claude/stoic-dirac-oz2ola` on all five repos; not merged).** Closes the Slice 7 open items except camera scanning.

- **Rate limiting** — backend: `@nestjs/throttler` with a global per-IP budget (`RATE_LIMIT_PER_MINUTE`, default 300) and tighter budgets on public trace (60/min), QR render (30), auth (20) and AI (20). `TRUST_PROXY` makes limits apply per real client behind nginx. 429/413/503 are in the Swagger contract.
- **Farm identity and ledger state** — backend product responses include `farmer {farmName, city, province}` and `originLedgerStatus`, loaded in batches. Web and mobile show real farm names on cards and detail pages, and a ledger chip on My Listings. The hardcoded fake farm banners ("Green Acres Farm 4.8", "Hassan Organic Farm") are removed.
- **Fabric read-back** — the trace re-reads up to 50 confirmed events from the ledger (3 s timeout, cached once verified) when `FABRIC_READ_ENABLED=true`, and reports `verified`/`mismatch`/`not_found` per event plus `ledgerCheck`. Origin is only "verified" when the ledger agrees. This also fixed `parseLedgerRecord`, which never matched the chaincode's actual response shape.
- **AI** — ai: FastAPI service around the crop-conditioned grade model, with an untrained preview mode (random weights, clearly labelled), a rule-based price fallback (master context 10.3), an optional internal token and a Dockerfile. Backend `AiModule`: farmer-only `GET /ai/status`, `POST /ai/quality` (photo upload, 8 MB) and `POST /ai/price`, storing `ai_predictions`. Web and mobile: a photo quality check and "Suggest a price" in listing creation. **Owner approval needed:** `ai_predictions` gained an optional `modelGrade` (A–D) instead of adding D to `qualityGrade` (Context.md §15.1).
- **Farm location** — farmer onboarding on web and mobile previously did not collect a complete pickup address, so transporters could never see those farmers' orders. Onboarding now requires street/village, city and province, and existing farmers get a prompt on My Listings backed by `GET/PATCH /farmers/me/farm-location`.
- **Web fixes** — farmer delete/hide actions now call the API (they were local-only fake successes); legacy CSS utilities moved into `@layer components` so Tailwind responsive classes such as `md:flex-row` work again; the farmer header no longer overflows at 390px.
- **Test readiness** — backend `docker-compose.local.yml` (Mongo replica set, Redis, API, AI, web; Fabric worker behind `--profile fabric`), `pnpm seed:demo`, `pnpm smoke:flow` (13 end-to-end API checks) and `docs/TESTING.md` with a per-role test script. Verified: seed and smoke 13/13 against the compose Mongo replica set with the live AI service. Container images for the API and web could not be built in the development sandbox (package mirrors blocked), and the Fabric network could not be started there.
- **Verification** — backend unit **111 tests**; web **79 tests**; mobile `flutter analyze` (4 pre-existing warnings) and **112 tests**; ai **26 tests**.
- **Still open** — camera QR scanning; a trained checkpoint (drop `best_model.pth` into `farm2fork-ai/models/checkpoints/grade_cond_dedup/`); sourced market prices for `price_rules.yaml`; a live Fabric run of the worker and read-back; user-owned device and browser smoke with real Firebase accounts; loans, community and notifications.

**Slice 9 — Proximity dispatch, notifications, loans, community (branch `claude/stoic-dirac-oz2ola`; not merged).** Owner-approved design: distance-based delivery fee paid by the buyer, map pins, foreground-only transporter location, Cloudinary for uploads.

- **Dispatch** — Farms and drop-offs carry a map pin (inside Pakistan). The delivery fee is base + per-km × straight-line distance × road factor (`system_config`, defaults Rs 150 + Rs 25/km × 1.3, 25 km radius). It is quoted by `POST /orders/quote`, frozen on the order and included in `grandTotal`. When an order is paid, online transporters with a location from the last 60 min within the radius and no delivery in progress get an FCM offer. They can decline, or accept through the existing atomic claim plus radius and one-delivery-at-a-time checks. Replica-set e2e proves one delivery per transporter under concurrent accepts. The drop-off shows only a ~1 km area and no street until acceptance.
- **Notifications** — in-app inbox + FCM push (device token registered on sign-in, cleared on sign-out, dead tokens pruned) for §6.5 events plus `delivery_offer`. Mobile: foreground notifications on an Android channel, tap routing, bell badges. Web: real bell for farmer, buyer and partner.
- **Loans** — farmers apply (mobile) with private documents (signed 10-minute links only). Financial partners (web `/financial`, mobile) see a farm summary with delivered-order history, review, approve (equal monthly instalments, no interest because the schema has none) or reject with a reason, and record repayments. Decisions are audit-logged.
- **Community** — posts with photos and tags, comments, author/admin removal, on mobile and the web Farm Feed.
- **Transporters are mobile-only** — web transporter portal removed. Mobile Deliveries tab: online toggle, offers with map, accept/decline, active delivery with Google Maps navigation and status steps.
- **Mock data removed** — the partner dashboard's invented credit scores, DTI and interest rates; the web farmer's hardcoded notifications; both feeds' fake posts and like counts.
- **Also fixed** — release APKs had no INTERNET permission; checkout summary rows overflowed; a loan reject dialog disposed its controller while still animating.
- **Verification** — backend 154 unit + 11 replica-set e2e; smoke flow 22/22 against a live API, Mongo replica set and AI service; web 75 tests + production build; mobile `flutter analyze` (4 pre-existing warnings) + 128 tests. **Not verified here:** an Android build (no Android SDK in the dev sandbox), real FCM delivery, real Google Maps rendering and Cloudinary uploads (no keys).
- **Schema additions (owner-approved in chat)** — `notifications.type` `delivery_offer`; `orders.deliveryFee/deliveryDistanceKm/pickupLocation/declinedBy` and `shippingAddress.lat/lng`; `shipments.deliveryFee` and address pins; `transporter_profiles.lastLocation/lastLocationAt/lastClaimAt`; delivery `system_config` keys. Existing enums and fields are unchanged.
- **Still open** — offers are pushed once at payment time. Drivers who come online later see open offers when they open the app, but there is no re-ping or widening radius. Notification text is English only. Admin web screens are still mock. Camera QR scanning.

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
- Mobile against a live backend: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api` (use port `3002` with the backend's `docker-compose.local.yml`)
- Whole flow: see `farm2fork-backend/docs/TESTING.md` (`pnpm seed:demo`, `pnpm smoke:flow`)
- Web: `CI=true pnpm test && CI=true pnpm run build` (in farm2fork-web)
- Web Compose configuration: `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api docker compose config` (in farm2fork-web)

## 2026-10-12 — develop integration

Merged the UI/UX audit branch into current remote develop in an isolated checkout. Kept develop's GPS/map dispatch and foreground heartbeat, complete farm pickup onboarding, AI listing assistance, public farm identity and ledger chips, community/loans/inbox surfaces. Integrated real Safepay launch/retry/resume and status-only cold returns, native payment deep links, bare payment DTO parsing and the `client: mobile` marker.

Buyer checkout keeps the map picker and now offers validated manual coordinates when GPS/maps are unavailable. Quotes are tied to the address, pin and cart contents; server subtotal/platform/delivery prices are shown before placement. Farmer listings retain the richer new-listing model, paginate all results and unwrap normalized ownership errors. Missing shipment ETA is accepted, and shipment status failures remain retryable.

Push uses one message/tap listener lifecycle plus one token-refresh subscription for an opted-in session. Consent remains explicit and stored per user in secure storage. An independent logout callback avoids auth/push provider cycles. Captured account and revision checks discard deferred SDK work after account changes; revocation serializes cleanup after pending token writes and blocks refresh reattachment. iOS foreground presentation and Android HIGH-priority channel creation are preserved.

Firebase Core 4.13.0 and Messaging 16.5.0 are pinned to compatible native Firebase 12.17 dependencies. Maps, geolocator and local notifications are retained. iOS uses Swift Package Manager for supported plugins and a tracked CocoaPods configuration/lock for Google Maps.

Verification recorded in the integration checkout: generated localization/models regenerated; full Flutter suite passed (157 tests, two live-only tests skipped) and scoped analysis found no issues; Android debug APK and iOS simulator app built. Full analysis retains four pre-existing `unawaited_return_in_try_block` warnings in unchanged FirebaseAuthGateway. Physical-device FCM/APNs delivery and hosted Safepay checkout are not established by builds or unit tests. The integration root's disposable backend/Fabric harness verified two paid/delivered orders and ten confirmed ledger/readback events through the merged mobile adapters.

The integration root also passed the real cross-platform listing lifecycle: persisted mobile listing, buyer web/mobile visibility, ownership and buyer-role denials, deactivate/reactivate/soft delete, and exactly one linked origin outbox record.

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
