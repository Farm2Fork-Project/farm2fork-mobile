# Implementation Plan — Mobile UI Screen Construction & Theme Constraints

This plan covers the step-by-step implementation of the core user-facing screens for the Farm2Fork mobile application, including strict rules for theme compliance and complete multilingual localization.

---

## User Review Required

> [!IMPORTANT]
> - **Theme-Only UI Rule**: We will update the `Agent Development Ruleset.md` to add a strict rule requiring that we **only** use existing theme tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, etc.) and avoid inventing any custom colors or typographies.
> - **Complete Localization**: Every user-facing string must be localized via `lib/l10n/app_en.arb` and `lib/l10n/app_ur.arb`. Hardcoded strings will be strictly forbidden.
> - **Admin and Financial Partner Exclusions**: Admins and financial partners will have no screens inside the mobile application (restricted to the web UI only). The mobile app will focus purely on **Farmers**, **Buyers**, and **Transporters**.

---

## Proposed Changes

### Component 1: Ruleset Modification

#### [MODIFY] [Agent Development Ruleset.md](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/Agent%20Development%20Ruleset.md)
- In the UI/UX section, explicitly append the strict instructions that AI and developers must **only** use the theme for the UI, must **not** invent colors or typographies (e.g. no random `Color(0xFF...)` or `TextStyle(...)` custom definitions unless using existing tokens), and that **any** user-visible string must be completely translated/localized inside the `.arb` files.

---

### Component 2: Farmer Listings Epic

#### [NEW] [listings_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/listings/data/repositories/listings_repository.dart) & [mock_listings_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/listings/data/repositories/mock_listings_repository.dart)
- Define a repository interface and mock implementation for retrieving and managing the active farmer's products (listings).
- Expose methods: `getFarmerListings(String farmerId)`, `createListing(Product product)`, `deleteListing(String productId)`, and `updateListingStatus(String productId, ProductStatus status)`.

#### [NEW] [listings_controller.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/listings/presentation/providers/listings_controller.dart)
- Create a Riverpod controller to manage listings state (loading, error, list of products).

#### [MODIFY] [listings_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/listings/presentation/screens/listings_screen.dart)
- Replace placeholder with a high-fidelity listings manager:
  - Header: showing the active farm's summary (name, total sales, rating).
  - List of active listings with card layout: displays produce name, price per unit, stock quantity, quality grade, and status badge (`Available` or `Sold out`).
  - Interactive controls: toggle status (active/inactive), delete button, and a prominent Floating Action Button to create a new listing.

#### [MODIFY] [create_listing_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/listings/presentation/screens/create_listing_screen.dart)
- Replace placeholder with a beautiful, fully validated multi-step form:
  - **Step 1: Produce Details**: input crop name, category dropdown (Vegetables, Fruits, Grains, Dairy), quality grade (A, B, C), and detailed description.
  - **Step 2: Pricing & Stock**: input unit price (PKR), stock quantity, and unit selector (kg, ton, dozen, piece, litre).
  - Validation: fields must not be empty; price and quantity must be valid positive numbers.
  - Complete Urdu RTL safety and localization support for all fields, labels, error messages, and buttons.

---

### Component 3: Orders Epic

#### [NEW] [order.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/orders/data/models/order.dart)
- Create a Freezed model for Orders, fully matching the 17-collection NestJS backend/MongoDB schema.
- Fields: `id`, `buyerId`, `farmerId`, list of items (`OrderItem`), `totalAmount`, `platformFeePercent`, `platformFeeAmount`, `grandTotal`, `shippingAddress`, `status`, `paymentId`, `shipmentId`, `createdAt`.

#### [NEW] [orders_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/orders/data/repositories/orders_repository.dart) & [mock_orders_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/orders/data/repositories/mock_orders_repository.dart)
- Fetch orders by user role (`buyer` -> buy orders, `farmer` -> receive orders, `transporter` -> deliveries).

#### [NEW] [orders_controller.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/orders/presentation/providers/orders_controller.dart)
- Riverpod controller for orders.

#### [MODIFY] [orders_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/orders/presentation/screens/orders_screen.dart)
- Replace placeholder with a premium dashboard displaying order cards:
  - Tabbed interface: active orders vs. history.
  - Details inside card: order number, date, items listing, totals (subtotal, platform fee, grand total), order status chip, payment status, and delivery partner status.
  - Role-specific UI views (Buyer sees items + farmer details; Farmer sees buyer name + shipping address; Transporter sees pickup farm location + destination).

---

### Component 4: Transporter Shipments Epic

#### [NEW] [shipment.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/shipments/data/models/shipment.dart)
- Create shipment model: `id`, `orderId`, `transporterId`, `status` (`assigned`, `picked_up`, `in_transit`, `delivered`, `failed`), `pickupAddress`, `deliveryAddress`, `statusHistory` list, `estimatedDelivery`, `actualDelivery`.

#### [NEW] [shipments_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/shipments/data/repositories/shipments_repository.dart) & [mock_shipments_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/shipments/data/repositories/mock_shipments_repository.dart)
- Retrieve shipments assigned to the active transporter, and update shipment status along with a textual history note.

#### [NEW] [shipments_controller.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/shipments/presentation/providers/shipments_controller.dart)
- Riverpod notifier for shipment status updates.

#### [MODIFY] [shipments_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/shipments/presentation/screens/shipments_screen.dart)
- High-fidelity transporter view:
  - Map/Address info: prominent cards showing pickup address (farmer location) and delivery address (buyer location).
  - Status slider/button: allows transporter to progress delivery state (`Pick Up`, `In Transit`, `Deliver`).
  - Timeline UI: derived directly from the real `statusHistory` array to visually display when the shipment was assigned, picked up, etc.

---

### Component 5: QR Traceability Epic

#### [NEW] [traceability_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/traceability/data/repositories/traceability_repository.dart) & [mock_traceability_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/traceability/data/repositories/mock_traceability_repository.dart)
- Handle fetching the blockchain journey timeline for a given product or shipment ID.

#### [MODIFY] [trace_scanner_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/traceability/presentation/screens/trace_scanner_screen.dart)
- Clean, premium QR interface:
  - Interactive Scanner mockup: simulated QR scanner overlay (with option to choose/click a sample product QR code to test).
  - Visual Blockchain Journey: shows an interactive vertical timeline of the scanned crop:
    1. **Farmer Listing**: showing farmer name, farm city, date of listing, and Hyperledger block/transaction hash.
    2. **Payment Confirmed**: buyer name, payment gateway, transaction hash.
    3. **Shipment Dispatch**: picked up by transporter, license plate, timestamp.
    4. **Delivery Successful**: delivery date and final recipient confirmation.

---

### Component 6: Community Feed Epic

#### [NEW] [post.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/community/data/models/post.dart)
- Freezed model for Community Posts and Comments.

#### [NEW] [community_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/community/data/repositories/community_repository.dart) & [mock_community_repository.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/community/data/repositories/mock_community_repository.dart)
- Retrieve community feed, upvote/like posts, add/retrieve comments.

#### [MODIFY] [feed_screen.dart](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/features/feed/presentation/screens/feed_screen.dart)
- A vibrant social feed screen:
  - Posts by other farmers/buyers sharing advice on crop yields, soil conditions, marketplace trends, and pricing.
  - Custom cards: author info, post date, tags, clear body content, and action items (like, comment, share).
  - Clean comments overlay: allows viewing and writing quick comments with complete localized strings.

---

### Component 7: Localization Addition

#### [MODIFY] [app_en.arb](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/l10n/app_en.arb) & [app_ur.arb](file:///Users/mac/junaidAfzal/Farm2Fork/farm2fork_mobile/lib/l10n/app_ur.arb)
- Add comprehensive localized entries for:
  - All form validation error messages (empty, negative numbers, invalid formats).
  - Order details labels: subtotal, platform fee, grand total, shipping address, order ID.
  - Status labels: pending, success, failed, refunded, assigned, picked up, in transit, delivered.
  - Timeline labels, community feed buttons (like, comment, post crop update), and create listing headings.

---

## Verification Plan

### Automated Tests
- We will execute the command `flutter test` to ensure that model serialization, one-order-one-farmer validation, and localization configs remain fully correct.
- We will run `flutter analyze` to verify code health.

### Manual Verification
- Switch application language inside the Profile screen to confirm that every element (titles, buttons, validation alerts, chips) instantly renders in simple, idiomatic Urdu with correct RTL text-alignment.
- Run the app across various screens (Listings, Create Listing, Orders, Shipments, Trace Scanner, Community Feed) to verify premium visual appearance using only the locked theme palettes and sizes.
