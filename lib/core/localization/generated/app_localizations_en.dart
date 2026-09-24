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
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You\'ll need to sign in again to access your account.';

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
  String get navShipments => 'History';

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
  String get traceScannerTitle => 'Trace produce';

  @override
  String get traceScannerDescription =>
      'Enter a product ID or paste the link from a Farm2Fork QR code to see where the produce came from and each step recorded on the blockchain ledger.';

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
  String get listingStepProduceDetails => 'Produce Details';

  @override
  String get listingStepPricingQuantity => 'Pricing & Quantity';

  @override
  String get produceName => 'Produce Name';

  @override
  String get produceNameHint => 'e.g., Organic Tomatoes';

  @override
  String get category => 'Category';

  @override
  String get descriptionHint =>
      'Describe freshness, farming practices, harvest date, etc.';

  @override
  String get priceWithCurrency => 'Price (PKR)';

  @override
  String get priceHint => 'e.g., 150';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get quantityHint => 'e.g., 250';

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get unit => 'Unit';

  @override
  String get feedTitle => 'Farm Feed';

  @override
  String get feedDescription =>
      'Share updates, ask questions, and follow trusted activity across the Farm2Fork network.';

  @override
  String feedCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Comments',
      one: '1 Comment',
    );
    return '$_temp0';
  }

  @override
  String get feedCommentsTitle => 'Comments';

  @override
  String get feedNoCommentsYet => 'No comments yet.';

  @override
  String get feedAddCommentHint => 'Add a comment...';

  @override
  String get shipmentsTitle => 'Shipments';

  @override
  String get shipmentsDescription =>
      'Track assigned pickups, delivery status, and QR-linked shipment movement.';

  @override
  String get availableDeliveries => 'Available deliveries';

  @override
  String get myDeliveries => 'My deliveries';

  @override
  String get deliveryRequest => 'Delivery request';

  @override
  String deliveryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get claimDelivery => 'Claim delivery';

  @override
  String get shipmentTracking => 'Shipment tracking';

  @override
  String get shipmentTimeline => 'Shipment timeline';

  @override
  String get shipmentAssigned => 'Assigned';

  @override
  String get shipmentPickedUp => 'Picked up';

  @override
  String get shipmentInTransit => 'In transit';

  @override
  String get shipmentDelivered => 'Delivered';

  @override
  String get shipmentFailed => 'Failed';

  @override
  String get trackDelivery => 'Track delivery';

  @override
  String shipmentNumber(String id) {
    return 'Shipment #$id';
  }

  @override
  String get pickupFarm => 'Pickup farm';

  @override
  String get deliveryDestination => 'Delivery destination';

  @override
  String get confirmPickup => 'Confirm crop pickup';

  @override
  String get startTransit => 'Depart — in transit';

  @override
  String get confirmDelivery => 'Confirm final delivery';

  @override
  String shipmentStatusUpdate(String status) {
    return 'Transporter updated status to $status.';
  }

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
  String get clearCart => 'Clear cart';

  @override
  String get clearCartConfirmTitle => 'Clear cart?';

  @override
  String get clearCartConfirmMessage =>
      'This removes every item from your cart. This can\'t be undone.';

  @override
  String get cancel => 'Cancel';

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
  String get ordersTabActive => 'Active';

  @override
  String get ordersTabCompleted => 'Completed';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusPaid => 'Paid';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

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
      'Your payment was created and is waiting for confirmation. This screen doesn\'t update automatically — check back or refresh to see the latest status.';

  @override
  String get checkPaymentStatus => 'Check payment status';

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
  String get deleteListingConfirmTitle => 'Delete listing?';

  @override
  String get deleteListingConfirmMessage =>
      'This removes the listing from the marketplace. This can\'t be undone.';

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
  String get enterEmailFirst => 'Enter your email address first.';

  @override
  String get passwordResetSentNote =>
      'If an account exists, we\'ve sent a password-reset email.';

  @override
  String get verifyYourEmailTitle => 'Verify your email';

  @override
  String get verifyYourEmailBodyGeneric =>
      'Open the verification link we sent to your email, then return here.';

  @override
  String verifyYourEmailBody(String email) {
    return 'Open the verification link we sent to $email, then return here.';
  }

  @override
  String get verificationResentNote =>
      'A new verification email has been sent.';

  @override
  String get verificationStillPendingNote =>
      'Your email is not verified yet. Check your inbox, then try again.';

  @override
  String get iHaveVerifiedMyEmail => 'I have verified my email';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signUpWithEmail => 'Sign up with email';

  @override
  String get onboardingCompleteProfile => 'Complete your profile';

  @override
  String get onboardingProfileSubtitle =>
      'Tell us a bit about you to finish setting up.';

  @override
  String get email => 'Email';

  @override
  String get fieldCnic => 'CNIC';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessType => 'Business Type';

  @override
  String get selectBusinessType => 'Select business type';

  @override
  String get businessTypeIndividual => 'Individual';

  @override
  String get businessTypeRetailer => 'Retailer';

  @override
  String get businessTypeRestaurant => 'Restaurant';

  @override
  String get businessTypeWholesaler => 'Wholesaler';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get selectVehicleType => 'Select vehicle type';

  @override
  String get vehicleTypeBike => 'Bike';

  @override
  String get vehicleTypeRickshaw => 'Rickshaw';

  @override
  String get vehicleTypeVan => 'Van';

  @override
  String get vehicleTypeTruck => 'Truck';

  @override
  String get cropTypesHint => 'e.g. wheat, rice, mango';

  @override
  String get serviceAreasHint => 'e.g. Lahore, Faisalabad';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationCnicInvalid =>
      'Enter a valid CNIC (e.g. 35202-1234567-1)';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationPasswordShort =>
      'Password must be at least 8 characters';

  @override
  String get authErrorEmailInUse =>
      'This email already has an account. Try signing in.';

  @override
  String get authErrorWeakPassword => 'Choose a stronger password.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

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
  String get notificationsNotYetConnectedNote =>
      'Push notifications for orders, deliveries and loans are on for this device. These per-topic switches only apply for this session for now; to stop all notifications, turn them off in your phone\'s settings.';

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
      'Message noted. Our support inbox isn\'t connected yet, so please also email support@farm2fork.pk for a reply.';

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

  @override
  String get traceInputLabel => 'Product ID or QR link';

  @override
  String get traceInputHint => '6a2fe77bb77795516febc287';

  @override
  String get traceInvalidInput =>
      'That isn\'t a Farm2Fork product ID or QR link. Product IDs are 24 characters long.';

  @override
  String get traceSearchButton => 'Trace product';

  @override
  String get traceCameraComingSoon =>
      'Camera scanning is coming soon. For now, paste the product ID or the link printed with the QR code.';

  @override
  String get traceLoading => 'Loading journey…';

  @override
  String get traceLoadFailed =>
      'Couldn\'t load the journey. Check your connection and try again.';

  @override
  String get traceNotFoundTitle => 'No product found for this code';

  @override
  String get traceNotFoundDesc =>
      'Check the ID or scan the QR code again. Only Farm2Fork listings have a traceable journey.';

  @override
  String get traceSearchAnother => 'Trace another product';

  @override
  String get traceOriginVerified => 'Origin verified on ledger';

  @override
  String get traceOriginVerifiedDesc =>
      'The farmer\'s listing is committed to the Hyperledger Fabric ledger and can\'t be altered.';

  @override
  String get traceOriginPending => 'Origin awaiting ledger confirmation';

  @override
  String get traceOriginPendingDesc =>
      'The listing is recorded and queued for the ledger. It will show as verified once the commit is confirmed.';

  @override
  String get traceOriginMissing => 'No ledger record for this listing';

  @override
  String get traceOriginMissingDesc =>
      'This listing was created before ledger recording was enabled, so its origin can\'t be verified on-chain.';

  @override
  String get traceSourceFarm => 'Source farm';

  @override
  String get traceFarmUnknown => 'Farm details not provided';

  @override
  String get traceQualityGrade => 'Quality grade';

  @override
  String traceGradeValue(String grade) {
    return 'Grade $grade';
  }

  @override
  String get traceGradeNone => 'Not graded';

  @override
  String get traceListedOn => 'Listed on';

  @override
  String get traceProductId => 'Product ID';

  @override
  String get traceStatusActive => 'Available on the marketplace';

  @override
  String get traceStatusSoldOut => 'Sold out';

  @override
  String get traceStatusInactive => 'No longer listed';

  @override
  String get traceJourneyTitle => 'Supply chain journey';

  @override
  String traceLedgerProgress(int confirmed, int total) {
    return '$confirmed of $total recorded on ledger';
  }

  @override
  String get traceJourneyEmpty =>
      'Only the listing so far. Sales and deliveries will appear here as they happen.';

  @override
  String get traceEventListed => 'Listed on marketplace';

  @override
  String get traceEventPaymentConfirmed => 'Payment confirmed';

  @override
  String get traceEventShipmentAssigned => 'Transporter assigned';

  @override
  String get traceEventShipmentPickedUp => 'Picked up from farm';

  @override
  String get traceEventShipmentInTransit => 'In transit';

  @override
  String get traceEventShipmentDelivered => 'Delivered';

  @override
  String get traceEventShipmentFailed => 'Delivery failed';

  @override
  String get traceRoleFarmer => 'Farmer';

  @override
  String get traceRoleBuyer => 'Buyer';

  @override
  String get traceRoleTransporter => 'Transporter';

  @override
  String traceReferenceSale(String reference) {
    return 'Sale #$reference';
  }

  @override
  String traceReferenceDelivery(String reference) {
    return 'Delivery #$reference';
  }

  @override
  String get traceLedgerConfirmed => 'Recorded on ledger';

  @override
  String get traceLedgerPending => 'Awaiting ledger confirmation';

  @override
  String get traceLedgerFailed => 'Ledger recording failed';

  @override
  String traceLedgerBlock(int block) {
    return 'Block $block';
  }

  @override
  String get productViewJourney => 'View product journey';

  @override
  String get listingViewJourney => 'View journey';

  @override
  String get listingHide => 'Hide from marketplace';

  @override
  String get listingShow => 'Show on marketplace';

  @override
  String get listingDelete => 'Delete listing';

  @override
  String get listingPublished => 'Listing published';

  @override
  String get listingPublishFailed =>
      'Couldn\'t publish the listing. Your details are kept - check your connection and try again.';

  @override
  String get timeAm => 'AM';

  @override
  String get timePm => 'PM';

  @override
  String get aiPriceTitle => 'Fair price suggestion';

  @override
  String get aiSuggestPrice => 'Suggest a price';

  @override
  String aiPriceRange(String min, String max, String unit) {
    return 'Rs $min – $max per $unit';
  }

  @override
  String get aiPriceRuleBased =>
      'Rule-based estimate from reference ranges, season and grade — not live market data.';

  @override
  String aiUsePrice(String price) {
    return 'Use Rs $price';
  }

  @override
  String get aiPriceNoRule => 'No price rule covers this unit or category yet.';

  @override
  String get aiQualityTitle => 'Photo quality check';

  @override
  String get aiPreviewModel =>
      'Preview model: the grading model isn\'t trained yet, so its grades are not reliable.';

  @override
  String get aiCropLabel => 'Crop in the photo';

  @override
  String get aiNeedCrop => 'Select the crop in the photo.';

  @override
  String get aiTakePhoto => 'Take a photo';

  @override
  String get aiChoosePhoto => 'Choose from gallery';

  @override
  String aiGradeResult(String grade, int confidence) {
    return 'Grade $grade · $confidence% confidence';
  }

  @override
  String get aiPreviewResult =>
      'Preview only — don\'t rely on this grade until the model is trained.';

  @override
  String get aiCropNotTrained =>
      'The model has no training data for this crop yet.';

  @override
  String get aiLowConfidence => 'Low confidence — check the grade yourself.';

  @override
  String aiUseGrade(String grade) {
    return 'Use grade $grade';
  }

  @override
  String get aiGradeD =>
      'Below listing grades (D). Consider selling for processing.';

  @override
  String get aiUnavailable =>
      'The AI service isn\'t reachable right now. You can still publish your listing.';

  @override
  String get aiTooManyRequests =>
      'Too many requests. Please wait a minute and try again.';

  @override
  String get aiInvalidPhoto =>
      'That photo couldn\'t be used. Try a clear JPEG or PNG under 8 MB.';

  @override
  String get aiFailed => 'Something went wrong. Please try again.';

  @override
  String get cropWheat => 'Wheat';

  @override
  String get cropRice => 'Rice';

  @override
  String get cropMango => 'Mango';

  @override
  String get cropMaize => 'Maize';

  @override
  String get cropCotton => 'Cotton';

  @override
  String get cropSugarcane => 'Sugarcane';

  @override
  String get ledgerConfirmed => 'On ledger';

  @override
  String get ledgerPending => 'Ledger pending';

  @override
  String get ledgerFailed => 'Ledger failed';

  @override
  String get ledgerMissing => 'No ledger record';

  @override
  String get farmStreet => 'Street / village';

  @override
  String get farmStreetHint => 'e.g. Chak 5, Canal Road';

  @override
  String get farmCity => 'City / district';

  @override
  String get farmProvince => 'Province';

  @override
  String get farmProvinceHint => 'Select province';

  @override
  String get provincePunjab => 'Punjab';

  @override
  String get provinceSindh => 'Sindh';

  @override
  String get provinceKpk => 'Khyber Pakhtunkhwa';

  @override
  String get provinceBalochistan => 'Balochistan';

  @override
  String get provinceGilgitBaltistan => 'Gilgit-Baltistan';

  @override
  String get provinceAjk => 'Azad Jammu and Kashmir';

  @override
  String get provinceIslamabad => 'Islamabad Capital Territory';

  @override
  String get farmLocationPromptTitle => 'Add your farm\'s pickup location';

  @override
  String get farmLocationPromptBody =>
      'Transporters can\'t see or collect your orders until your farm\'s street, city and province are saved.';

  @override
  String get farmLocationSave => 'Save location';

  @override
  String get farmLocationSaveFailed =>
      'Couldn\'t save the location. Check your connection and try again.';

  @override
  String get pickFarmLocationTitle => 'Pin your farm';

  @override
  String get pickFarmLocationHint =>
      'Move the map so the pin sits on your farm gate. Transporters will navigate to this exact spot.';

  @override
  String get pickDropoffTitle => 'Pin the drop-off';

  @override
  String get pickDropoffHint =>
      'Move the map so the pin sits where the order should be delivered. The delivery fee is based on this spot.';

  @override
  String get useMyLocation => 'Use my current location';

  @override
  String get confirmLocation => 'Confirm this spot';

  @override
  String get locationOutsidePakistan =>
      'Please choose a location inside Pakistan.';

  @override
  String get locationServiceDisabled =>
      'Location is turned off on this phone. Turn it on to continue.';

  @override
  String get locationPermissionDenied =>
      'Farm2Fork needs location permission for this.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission is blocked. Allow it in Settings to continue.';

  @override
  String get locationUnavailable =>
      'Couldn\'t get your location. Move to open sky and try again.';

  @override
  String get openSettings => 'Settings';

  @override
  String get pinFarmOnMap => 'Pin farm on map';

  @override
  String get pinDropoffOnMap => 'Pin drop-off on map';

  @override
  String get pinSet => 'Location pinned';

  @override
  String get pinOpenMap => 'Open map';

  @override
  String get pinChange => 'Change';

  @override
  String get pinRequired => 'Pin the location on the map';

  @override
  String get deliveryFeePinFirst => 'Pin the drop-off to see the delivery fee.';

  @override
  String get deliveryFeeCalculating => 'Calculating delivery fee…';

  @override
  String get deliveryFeeUnavailable =>
      'Delivery can\'t be priced for this farm yet, so it can\'t be ordered right now.';

  @override
  String deliveryFeeWithDistance(String km) {
    return 'Delivery ($km km)';
  }

  @override
  String get navDeliveries => 'Deliveries';

  @override
  String get deliveriesTitle => 'Deliveries';

  @override
  String get deliveryHistoryTitle => 'Delivery history';

  @override
  String get noDeliveriesYet =>
      'No deliveries yet. Accepted deliveries will appear here.';

  @override
  String get youAreOnline => 'You\'re online';

  @override
  String get youAreOffline => 'You\'re offline';

  @override
  String onlineSubtitle(String km) {
    return 'You\'ll be offered paid orders from farms within $km km. Keep the app open so your location stays current.';
  }

  @override
  String get offlineSubtitle =>
      'Go online to receive delivery offers near you.';

  @override
  String get locationStaleWarning =>
      'Your location is out of date, so you may miss offers. Open the app to refresh it.';

  @override
  String get offlineHint =>
      'You\'re offline. Turn on the switch above to start receiving deliveries.';

  @override
  String noOffersNearby(String km) {
    return 'No deliveries within $km km right now. We\'ll notify you when one comes up.';
  }

  @override
  String get offersNearYou => 'Deliveries near you';

  @override
  String offerRoute(String farm, String from, String to) {
    return '$farm ($from) → $to';
  }

  @override
  String offerDistances(String toPickup, String trip) {
    return '$toPickup km to pickup · $trip km trip';
  }

  @override
  String get viewOnMap => 'Map';

  @override
  String get acceptDelivery => 'Accept';

  @override
  String get declineDelivery => 'Decline';

  @override
  String get offerNoLongerAvailable =>
      'This delivery is no longer available — someone else may have accepted it, or you\'re out of range.';

  @override
  String get dispatchActionFailed =>
      'That didn\'t work. Check your connection and try again.';

  @override
  String get dropoffApproximateNote =>
      'The drop-off is shown approximately (within about 1 km). You\'ll see the exact address after accepting.';

  @override
  String get activeDeliveryTitle => 'Your current delivery';

  @override
  String youEarn(String amount) {
    return 'You earn $amount';
  }

  @override
  String get navigateToPickup => 'Navigate to pickup';

  @override
  String get navigateToDropoff => 'Navigate to drop-off';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get myAccount => 'My account';

  @override
  String get newPost => 'New post';

  @override
  String get communityEmpty => 'No posts yet. Start the conversation!';

  @override
  String get communityActionFailed => 'That didn\'t work. Please try again.';

  @override
  String get communityRoleFarmer => 'Farmer';

  @override
  String get communityRoleBuyer => 'Buyer';

  @override
  String get communityRoleTeam => 'Farm2Fork team';

  @override
  String get postTitleLabel => 'Title';

  @override
  String get postContentLabel => 'What would you like to share?';

  @override
  String get postTagsLabel => 'Tags (optional)';

  @override
  String get postTagsHint => 'e.g. wheat, sowing';

  @override
  String postTooManyTags(int max) {
    return 'Use at most $max tags';
  }

  @override
  String postPhotosLabel(int max) {
    return 'Photos (up to $max)';
  }

  @override
  String get takePhoto => 'Camera';

  @override
  String get chooseFromGallery => 'Gallery';

  @override
  String get publishPost => 'Publish';

  @override
  String get remove => 'Remove';

  @override
  String get removePostConfirm => 'Remove this post for everyone?';

  @override
  String get removeCommentConfirm => 'Remove this comment?';

  @override
  String get send => 'Send';

  @override
  String get loanStatusPending => 'Submitted';

  @override
  String get loanStatusUnderReview => 'Under review';

  @override
  String get loanStatusApproved => 'Approved';

  @override
  String get loanStatusRejected => 'Not approved';

  @override
  String get loanStatusRepaid => 'Repaid';

  @override
  String get loansFarmerIntroTitle => 'Microfinance for your farm';

  @override
  String get loansFarmerIntroBody =>
      'Apply for seeds, fertiliser or equipment. A financial partner reviews your farm and Farm2Fork sales history, then approves a monthly repayment plan or explains why not.';

  @override
  String get loanApply => 'Apply for a loan';

  @override
  String get loanOneAtATime =>
      'You can have one application in progress or being repaid at a time.';

  @override
  String get loansNone => 'No applications yet.';

  @override
  String loanTermsSummary(int months, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0 · applied $date';
  }

  @override
  String loanReviewerNote(String note) {
    return 'Reviewer: $note';
  }

  @override
  String loanRepaidProgress(String paid, String total) {
    return 'Repaid $paid of $total';
  }

  @override
  String loanInstalment(int n, String amount) {
    return 'Instalment $n: $amount';
  }

  @override
  String loanDueOn(String date) {
    return 'Due $date';
  }

  @override
  String loanPaidOn(String date) {
    return 'Paid $date';
  }

  @override
  String get loanMarkPaid => 'Mark paid';

  @override
  String get loanAmountLabel => 'Amount (Rs)';

  @override
  String loanAmountRange(String min, String max) {
    return 'Between Rs $min and Rs $max';
  }

  @override
  String get loanDurationLabel => 'Repay over';

  @override
  String loanMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get loanPurposeLabel => 'What is the loan for?';

  @override
  String get loanPurposeHint =>
      'e.g. seeds and fertiliser for the wheat season';

  @override
  String get loanDocumentsLabel => 'Documents';

  @override
  String get loanDocumentsHint =>
      'Photos of your CNIC and land papers speed up the review. Only reviewers can see them.';

  @override
  String get loanSubmit => 'Submit application';

  @override
  String get loanSubmitted =>
      'Application submitted. We\'ll notify you when it\'s reviewed.';

  @override
  String get loanSubmitFailed =>
      'Couldn\'t submit. Check the amount and your connection, then try again.';

  @override
  String get loanFilterAll => 'All';

  @override
  String get loanQueueEmpty => 'No applications here.';

  @override
  String get loanReviewTitle => 'Loan application';

  @override
  String loanLandSize(String acres) {
    return 'Land: $acres acres';
  }

  @override
  String loanCrops(String crops) {
    return 'Crops: $crops';
  }

  @override
  String loanSalesHistory(int count, String revenue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count delivered orders · $revenue',
      one: '1 delivered order · $revenue',
      zero: 'No delivered orders yet',
    );
    return '$_temp0';
  }

  @override
  String loanDocumentN(int n) {
    return 'Document $n';
  }

  @override
  String get loanDocumentsExpire =>
      'Links expire after about 10 minutes; reopen the application for new ones.';

  @override
  String get loanStartReview => 'Start review';

  @override
  String get loanApprove => 'Approve';

  @override
  String get loanReject => 'Reject';

  @override
  String get loanRejectTitle => 'Reason for rejection';

  @override
  String get loanRejectHint => 'The farmer will see this';

  @override
  String get loanActionFailed => 'That didn\'t work. Refresh and try again.';
}
