# Farm2Fork Design Language

## Purpose

Farm2Fork should feel like a trustworthy agricultural operating system, not a flashy shopping app. The same design philosophy must guide the Flutter mobile app and the future web admin app so both products feel connected.

## Core Philosophy

Use a hybrid expression:

- **Calm Agricultural Utility** as the base for readability, farmer usability, Urdu support, and low-distraction task completion.
- **Modern Marketplace** polish for browsing, product comparison, pricing, cart, and order flows.
- **Trust Forward** cues for blockchain traceability, QR verification, payments, shipment tracking, loan review, and admin/financial workflows.

The product should change visual intensity by role and task, not by creating separate visual systems.

## Role-Weighted Expression

### Farmer-heavy screens

Use the simplest expression. These screens need larger touch targets, direct labels, fewer decorative surfaces, and very clear form hierarchy.

Examples:

- Farmer dashboard
- Create product listing
- Edit listing
- Loan application
- Shipment handoff
- Profile setup
- Bank/farm details forms

### Buyer and marketplace screens

Use marketplace polish while staying calm. Product cards, pricing, farmer origin, availability, and quality badges should be easy to scan.

Examples:

- Marketplace home
- Product detail
- Cart
- Checkout
- Orders

### Trust, traceability, and admin screens

Use stronger verification styling. Timelines, status badges, QR/ledger states, and secure-feeling cards are appropriate here.

Examples:

- QR scanner
- Blockchain journey
- Shipment tracking
- Payment confirmation
- Admin review
- Financial partner loan review

## Visual Tokens

Use restrained agriculture-first tokens:

- Deep green for primary actions and trust.
- Soft field background instead of bright cream or loud yellow.
- Harvest yellow as an accent only.
- Muted blue for logistics, links, and information states.
- Red only for destructive and error states.
- Neutral high-contrast text for English and Urdu readability.

## Layout Rules

- Use `flutter_screenutil` for responsive typography and spacing scale.
- Use `LayoutBuilder` when the layout itself changes, such as grid columns, card density, tablet layouts, and bottom-sheet behavior.
- Prefer `EdgeInsetsDirectional`, `AlignmentDirectional`, and `PositionedDirectional`.
- Design all components assuming Urdu labels can be longer than English.
- Avoid visual density on farmer task screens.

## Component Rules

Shared primitives are the source of truth:

- `AppCard`
- `AppButton`
- `AppBadge`
- `SectionHeader`
- Future: `AppTextField`, `StatusChip`, `MetricTile`, `TimelineStep`, `FarmerSummaryCard`

Do not hand-style repeated cards, buttons, chips, or section headers inside screens unless the component API is genuinely insufficient.

## Mobile and Web Consistency

The web app should reuse the same conceptual tokens and component meanings:

- Same green/yellow/blue role meanings.
- Same trust badge and timeline language.
- Same distinction between farmer utility screens and trust-forward verification/admin screens.
- More density is allowed on web, but the visual mood must remain calm and operational.

