# Farm2Fork — Implementation Progress Tracker

> Working model: **Backend + Mobile in lockstep**, one vertical slice at a time. Each slice = a `feature/<name>` branch off `develop`, a PR per feature, reviewed and merged into `develop`. Integration branch is **`develop`** on every repo (team convention).
>
> Last updated: 2026-06-24

---

## Repo maturity snapshot

| Repo | State | Notes |
|------|-------|-------|
| **farm2fork-backend** (Nest.js) | Auth + Profiles + 17 schemas + **Marketplace** + **Orders** real | Payment still mock; blockchain/transport/loan/community/notification/ai are schema-only scaffolds |
| **farm2fork-mobile** (Flutter) | Network layer + Marketplace + **Checkout** wired to API | Defaults to `USE_MOCKS=true`; payments/notifications/loans screens not built |
| **farm2fork-web** (Next.js admin) | Polished UI prototype, all mock data | No API client / real auth yet |
| **farm2fork-blockchain** (Fabric/Go) | ~70% — chaincode `RecordPayment` + `RecordSupplyChainEvent` work | No backend SDK integration yet |
| **farm2fork-ai** (FastAPI) | Empty scaffold (plan doc only) | No Python code |

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

## Next up (not started)

**Slice 3 — Payment (Sprint 3 finish).**
- Backend: real `PaymentService` — initiate payment for an order, status transitions (`pending → success/failed/refunded`), mark order `paid`, decrement stock on success, trigger blockchain payment record (async).
  - **Open decision:** real gateway (JazzCash/Stripe keys) vs. a simulated/stubbed gateway for now.
- Mobile: payment screen after checkout, payment status display.

Then, per implementation order: **Shipments/tracking → Notifications → Loans → Community → AI predictions → Blockchain traceability screens**.

Backlog item to slot in: a **profiles endpoint** so the marketplace farmer-detail stub can be replaced with real farm name/location/rating.

---

## Environment notes
- `pnpm` on PATH via corepack shim at `~/.local/bin` (in `.zshrc`/`.zprofile`). Backend/web use **pnpm**, never commit `package-lock.json`.
- `gh` CLI installed (Homebrew), authed as `junii03`.
- Backend dep added this work: `qrcode`. No new mobile deps.
- In non-interactive shells, prefix: `export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"`.

## Verification commands
- Backend: `pnpm run build && pnpm test` (in farm2fork-backend)
- Mobile: `flutter analyze && flutter test` (in farm2fork-mobile)
- Mobile against a live backend: `flutter run --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:3000`
