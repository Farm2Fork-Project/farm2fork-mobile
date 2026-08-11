# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-08-11

---

## Repo maturity snapshot

| Repo | State | Notes |
|------|-------|-------|
| **farm2fork-backend** (Nest.js) | Auth + Profiles + 17 schemas + **Marketplace** + **Orders** real | Payment endpoints are DTO-shaped mocks; blockchain/transport/loan/community/notification/ai are schema-only scaffolds |
| **farm2fork-mobile** (Flutter) | Network layer + Marketplace + **Checkout** wired to API | Defaults to `USE_MOCKS=true`; payments/notifications/loans screens not built |
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

## Agreed next slice (not started)

**Slice 3 — Local runtime + simulated payment.**

- Runtime: Docker Compose runs the NestJS backend and local Redis. MongoDB Atlas is used through `DATABASE_URL`; MongoDB is deliberately not containerized. Flutter remains a native mobile runtime, not a Docker service.
- Backend: replace mock `PaymentService` responses with persisted payments; enforce buyer/order ownership and one payment per order; support idempotent simulated callback settlement; atomically mark an order `paid`, decrement stock once, and create a pending blockchain transaction record.
- Mobile: initiate one simulated payment for each farmer-grouped order and show pending/success/failed status.
- Deferred: real JazzCash/Stripe integration, Fabric Gateway SDK/retry worker, web API integration, and automatic restocking on refunds.

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
- Backend: `pnpm run build && pnpm test` (in farm2fork-backend)
- Mobile: `flutter analyze && flutter test` (in farm2fork-mobile)
- Mobile against a live backend: `flutter run --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:3000`
