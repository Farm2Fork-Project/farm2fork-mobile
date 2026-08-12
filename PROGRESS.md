# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-08-12

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

Then, per implementation order: **Notifications → Loans → Community → AI predictions → Blockchain traceability screens**. The backend-to-Fabric foundation is now in place; the later traceability screens still need web/mobile API integration.

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
