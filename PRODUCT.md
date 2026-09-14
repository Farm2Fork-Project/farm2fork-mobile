# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Farm2Fork's mobile app serves three self-service roles plus an unauthenticated guest:

- **Farmers** — small-scale Pakistani growers listing produce for sale, tracking orders, applying for microfinance, and reading/posting in the community feed. Often lower digital literacy, may prefer Urdu, use low/mid-range Android phones, and need the simplest, lowest-friction screens in the app (per the team's own design-language doc, "Calm Agricultural Utility").
- **Buyers** — retailers, restaurants, and wholesalers browsing the marketplace, building a farmer-grouped cart, checking out, paying, and tracking orders/shipments. Comparison-shopping mindset; screens here get "Modern Marketplace" polish while staying calm.
- **Transporters** — delivery partners who claim available shipments and update delivery status through a guarded state machine (assigned → picked_up → in_transit → delivered).
- **Guests** — unauthenticated visitors who can browse the marketplace, use the QR trace scanner, and view a read-only cart before being prompted to authenticate.

A `financial_partner` role shell exists in the app's router/navigation config (loans review + feed + profile) but financial partners are primarily expected to operate from the web app; treat mobile financial-partner screens as lower priority until confirmed otherwise.

Admin has no mobile presence by design (admin nav is intentionally empty) — administrators work exclusively from farm2fork-web.

Both English and Urdu (RTL) are supported and mandatory for every user-facing string (ARB-based localization, zero hardcoded strings is a hard team rule). Urdu labels can run longer than English and layouts must tolerate that.

## Product Purpose

Farm2Fork is a blockchain-backed, AI-enhanced platform that connects Pakistani farmers directly to buyers, removing exploitative middlemen and giving buyers verifiable supply-chain transparency. The mobile app is the primary interface for farmers, buyers, and transporters to run their day-to-day marketplace, order, payment, shipment, and (eventually) financing and quality-verification workflows on a phone.

Success for this app is a farmer-to-buyer transaction that feels trustworthy and low-friction end to end: list or find produce, agree a fair price, pay/get paid safely, and see the product's journey and delivery status without needing a middleman to vouch for any of it.

## Positioning

No existing local competitor (e.g. Agriconnect, Farmease) combines direct marketplace + blockchain traceability + AI-driven pricing/quality + microfinance + a dedicated transport module in one product. The blockchain journey timeline, QR-code verification, an AI price advisor with a visible confidence score, and an in-app loan-application flow are the specific mechanisms meant to be visibly different from a generic marketplace app, not just backend plumbing — they should read as trust-building UI, not hidden infrastructure.

## Operating Context

- This is a Final Year Project built by a 3-person student team (one of whom owns UI/UX for mobile) with heavy AI-coding-agent assistance, developed against a shared cross-repo master spec (`Context.md`) and a living progress tracker (`PROGRESS.md`) in this repo.
- Backend, mobile, and web repos move in lockstep on `feature/*` branches merged into each repo's `develop`; `develop` is the integration branch to build against, not `main`.
- The backend is a real, working Nest.js API (not fully mocked): auth, profiles, marketplace, orders, and a simulated payment/Fabric-outbox pipeline are implemented and tested. Some backend capability the UI may eventually need does not exist yet — see Capabilities and Constraints.
- The app supports a `USE_MOCKS` dart-define toggle and separate mock/API repository implementations per feature, so screens can be reviewed either against mock data or a live local backend (`http://10.0.2.2:3000/api` on the Android emulator).
- Locked stack: Flutter + Dart, Riverpod (state), go_router (routing, including a guest shell and per-role `StatefulShellRoute` shells), Dio (networking), Freezed/json_serializable (models). Bloc, GetX, Provider, MobX, and raw `Navigator.push` are explicitly forbidden by the team's ruleset.

## Capabilities and Constraints

**Implemented and real (not mocked) as of the `develop` branch:** Firebase-based auth with role onboarding (farmer/buyer/transporter self-service; admin/financial_partner are allowlist-provisioned, never self-assignable); marketplace browse/search/product detail; farmer-grouped cart and one-order-one-farmer checkout; order creation and status; a payment flow whose real-gateway settlement is simulated (JazzCash/Stripe are not yet live — the in-app "complete payment" test action is only reachable in mock mode or with a simulator flag, and this must read to the user as genuinely pending, not broken); shipment self-claim and guarded status-transition tracking for transporters; a QR trace scanner screen; a community feed with posts/comments.

**Explicitly not yet built — do not design these as if they were finished:** real JazzCash/Stripe gateway UI/redirect handling; push notifications (FCM) and any notification center; loan applications (currently a single shared "coming soon" placeholder screen); AI price-advisor and quality-grading screens (no FastAPI endpoint wired yet); a blockchain "journey timeline" view distinct from the QR scanner; maps/GPS for live shipment tracking; proof-of-delivery capture; shipment reassignment; full Urdu coverage of admin-only surfaces (not applicable to mobile, which has no admin surface at all).

**Terminology:** "farmer_summary" on a product is currently a synthesized empty stub client-side (the backend `/products` endpoint doesn't yet embed real farmer detail) — screens showing farmer identity on a product/order should be designed to tolerate a sparse/placeholder farmer summary gracefully, not assume it's always populated.

## Brand Commitments

Product name is "Farm2Fork." No logo, mark, or marketing asset set has been established as binding for this audit — treat existing icon usage (Material icons via `IconData`) as implementation detail, not brand commitment.

## Evidence on Hand

- `Context.md` (this repo) — full cross-repo master spec: data model, roles, module boundaries, sprint plan.
- `PROGRESS.md` (this repo) — living, dated log of exactly what's merged, tested, and still open per slice, across all 5 repos.
- `docs/design/farm2fork-design-language.md` (this repo) — the team's own design-system philosophy (Calm Agricultural Utility / Modern Marketplace / Trust Forward role-weighted expression, token list, shared primitive list).
- `lib/core/theme/` and `lib/core/widgets/` — the actual implemented design tokens (`AppColors`, `AppSpacing`, `AppTypography`) and shared primitives (`AppCard`, `AppButton`, `AppBadge`, `SectionHeader`, `FeaturePlaceholderScreen`).
- No user research, testimonials, usage analytics, or real farmer/buyer feedback exists yet — this is pre-launch academic work; do not fabricate any of that.

## Product Principles

1. Screen intensity follows role and task, not personal taste — farmer task screens stay plain and high-contrast; buyer/marketplace screens get more visual polish; trust/verification screens (QR, payments, shipment tracking) get stronger, more deliberate "secure-feeling" styling. This is an explicit, already-documented rule, not a suggestion.
2. Every screen must have honest behavior for loading, empty, error, and partial data, in addition to the happy path — several current screens for not-yet-backed features (payments, loans) need to clearly read as "pending/coming soon," never as broken or unfinished-looking.
3. Reuse the existing shared primitives (`AppCard`, `AppButton`, `AppBadge`, `SectionHeader`) before introducing new hand-styled widgets; the team's own ruleset already forbids ad hoc card/button/chip styling inside screens.
4. Zero hardcoded, English-only, or Urdu-only strings; assume Urdu text runs longer than English and design layouts that don't break under that.
5. Mobile and web must share conceptual meaning (same role colors, same trust-badge and timeline language) even though implementations are separate codebases — a change to one should be checked against the other.

## Accessibility & Inclusion

Farmer-heavy screens must use larger touch targets, direct labels, minimal decorative surfaces, and clear form hierarchy — this is a named, explicit requirement (not generic a11y advice) because farmer users are assumed to have lower digital literacy and are the most vulnerable persona this product exists to serve. Full bilingual (English/Urdu, LTR/RTL) support is a hard MVP requirement, not a stretch goal.
