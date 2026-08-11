# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-08-11

---

## Repo maturity snapshot

| Repo | State | Notes |
|------|-------|-------|
| **farm2fork-backend** (Nest.js) | Auth + Profiles + 17 schemas + **Marketplace** + **Orders** + persisted payment initiation/read/refund/simulated settlement | Blockchain/transport/loan/community/notification/ai are otherwise schema-only scaffolds |
| **farm2fork-mobile** (Flutter) | Network layer + Marketplace + **Checkout** + buyer payment status flow | Defaults to `USE_MOCKS=true`; real gateway polling, notifications, and loans are not built |
| **farm2fork-web** (Next.js admin) | Polished UI prototype, all mock data | No API client / real auth yet |
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

## Active slice (local feature branches; not merged or pushed)

**Slice 3 — Local runtime, simulated payment, and Fabric persistence.**

- **Runtime** — backend branch `feature/payment-runtime`: `e0f1aef` removes Compose `env_file`, requires `DATABASE_URL` for Atlas, and runs local Redis only. `docker compose --env-file .env.example config` passed. No Atlas-backed `docker compose up` was run because only placeholder credentials are available.
- **Backend payment write/read/refund path** — `15f585a`, `f8355f6`, `4b87ae3`, `021aa91`, `ccf4f00`, `07b5dca`: buyer-owned pending orders create/reuse a persisted payment whose amount comes from `Order.grandTotal`; buyer/admin list and individual reads are database-backed and ownership-scoped; admin refunds persist without restocking inventory. The guarded local simulator settles success idempotently in a MongoDB transaction, decrements stock once, marks zero stock `sold_out`, sets the order `paid`, and creates one pending blockchain outbox record. A public webhook now returns 501 until a real provider signature design exists. `pnpm run build`, `pnpm test` (64 tests), and `pnpm test:e2e --runInBand` (2 tests) passed.
- **Fabric backend integration** — backend branch `feature/fabric-backend-integration`: `2ecd364`, `7af5659`, `a253b97`, `3d30a29`, `a1c45b5`, `5d83198`, `d811162` add the Fabric Gateway client, durable leased outbox worker, per-product shipment-event fan-out, and an isolated Docker worker on the local Fabric network. The worker configuration is namespaced correctly, defaults align with the deployed `farm2fork-chaincode`, and submissions target `Farm2ForkMSP` explicitly. Focused worker/gateway/config tests (**12**) and `pnpm run build` pass. An approved Atlas/Fabric synthetic payment smoke was confirmed in Atlas and independently read back from Fabric; no production order, payment, shipment, or product was used.
- **Mobile flow** — branch `feature/payment-mobile`: `be0ff8f`, `5574a6e`, `025b460`, `9d85daf` add typed payment API/mock repositories, a payment controller, a localized buyer status screen, checkout-to-payment navigation, and a persisted payment-status adapter. The test-completion action is visible only in mock mode or with `PAYMENT_SIMULATOR_ENABLED=true`; normal API builds create a pending payment and do not call the simulator. `flutter analyze` and `flutter test` passed (60 tests).
- **Still open in this slice** — real JazzCash/Stripe and provider signature validation; mobile polling after a real-gateway redirect; concurrent-lease and existing-ledger-key outbox e2e coverage; web API integration; automatic refund restocking. The full backend e2e suite remains unverified because its Jest runtime currently conflicts with the Fabric SDK's ESM dependency path.

**Slice 4 — Shipment self-claim and tracking (in progress; local-only).**

- **Backend** — branch `feature/shipment-self-claim`, with Fabric integration on `feature/fabric-backend-integration`: `3d5600f`, `5300e4c`, `82a2da7`, `7af5659` add a privacy-preserving paid/unclaimed delivery list; an atomic first-claim transaction that creates the assigned shipment, updates the order, and writes one typed supply-chain outbox record per distinct product; role-scoped shipment reads; and guarded transporter transitions (`assigned → picked_up → in_transit → delivered`, with terminal failure). The replica-set e2e test proves one concurrent claimant wins and duplicate-key conflicts return 409. `pnpm run build`, `pnpm test` (**70 tests**), and `pnpm test:e2e --runInBand` (**4 tests**) passed before the Fabric SDK was included; the current focused Fabric-related test suite is green, while the full e2e suite has the ESM/Jest limitation noted above.
- **Mobile data and transporter flow** — branch `feature/shipment-self-claim`: `62edbe5`, `769b59a`, `5418f22`, `6d87f9a` add typed real/mock shipment repositories, redacted available-delivery cards, atomic claim UI, a read-only `/shipments/:id` tracking route, buyer/farmer order-card entry when `shipmentId` exists, and complete EN/UR shipment-screen copy. The real client sends only `orderId` to claim and only `{status, note}` to transition. `flutter test test/shipments` (**5 tests**) and `flutter analyze` passed.
- **Still open before this slice is complete** — run full `flutter test`; user-owned physical-device smoke checks; concurrent-lease and existing-ledger-key Fabric outbox e2e coverage. Maps/GPS, notifications, bids/fees, buyer offer selection, proof of delivery, reassignment, and web integration remain deferred.

Then, per implementation order: **Notifications → Loans → Community → AI predictions → Blockchain traceability screens**. The backend-to-Fabric foundation is now in place; the later traceability screens still need a web/mobile API integration slice.

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
- Mobile against a live backend: `flutter run --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:3000`
