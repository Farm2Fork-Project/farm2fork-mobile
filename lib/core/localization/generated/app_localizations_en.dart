// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Farm2Fork';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get urdu => 'Urdu';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get navListings => 'Listings';

  @override
  String get navCreateListing => 'Create';

  @override
  String get navTrace => 'Trace';

  @override
  String get navShipments => 'Shipments';

  @override
  String get navLoans => 'Loans';

  @override
  String get navFeed => 'Feed';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noDataFound => 'No data found.';

  @override
  String get loading => 'Loading...';

  @override
  String get featureComingSoon => 'Coming soon';

  @override
  String get traceScannerTitle => 'Scan & Trace';

  @override
  String get traceScannerDescription =>
      'Scan a product QR code to verify origin, farmer, order journey, shipment updates, and blockchain records.';

  @override
  String get paymentOptionsNote =>
      'Payments will support multiple options such as cash, JazzCash, and other gateways once the provider is finalized.';

  @override
  String get authWelcomeTitle => 'Farm2Fork Access';

  @override
  String get authWelcomeSubtitle =>
      'Choose the account role you want to preview. Real login will connect here after the backend auth module is ready.';

  @override
  String get chooseYourRole => 'Choose your role';

  @override
  String continueAsRole(String role) {
    return 'Continue as $role';
  }

  @override
  String get roleFarmer => 'Farmer';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleTransporter => 'Transporter';

  @override
  String get roleFinancialPartner => 'Financial Partner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get farmerRoleDescription =>
      'Manage produce listings, orders, and community updates.';

  @override
  String get buyerRoleDescription =>
      'Buy fresh produce, scan QR codes, and track your orders.';

  @override
  String get transporterRoleDescription =>
      'View shipment tasks and update delivery progress.';

  @override
  String get financialPartnerRoleDescription =>
      'Review loan requests and farmer finance activity.';

  @override
  String get adminRoleDescription =>
      'Monitor marketplace, orders, finance, and platform activity.';

  @override
  String signedInAsRole(String role) {
    return 'Signed in as $role';
  }

  @override
  String get listingsTitle => 'My Listings';

  @override
  String get listingsDescription =>
      'Review active produce listings, update stock, and manage farm inventory.';

  @override
  String get createListingTitle => 'Create Listing';

  @override
  String get createListingDescription =>
      'Add crop details, quantity, grade, price, and harvest information for buyers.';

  @override
  String get feedTitle => 'Farm Feed';

  @override
  String get feedDescription =>
      'Share updates, ask questions, and follow trusted activity across the Farm2Fork network.';

  @override
  String get shipmentsTitle => 'Shipments';

  @override
  String get shipmentsDescription =>
      'Track assigned pickups, delivery status, and QR-linked shipment movement.';

  @override
  String get loansTitle => 'Loans';

  @override
  String get loansDescription =>
      'Review farmer finance requests, repayment status, and partner decisions.';

  @override
  String get changeLanguage => 'تبدیل کریں (Change Language)';

  @override
  String get allCategories => 'All';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryGrains => 'Grains';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get searchHint => 'Search products, farms...';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get productDetails => 'Product Details';

  @override
  String get farmerInfo => 'Farmer Info';

  @override
  String priceAmountWithUnit(String amount, String unit) {
    return 'Rs $amount / $unit';
  }

  @override
  String currencyAmount(String amount) {
    return 'Rs $amount';
  }

  @override
  String quantityAmountWithUnit(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitTon => 'ton';

  @override
  String get unitDozen => 'dozen';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitLitre => 'litre';

  @override
  String get quantity => 'Quantity';

  @override
  String get description => 'Description';

  @override
  String get qualityGrade => 'Quality Grade';

  @override
  String qualityGradeWithValue(String grade) {
    return 'Quality Grade: $grade';
  }

  @override
  String get gradeA => 'A';

  @override
  String get gradeB => 'B';

  @override
  String get gradeC => 'C';

  @override
  String get yourCart => 'Your Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Browse the marketplace and add fresh produce.';

  @override
  String get shopNow => 'Shop Now';

  @override
  String get subtotal => 'Subtotal';

  @override
  String platformFeeWithPercent(String percent) {
    return 'Platform Fee ($percent%)';
  }

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get checkout => 'Checkout';

  @override
  String checkoutForFarmer(String farmerName) {
    return 'Checkout for $farmerName';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get city => 'City';

  @override
  String get province => 'Province';

  @override
  String get zipCode => 'Postal Code';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String orderForFarmer(String farmerName) {
    return 'Order for $farmerName';
  }

  @override
  String get separateOrdersNote =>
      'Items from different farmers are placed as separate orders.';

  @override
  String placeOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Place $count Orders',
      one: 'Place 1 Order',
    );
    return '$_temp0';
  }

  @override
  String ordersPlacedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders placed successfully',
      one: '1 order placed successfully',
    );
    return '$_temp0';
  }

  @override
  String get orderPlacementFailed =>
      'Could not place your order. Please try again.';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentPending => 'Payment pending';

  @override
  String get paymentPendingDescription =>
      'Your payment was created and is waiting for confirmation.';

  @override
  String paymentOrdersReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders are ready for payment',
      one: '1 order is ready for payment',
    );
    return '$_temp0';
  }

  @override
  String get completeTestPayment => 'Complete test payment';

  @override
  String get paymentComplete => 'Payment complete';

  @override
  String paymentCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order payments completed',
      one: '1 order payment completed',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Payment could not be completed';

  @override
  String paymentFailedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order payments failed',
      one: '1 order payment failed',
    );
    return '$_temp0';
  }

  @override
  String get viewOrders => 'View orders';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get removeItem => 'Remove';

  @override
  String get itemRemoved => 'Item removed';

  @override
  String get rating => 'Rating';

  @override
  String get soldBy => 'Sold by';

  @override
  String get location => 'Location';

  @override
  String totalSales(int count) {
    return '$count sales';
  }

  @override
  String get productStatusActive => 'Available';

  @override
  String get productStatusInactive => 'Inactive';

  @override
  String get productStatusSoldOut => 'Sold out';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get emailOrPhone => 'Email / Phone';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get invalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get signUpSuccess => 'Account created! You are now logged in.';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please login again.';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginToAddToCart =>
      'Login or create an account to add products to your cart.';

  @override
  String get loginToCheckout => 'Login or create an account to checkout.';

  @override
  String get loginToViewOrders =>
      'Login or create an account to view your orders.';

  @override
  String get loginToViewProfile =>
      'Login or create an account to manage your profile.';

  @override
  String get authRequiredDismiss => 'Continue browsing';

  @override
  String get authOr => 'or';

  @override
  String get signUpSelectRole => 'I want to...';

  @override
  String get signUpName => 'Full Name';

  @override
  String get signUpPhone => 'Phone Number';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get farmInfo => 'Farm Information';

  @override
  String get farmName => 'Farm Name';

  @override
  String get farmLocation => 'Farm Location';

  @override
  String get farmSize => 'Farm Size (acres)';

  @override
  String get cropTypes => 'Crop Types';

  @override
  String get certifications => 'Certifications (optional)';

  @override
  String get vehicleInfo => 'Vehicle Information';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get vehicleLicense => 'Vehicle License Number';

  @override
  String get serviceArea => 'Service Area';

  @override
  String get cnic => 'CNIC (optional)';

  @override
  String get availabilityStatus => 'Availability';

  @override
  String stepNofM(int n, int m) {
    return 'Step $n of $m';
  }

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get welcomeToFarm2Fork => 'Welcome to Farm2Fork';

  @override
  String get guestWelcomeSubtitle =>
      'Login or create an account to access your orders, cart, and full profile.';

  @override
  String get devTestAccounts => 'Dev test accounts';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get languageDisplay => 'Language & Display';

  @override
  String get fontSize => 'Font Size';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get faqs => 'FAQs';

  @override
  String get aboutUs => 'About Us';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get appSettings => 'App Settings';

  @override
  String get helpInformation => 'Help & Information';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Choose how you want to be notified';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderUpdatesDesc => 'Get notified when order status changes';

  @override
  String get shipmentUpdates => 'Shipment Alerts';

  @override
  String get shipmentUpdatesDesc => 'Track active shipments in real-time';

  @override
  String get communityAlerts => 'Community Updates';

  @override
  String get communityAlertsDesc => 'Get alerts on new posts and comments';

  @override
  String get marketingAlerts => 'Promotional Messages';

  @override
  String get marketingAlertsDesc =>
      'Stay updated on discounts and marketplace campaigns';

  @override
  String get languageDisplayTitle => 'Language & Display';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeXLarge => 'Extra Large';

  @override
  String get textScalePreview => 'Font Size Preview Text';

  @override
  String get textScalePreviewDesc =>
      'This is a sample sentence to see how font scaling affects readability across the application.';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get contactUsSubtitle => 'Get in touch with support team';

  @override
  String get contactSubject => 'Subject';

  @override
  String get contactSubjectGeneral => 'General Inquiry';

  @override
  String get contactSubjectListing => 'Listing Assistance';

  @override
  String get contactSubjectPayment => 'Payment Issue';

  @override
  String get contactSubjectTransport => 'Transportation Support';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactMessageHint => 'Describe your request in detail...';

  @override
  String get contactSubmit => 'Submit Inquiry';

  @override
  String get contactEmail => 'Support Email';

  @override
  String get contactPhone => 'Toll-Free Helpline';

  @override
  String get contactAddress => 'Headquarters Address';

  @override
  String get contactMessageSuccess =>
      'Your inquiry has been submitted successfully!';

  @override
  String get pleaseEnterMessage => 'Please enter your message';

  @override
  String get faqsTitle => 'Frequently Asked Questions';

  @override
  String get faqCategoryGeneral => 'General';

  @override
  String get faqCategoryMarketplace => 'Marketplace';

  @override
  String get faqCategorySecurity => 'Security';

  @override
  String get faqCategoryTransport => 'Delivery';

  @override
  String get faqQ1 => 'How does Farm2Fork work?';

  @override
  String get faqA1 =>
      'Farm2Fork connects farmers directly with buyers and transporters. Farmers list crops, buyers purchase them, and transporters deliver them, eliminating middlemen.';

  @override
  String get faqQ2 => 'Is my payment secure?';

  @override
  String get faqA2 =>
      'Yes. Farm2Fork uses verified payment escrow models (JazzCash, Bank transfers) where funds are safely released only upon successful cargo delivery.';

  @override
  String get faqQ3 => 'What is the platform fee?';

  @override
  String get faqA3 =>
      'The platform charges a small fee (up to 5%) on successful transactions to cover payment gateway costs, system maintenance, and support.';

  @override
  String get faqQ4 => 'How do transporters register?';

  @override
  String get faqA4 =>
      'Transporters can sign up in the app by selecting the Transporter role and entering their vehicle details, area of service, and license information.';

  @override
  String get aboutUsTitle => 'About Us';

  @override
  String get aboutUsContent =>
      'Farm2Fork is an agri-tech initiative built to empower local farmers, bypass predatory middlemen, and guarantee fresh produce for buyers. By securing transactions through transparent blockchain-grade ledger records, we build direct, trustworthy, and efficient supply networks.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'At Farm2Fork, we value your privacy. We collect profile details (name, email, phone number) and location data solely to facilitate transactions, listing maps, and shipment tracking. Transaction details are securely recorded to audit delivery steps, and we never sell user data to third parties.';

  @override
  String get termsConditionsTitle => 'Terms & Conditions';

  @override
  String get termsConditionsContent =>
      'By using the Farm2Fork application, you agree to fulfill order commitments. Farmers must guarantee correct quality grades, buyers must settle balances upon checkout, and transporters must complete delivery routes securely. Platform fee calculations are fixed by system rules and are non-refundable.';
}
