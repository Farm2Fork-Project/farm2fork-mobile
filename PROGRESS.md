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
| **farm2fork-blockchain** (Fabric/Go) | ~70% — chaincode `RecordPayment` + `RecordSupplyChainEvent` work | No backend SDK integration yet |
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

**Slice 3 — Local runtime + simulated payment.**

- **Runtime** — backend branch `feature/payment-runtime`: `e0f1aef` removes Compose `env_file`, requires `DATABASE_URL` for Atlas, and runs local Redis only. `docker compose --env-file .env.example config` passed. No Atlas-backed `docker compose up` was run because only placeholder credentials are available.
- **Backend payment write/read/refund path** — `15f585a`, `f8355f6`, `4b87ae3`, `021aa91`, `ccf4f00`, `07b5dca`: buyer-owned pending orders create/reuse a persisted payment whose amount comes from `Order.grandTotal`; buyer/admin list and individual reads are database-backed and ownership-scoped; admin refunds persist without restocking inventory. The guarded local simulator settles success idempotently in a MongoDB transaction, decrements stock once, marks zero stock `sold_out`, sets the order `paid`, and creates one pending blockchain outbox record. A public webhook now returns 501 until a real provider signature design exists. `pnpm run build`, `pnpm test` (64 tests), and `pnpm test:e2e --runInBand` (2 tests) passed.
- **Mobile flow** — branch `feature/payment-mobile`: `be0ff8f`, `5574a6e`, `025b460`, `9d85daf` add typed payment API/mock repositories, a payment controller, a localized buyer status screen, checkout-to-payment navigation, and a persisted payment-status adapter. The test-completion action is visible only in mock mode or with `PAYMENT_SIMULATOR_ENABLED=true`; normal API builds create a pending payment and do not call the simulator. `flutter analyze` and `flutter test` passed (60 tests).
- **Still open in this slice** — real JazzCash/Stripe and provider signature validation; Atlas Compose/device smoke test; mobile polling after a real-gateway redirect; Fabric Gateway SDK/retry worker; web API integration; automatic refund restocking.

Then, per implementation order: **Shipments/tracking → Notifications → Loans → Community → AI predictions → Blockchain traceability screens**.

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
