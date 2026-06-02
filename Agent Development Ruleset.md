# Farm2Fork Mobile App — Agent Development Ruleset v1.1

## 1. Project Overview

Farm2Fork is a Flutter mobile application for a farm-to-consumer marketplace. The app connects farmers, buyers, transporters, financial partners, and admins.

The application must support:

* English
* Urdu

The application must follow the approved architecture, database schema, feature boundaries, localization strategy, and data-model rules.

Agents must treat this document as the project source of truth unless the project owner explicitly updates it.

---

## 2. Locked Technical Decisions

The following decisions are locked:

```text
Framework: Flutter
Language: Dart
State management: Riverpod
Routing: go_router
Networking: Dio
Data models: Freezed + json_serializable
Code generation: build_runner
Localization: flutter_localizations + intl + ARB files + language toggle
Linting: flutter_lints
Architecture: feature-first architecture
```

Agents must not replace these choices without explicit approval.

Agents must not introduce:

```text
Bloc
GetX
Provider
MobX
Raw Navigator-first routing
Raw http client instead of Dio
Manual JSON parsing everywhere
Hardcoded localization strings
```

---

## 3. Approved Backend Collections

The backend schema contains 17 collections:

```text
1. users
2. farmer_profiles
3. buyer_profiles
4. transporter_profiles
5. financial_partner_profiles
6. products
7. orders
8. payments
9. blockchain_transactions
10. shipments
11. loan_applications
12. audit_logs
13. posts
14. comments
15. notifications
16. ai_predictions
17. system_config
```

Flutter models must align with these collections where applicable.

Agents must not rename, remove, or reinterpret schema fields casually.

---

## 4. Required Project Structure

Use feature-first architecture.

Required base structure:

```text
lib/
  app/
    app.dart
    bootstrap.dart
    router.dart

  core/
    config/
    constants/
    error/
    localization/
    network/
    storage/
    theme/
    utils/
    widgets/

  features/
    auth/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    marketplace/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    cart/
      data/
        models/
        repositories/
      presentation/
        providers/
        screens/
        widgets/

    orders/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    payments/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    shipments/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    loans/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    community/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    notifications/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/

    profile/
      data/
        models/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/
```

Agents may add subfolders only when the feature requires it.

Agents must not create vague folders such as:

```text
helpers/
common2/
new_widgets/
utils_old/
misc/
temp/
```

---

## 5. Data Model Rules

All API/data models must use Freezed and json_serializable.

Every model must follow this pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_model.freezed.dart';
part 'example_model.g.dart';

@freezed
abstract class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

Rules:

```text
- Use Dart camelCase field names.
- Use @JsonKey when backend field names differ.
- Use @Default for safe fallback values.
- Use nullable fields only when backend can return null.
- Use typed nested models instead of dynamic/Object/Map when possible.
- Never parse raw JSON in widgets.
- Never pass raw Map<String, dynamic> into UI widgets.
- Never manually edit generated files.
```

When models change, agents must run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

During heavy model work, agents may use:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Generated files must be committed:

```text
*.freezed.dart
*.g.dart
```

---

## 6. Schema-Specific Rules

### 6.1 User Roles

Allowed user roles are:

```text
farmer
buyer
transporter
financial_partner
admin
```

Agents must not invent alternate role names such as:

```text
customer
seller
driver
finance
super_admin
```

unless the backend schema is officially changed.

---

### 6.2 Profile Models

Each role-specific profile must be handled separately:

```text
farmer_profiles
buyer_profiles
transporter_profiles
financial_partner_profiles
```

Agents must not merge all profile models into one generic profile model unless explicitly instructed.

---

### 6.3 Product Blockchain Field

The product blockchain field is:

```text
initialBlockchainRecordId
```

Agents must not use the old name:

```text
blockchainTxId
```

This field represents the first traceability blockchain record created when the product is listed.

---

### 6.4 One-Order-One-Farmer Rule

This is a mandatory business rule.

One order belongs to exactly one farmer.

Rules:

```text
- orders.farmerId defines the farmer for the order.
- Every item in orders.items[] must belong to the same farmerId.
- The cart must group products by farmer.
- Checkout must create separate orders for separate farmers.
- UI must clearly show farmer-grouped checkout sections.
```

Example:

```text
Cart:
  Farmer A:
    Product 1
    Product 2

  Farmer B:
    Product 3

Checkout result:
  Order 1 for Farmer A
  Order 2 for Farmer B
```

Agents must not implement a single global checkout that creates one mixed-farmer order.

---

### 6.5 Payment Rules

Payment statuses:

```text
pending
success
failed
refunded
```

Payment models must support:

```text
paidAt
failedAt
refundedAt
```

Rules:

```text
- A payment record does not automatically mean payment succeeded.
- UI must display payment status clearly.
- Payment timestamps are nullable.
- Do not expose gateway internals unnecessarily.
```

---

### 6.6 Shipment Rules

Shipment statuses:

```text
assigned
picked_up
in_transit
delivered
failed
```

Shipment status history must include:

```text
status
timestamp
note
updatedBy
```

Rules:

```text
- Shipment timeline UI must be based on statusHistory.
- Do not hardcode fake timeline steps.
- Display transporter notes when available.
- updatedBy identifies who changed the shipment status.
```

---

### 6.7 Blockchain Transaction Rules

Blockchain transaction types:

```text
payment
supply_chain_event
```

Rules:

```text
- Blockchain payloads must be sanitized.
- Do not expose raw payload internals to normal users.
- Do not display private payment metadata.
- Do not display CNIC, bank details, passwordHash, FCM token, or audit internals.
```

---

### 6.8 System Config Rules

System config must be accessed through a service/repository abstraction.

Known config-style values include:

```text
platform_fee_percent
max_loan_amount
min_loan_amount
supported_gateways
```

Rules:

```text
- UI must not access raw system_config directly.
- Config values must be converted into typed frontend values.
- Invalid config values must be handled safely.
```

---

## 7. Localization Rules — Locked and Expanded

### 7.1 Localization Approach

The localization approach is locked:

```text
Flutter flutter_localizations + intl package + ARB files + in-app language toggle
```

Supported locales:

```text
English: en
Urdu: ur
```

Agents must not replace this with a custom localization system.

Agents must not use third-party localization packages unless explicitly approved.

---

### 7.2 Localization Goal

The app must be fully usable in both English and Urdu.

Localization is not decorative.

Agents must assume every user-facing screen must support:

```text
English LTR
Urdu RTL
Language switching inside the app
Persistent language preference
Localized validation messages
Localized empty states
Localized error messages
Localized button labels
Localized navigation labels
Localized status labels
```

---

### 7.3 Required Localization Files

Localization files must live here:

```text
lib/l10n/
  app_en.arb
  app_ur.arb
```

Localization config must be in:

```text
l10n.yaml
```

The project must use Flutter-generated localization output.

Agents must not manually create custom translation classes unless explicitly instructed.

---

### 7.4 Language Toggle Requirement

The app must include an in-app language toggle.

Rules:

```text
- Users must be able to switch between English and Urdu from inside the app.
- Language change must apply app-wide.
- Language preference must be persisted locally.
- App restart must keep the selected language.
- The toggle must not require logout.
- The toggle must not require app reinstall.
```

Recommended UI locations:

```text
Profile screen
Settings screen
Onboarding / first launch screen if required
```

The language toggle must use Riverpod or the approved app state mechanism.

Agents must not use random local `setState` for app-wide language changes.

---

### 7.5 Locale State Rules

Locale must be managed centrally.

Recommended ownership:

```text
core/localization/
  locale_controller.dart
  locale_repository.dart
```

Rules:

```text
- selectedLocale must be provided to MaterialApp.router.
- locale changes must notify the entire app.
- persisted locale must be loaded during app bootstrap.
- default locale should be English unless product owner specifies otherwise.
- unsupported locale values must fallback safely to English.
```

Expected app root behavior:

```dart
MaterialApp.router(
  locale: selectedLocale,
  supportedLocales: const [
    Locale('en'),
    Locale('ur'),
  ],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  routerConfig: router,
);
```

Agents must not hardcode locale directly inside screens.

---

### 7.6 Accessing Localized Text

Agents must use a context extension or generated localization access consistently.

Preferred pattern:

```dart
Text(context.l10n.addToCart)
```

Not allowed:

```dart
Text('Add to Cart')
Text('کارٹ میں شامل کریں')
```

A helper extension may be used:

```dart
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

Rules:

```text
- All visible strings must use localization keys.
- Both English and Urdu ARB files must be updated together.
- Do not add English-only keys.
- Do not add Urdu-only keys.
- Key names must be descriptive and stable.
```

---

### 7.7 Hardcoded String Ban

Agents must not hardcode user-facing strings in:

```text
Widgets
Buttons
TextFields
SnackBars
Dialogs
Bottom sheets
AppBars
Navigation bars
Validation messages
Error messages
Empty states
Loading messages
Status labels
Tooltips
Form labels
Hints
Placeholders
```

Allowed hardcoded strings:

```text
Debug logs during development
Non-user-facing enum values
Internal route names
Internal API constants
Asset paths
Test descriptions
```

Even debug logs must not contain sensitive data.

---

### 7.8 ARB Key Naming Rules

ARB keys must use lowerCamelCase.

Good:

```text
login
logout
addToCart
orderDetails
paymentFailed
shipmentInTransit
loanApplicationSubmitted
productOutOfStock
```

Bad:

```text
Login
login_text
btn_add_cart
text1
messageNew
urduLogin
```

Rules:

```text
- Key names must describe meaning, not UI location only.
- Do not create duplicate keys with the same meaning.
- Do not create separate keys for English and Urdu.
- Do not use vague names like title1, button2, labelText.
```

---

### 7.9 ARB Message Examples

English:

```json
{
  "appName": "Farm2Fork",
  "login": "Login",
  "logout": "Logout",
  "addToCart": "Add to Cart",
  "productOutOfStock": "Out of stock",
  "orderPlacedSuccessfully": "Order placed successfully",
  "paymentFailed": "Payment failed",
  "shipmentInTransit": "Shipment is in transit",
  "selectLanguage": "Select language",
  "english": "English",
  "urdu": "Urdu"
}
```

Urdu:

```json
{
  "appName": "فارم ٹو فورک",
  "login": "لاگ ان",
  "logout": "لاگ آؤٹ",
  "addToCart": "کارٹ میں شامل کریں",
  "productOutOfStock": "اسٹاک ختم ہو گیا ہے",
  "orderPlacedSuccessfully": "آرڈر کامیابی سے دے دیا گیا",
  "paymentFailed": "ادائیگی ناکام ہو گئی",
  "shipmentInTransit": "شپمنٹ راستے میں ہے",
  "selectLanguage": "زبان منتخب کریں",
  "english": "انگریزی",
  "urdu": "اردو"
}
```

Agents may improve wording, but both locales must remain equivalent in meaning.

---

### 7.10 Messages With Variables

Agents must use placeholders for dynamic values.

Bad:

```dart
Text('${context.l10n.total}: $amount')
```

Good:

```dart
Text(context.l10n.totalAmount(amount))
```

Example ARB:

English:

```json
{
  "totalAmount": "Total: Rs {amount}",
  "@totalAmount": {
    "placeholders": {
      "amount": {
        "type": "num"
      }
    }
  }
}
```

Urdu:

```json
{
  "totalAmount": "کل رقم: {amount} روپے",
  "@totalAmount": {
    "placeholders": {
      "amount": {
        "type": "num"
      }
    }
  }
}
```

Rules:

```text
- Do not manually concatenate translated strings.
- Use placeholders for names, amounts, counts, dates, order numbers, and statuses.
- Keep placeholder names identical across English and Urdu ARB files.
```

---

### 7.11 Pluralization Rules

For count-based messages, agents must use ICU plural syntax where needed.

Example:

```json
{
  "cartItemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
}
```

Urdu must provide equivalent behavior.

Rules:

```text
- Do not manually write if/else text for singular/plural labels in widgets.
- Use localized plural messages for counts.
- Use placeholders consistently.
```

---

### 7.12 Enum and Status Localization

Backend enum values must not be displayed directly.

Bad:

```dart
Text(order.status)
```

Good:

```dart
Text(orderStatusLabel(context, order.status))
```

Agents must localize these enum/status groups:

```text
User roles
Product status
Product category if displayed as label
Quality grade if displayed descriptively
Order status
Payment status
Shipment status
Loan application status
Notification type
Post status
Comment status
Prediction type
Season
Vehicle type
Business type
Institution type
Blockchain transaction type
Supply-chain event type
```

Example mapping:

```dart
String orderStatusLabel(BuildContext context, OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => context.l10n.orderStatusPending,
    OrderStatus.paid => context.l10n.orderStatusPaid,
    OrderStatus.processing => context.l10n.orderStatusProcessing,
    OrderStatus.shipped => context.l10n.orderStatusShipped,
    OrderStatus.delivered => context.l10n.orderStatusDelivered,
    OrderStatus.cancelled => context.l10n.orderStatusCancelled,
  };
}
```

Agents must not expose raw backend values such as:

```text
under_review
in_transit
sold_out
financial_partner
```

directly in the UI.

---

### 7.13 RTL Layout Rules for Urdu

Urdu requires RTL layout support.

Agents must test every major screen in Urdu.

Rules:

```text
- Use Directionality-aware widgets where needed.
- Prefer EdgeInsetsDirectional over EdgeInsets when start/end matters.
- Prefer AlignmentDirectional over Alignment when start/end matters.
- Avoid hardcoded left/right positioning.
- Avoid fixed-width text containers.
- Product cards must handle Urdu text expansion.
- Buttons must handle longer Urdu labels.
- Navigation labels must not overflow.
- App bars must look correct in RTL.
- Form labels and hints must align naturally.
```

Bad:

```dart
padding: EdgeInsets.only(left: 16, right: 8)
alignment: Alignment.centerLeft
```

Better:

```dart
padding: EdgeInsetsDirectional.only(start: 16, end: 8)
alignment: AlignmentDirectional.centerStart
```

Agents must not force LTR unless the content truly requires it.

Allowed LTR exceptions:

```text
Email addresses
Phone numbers
URLs
Tracking IDs
Order IDs
Payment references
QR codes
Technical codes
```

These exceptions should be handled carefully inside otherwise RTL screens.

---

### 7.14 Urdu Text Quality Rules

Agents must not blindly generate awkward Urdu.

Rules:

```text
- Urdu should be simple, readable, and user-friendly.
- Avoid overly formal government-document Urdu unless the screen requires it.
- Keep marketplace actions clear.
- Avoid mixed English unless the term is commonly understood or brand-specific.
- Keep Farm2Fork brand name consistent.
```

Preferred tone:

```text
Clear
Practical
Friendly
Not overly poetic
Not overly technical
```

Agents must flag uncertain translations for human review instead of pretending machine-translated Urdu is divine revelation.

---

### 7.15 Validation Message Localization

All form validation messages must be localized.

Required areas:

```text
Login
Register
Phone number
Password
CNIC
Address
Product creation
Quantity
Price
Loan amount
Vehicle details
Bank account details
Payment form
Shipment status update
Community posts/comments
```

Bad:

```dart
validator: (value) => 'Required'
```

Good:

```dart
validator: (value) =>
  value == null || value.isEmpty ? context.l10n.validationRequired : null
```

Agents must add both English and Urdu keys for every validation message.

---

### 7.16 Error, Empty, and Loading State Localization

Every screen must localize:

```text
Loading message
Empty state title
Empty state description
Retry button
Error title
Error description
Success message
SnackBar text
Dialog text
```

Bad:

```dart
Center(child: Text('No products found'))
```

Good:

```dart
Center(child: Text(context.l10n.noProductsFound))
```

Agents must not leave temporary English error messages in production UI.

---

### 7.17 Date, Time, Number, and Currency Formatting

Agents must not manually format user-facing dates, numbers, or money values with string concatenation.

Rules:

```text
- Currency must be displayed consistently in PKR/Rs.
- Dates must be formatted through localization-aware utilities.
- Large numbers must be readable.
- Avoid raw ISO date strings in UI.
- Avoid raw backend numeric values without formatting.
```

Bad:

```dart
Text('Rs ' + amount.toString())
Text(order.createdAt.toString())
```

Better:

```dart
Text(context.l10n.priceAmount(formatCurrency(amount)))
Text(formatDate(order.createdAt, locale))
```

Agents should place formatting helpers in:

```text
core/utils/
core/localization/
```

---

### 7.18 Language-Aware API Rules

When useful, selected app language may be sent to backend APIs.

Recommended header:

```text
Accept-Language: en
Accept-Language: ur
```

Rules:

```text
- Dio interceptor may attach selected locale.
- Backend-provided localized messages should still be handled safely.
- Frontend must not depend entirely on backend for basic UI strings.
```

---

### 7.19 Localization Testing Checklist

Agents must verify localization before finishing UI tasks:

```text
[ ] No hardcoded visible strings
[ ] English ARB updated
[ ] Urdu ARB updated
[ ] Placeholder names match in both ARB files
[ ] Urdu RTL layout checked
[ ] Long Urdu labels do not overflow
[ ] Buttons handle both languages
[ ] Form validation messages are localized
[ ] Empty/error/loading states are localized
[ ] Backend enum values are mapped to localized labels
[ ] Language toggle still works after changes
[ ] Selected language persists after restart
```

---

## 8. UI/UX Rules

The UI must be clean, responsive, and suitable for an agriculture/marketplace app.

Rules:

```text
- ONLY use the existing theme tokens for the UI (AppColors, AppTextStyles, AppSizes, etc.). Do NOT invent or hardcode custom colors or typographies (e.g., no random Color(0xFF...) or one-off TextStyles).
- Every single user-visible string MUST be completely localized/translated in the ARB files (lib/l10n/app_en.arb and lib/l10n/app_ur.arb). Hardcoded English or Urdu strings in widgets are strictly forbidden.
- Use app theme tokens for colors, spacing, radius, and typography.
- Do not scatter magic numbers everywhere.
- Use reusable widgets.
- Every screen must handle loading, error, empty, and success states.
- Every screen must work on small Android phones and iOS simulators.
- Forms must validate input before submission.
- Product cards must handle missing image, long name, price, unit, quality grade, and stock status.
- Order screens must show items, farmer, totals, platform fee, grand total, status, payment, and shipment state.
- Shipment screens must show timeline from real statusHistory.

Agents must not build UI directly against fake maps or raw JSON.
```

## Design Philosophy — Locked

The Figma file is a design direction and visual reference, not a strict pixel-perfect final specification.

Agents must use the Figma file to understand:
- visual mood
- color direction
- typography direction
- component patterns
- spacing tendencies
- screen structure
- marketplace/agriculture/trust/blockchain visual language

Agents must not blindly copy Figma values when they create poor Flutter implementation.

The final Flutter UI should be:
- cleaner than the rough Figma if needed
- responsive
- maintainable
- localized for English and Urdu
- RTL-safe
- consistent with the app theme
- usable on real Android/iOS devices
- based on reusable components, not one-off copied layouts

Figma is the starting point. The coded app is the source of truth once implementation begins.

## How agents should treat your Figma

Give them this hierarchy:

```

1. Business rules and schema
2. Localization and RTL requirements
3. Flutter architecture and maintainability
4. Reusable design system tokens
5. Figma visual direction
6. Pixel-level Figma details

```

That means if Figma says `Background Light = #FFC107`, but that looks insane as an app background, the agent should not blindly obey it. It should flag it and use the token carefully.

## Theme and Design System Rules — Practical Version

The Farm2Fork Figma file contains early design thinking, visual ideas, color direction, typography direction, and component inspiration.

It is not a final pixel-perfect design specification.

Agents must use Figma as the visual baseline but are allowed to improve implementation details when needed for:
- responsiveness
- localization
- Urdu RTL support
- accessibility
- maintainability
- visual consistency
- Flutter best practices
- real-device usability

Agents must preserve the overall design language:
- modern agricultural marketplace
- clean card-based UI
- green primary actions
- light surfaces
- rounded cards and buttons
- trust and verification visual cues
- blockchain/traceability elements where relevant
- simple, readable typography
- marketplace-first user experience

Agents must not:
- blindly copy every absolute position from Figma
- hardcode one-off colors inside widgets
- hardcode one-off font sizes inside widgets
- create separate styling per screen
- treat rough Figma layouts as final
- ignore mobile constraints
- ignore Urdu text expansion
- ignore RTL layout behavior

The implemented Flutter design system is the source of truth once created.
Figma remains the inspiration/reference.

## UI Implementation Guidance for Agents

When implementing UI from Figma:

1. Read the relevant Figma frame for visual direction.
2. Identify reusable patterns before coding.
3. Implement using Flutter layout widgets, not absolute positioning.
4. Use project theme tokens.
5. Use localized strings only.
6. Support English and Urdu.
7. Check RTL behavior.
8. Prefer responsive layouts over fixed dimensions.
9. If Figma details conflict with usability or maintainability, improve the coded version and explain the change.
10. The final Flutter implementation may refine the Figma idea.

### Practical design workflow

Step 1: Lock rough visual tokens
Use the Figma tokens as a first draft:

```

Primary green
Accent yellow
Surface color
Text dark
Open Sans
Card radius
Button radius
Page padding

```

Step 2: Build reusable Flutter components
Start with:

```

AppButton
AppCard
AppBadge
AppTextField
AppSectionHeader
ProductCard
OrderCard
StatusChip

```

Step 3: Build one real screen
Start with **MarketPlace** because it is core.
Build it with mock data and localization.

Step 4: Review visually
You look at the running app and say:

```

This card feels too tall.
This button is too bright.
Urdu text breaks here.
Spacing looks cheap.
This status chip needs better color.

```

Then fix the design system tokens/components, not every screen manually.

Step 5: Agents update components globally
If the card radius changes, agents update `AppRadius`.
If button height changes, agents update `AppButton`.
If heading size changes, agents update `AppTextStyles`.

The correct mindset
Your Figma is:

```

visual sketch + product mood + layout reference

```

Your Flutter code becomes:

```

actual design system + implementation source of truth

```

That is not a weakness. That is a sane developer-led design process. Just don’t let the agents freestyle too much. They need a leash, a map, and occasionally a rolled-up newspaper.

Agents must not build UI directly against fake maps or raw JSON.

---

## 9. Riverpod Rules

Use Riverpod consistently.

Preferred flow:

```text
Widget
  → Provider
    → Repository
      → API Service
        → Dio Client
```

Rules:

```text
- Do not put business logic inside widgets.
- Do not call Dio directly from widgets.
- Providers must live near their feature.
- Do not create global providers for feature-specific state.
- Async providers must expose loading/error/data states.
- Errors must not be swallowed silently.
```

---

## 10. Routing Rules

Use go_router.

Rules:

```text
- Define routes centrally or through approved feature route modules.
- Use named routes where practical.
- Auth redirects must be centralized.
- Validate route parameters.
- Prefer passing IDs through routes instead of full model objects.
- Do not use random Navigator.push calls for normal app navigation.
```

Suggested route groups:

```text
/auth/login
/auth/register
/marketplace
/products/:id
/cart
/orders
/orders/:id
/payments/:id
/shipments/:id
/loans
/community
/notifications
/profile
/settings
```

---

## 11. Networking Rules

Use Dio through a centralized API client.

Rules:

```text
- Do not create Dio instances inside widgets.
- Use interceptors for auth tokens, locale headers, and common errors.
- API services return typed models.
- Repositories expose app-friendly methods.
- UI must not know endpoint URLs.
- Handle timeout, unauthorized, validation, and server errors consistently.
```

Sensitive data must not be logged.

---

## 12. Mock Data Rules

Mock data is allowed during early development.

Rules:

```text
- Mock data must use typed models.
- Mock data must live in clearly named mock files.
- Mock data must follow schema constraints.
- Mock cart data must respect one-order-one-farmer.
- Do not mix mock data inside production repositories.
```

Allowed:

```text
lib/features/marketplace/data/mock/mock_products.dart
```

Not allowed:

```dart
Text(fakeJson['product']['name'])
```

---

## 13. Security and Privacy Rules

Treat these fields as sensitive:

```text
CNIC
Bank account details
Password hash
FCM token
Gateway reference
Audit metadata
License number
Uploaded documents
Blockchain payload internals
```

Rules:

```text
- Do not log sensitive data.
- Mask CNIC and bank account numbers where shown.
- Do not expose raw audit logs to non-admin users.
- Do not expose raw blockchain payloads to normal users.
- Do not store sensitive data in plain local storage.
```

---

## 14. Testing Rules

Agents must add or update tests when business logic changes.

Required test areas:

```text
Model JSON parsing
Order grouping by farmer
Cart subtotal and total calculation
Platform fee display
Payment status mapping
Shipment timeline mapping
Localization keys
Auth redirect behavior
Product availability behavior
Form validation
```

For localization-sensitive UI, agents must test both English and Urdu where practical.

---

## 15. Recommended Implementation Order

Agents should follow this order:

```text
1. Project foundation
2. Theme setup
3. Localization setup and language toggle
4. Routing shell
5. Core network layer
6. Auth models
7. User/profile models
8. Product/marketplace models
9. Mock repositories
10. Marketplace home UI
11. Product details UI
12. Cart grouped by farmer
13. Order creation flow
14. Payments
15. Shipments
16. Notifications
17. Loan applications
18. Community posts/comments
19. AI predictions
20. Blockchain traceability screens
21. Admin/system config screens
```

Agents must not begin with AI, blockchain, or payment screens before the core marketplace/order flow is stable.

---

## 16. Agent Completion Checklist

Before finishing any task, agents must verify:

```text
[ ] Feature-first architecture preserved
[ ] No business logic inside widgets
[ ] No raw JSON parsing inside widgets
[ ] No hardcoded user-facing strings
[ ] English ARB updated
[ ] Urdu ARB updated
[ ] RTL layout considered
[ ] Models use Freezed/json_serializable
[ ] Generated files were not manually edited
[ ] build_runner was run if generated files changed
[ ] dart format was run
[ ] flutter analyze passes
[ ] Tests were added/updated when logic changed
[ ] No unrelated packages were added
[ ] No schema fields were renamed without approval
[ ] One-order-one-farmer rule preserved
[ ] Sensitive fields are not logged or exposed
```

Required commands when relevant:

```bash
dart format .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test
```

---

## 17. Forbidden Agent Behavior

Agents must never:

```text
- Change the approved database schema silently
- Rename backend fields without approval
- Add another state-management package
- Put API calls inside widgets
- Parse JSON inside widgets
- Hardcode English strings
- Hardcode Urdu strings
- Ignore RTL layout
- Edit generated files manually
- Store sensitive data insecurely
- Add random packages without justification
- Mix mock and production data sources
- Create duplicate models for the same backend entity
- Use raw dynamic where typed models are possible
- Display backend enum values directly
- Build one checkout order containing products from multiple farmers
- Start with payment/blockchain/AI before core marketplace flow
```

---

## 18. Standard Agent Prompt Template

Use this when assigning work to a coding agent:

```text
You are working on the Farm2Fork Flutter mobile app.

Before coding, read and follow the Farm2Fork Agent Development Ruleset v1.1.

Task:
<describe task>

Constraints:
- Use existing feature-first architecture.
- Use Riverpod, go_router, Dio, Freezed, json_serializable.
- Use flutter_localizations + intl + ARB files.
- Do not add new packages unless necessary and explained.
- Do not hardcode user-facing strings.
- Add/update both English and Urdu localization keys.
- Preserve RTL support.
- Do not change backend schema fields.
- Do not edit generated files manually.
- Run build_runner if models are changed.
- Run dart format and flutter analyze before finishing.

Expected output:
- Files changed
- What was implemented
- Localization keys added/updated
- Assumptions made
- Commands run
- Remaining issues, if any
```

---

## 19. First Milestone

The first milestone should be:

```text
Farm2Fork app shell with theme, localization, in-app language toggle, routing, typed models, mock marketplace data, product listing, product details, and cart grouped by farmer.
```

Core marketplace flow comes first.

Payment, blockchain, loan applications, AI predictions, and admin screens come later.
