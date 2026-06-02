import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Farm2Fork'**
  String get appName;

  /// Title for language selection screen/toggle
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Label for English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Label for Urdu language option
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// Button or title label for logging in
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Button or title label for logging out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// A general greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Label for the Marketplace epic/tab
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Label for the Cart epic/tab
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Label for the Orders epic/tab
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Label for the Profile epic/tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for the Settings epic/tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Bottom navigation label for Home/Marketplace
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label for Cart
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// Bottom navigation label for Orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// Bottom navigation label for Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom navigation label for farmer listings
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get navListings;

  /// Bottom navigation label for creating a listing
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreateListing;

  /// Bottom navigation label for QR traceability
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get navTrace;

  /// Bottom navigation label for shipments
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get navShipments;

  /// Bottom navigation label for loans
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get navLoans;

  /// Bottom navigation label for community feed
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// Button label for retrying an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Fallback text when lists or details are empty
  ///
  /// In en, this message translates to:
  /// **'No data found.'**
  String get noDataFound;

  /// Generic loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Placeholder title for future screens
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get featureComingSoon;

  /// QR traceability scanner screen title
  ///
  /// In en, this message translates to:
  /// **'Scan & Trace'**
  String get traceScannerTitle;

  /// QR traceability scanner placeholder description
  ///
  /// In en, this message translates to:
  /// **'Scan a product QR code to verify origin, farmer, order journey, shipment updates, and blockchain records.'**
  String get traceScannerDescription;

  /// Payment provider placeholder note
  ///
  /// In en, this message translates to:
  /// **'Payments will support multiple options such as cash, JazzCash, and other gateways once the provider is finalized.'**
  String get paymentOptionsNote;

  /// Title on the mock authentication role selection screen
  ///
  /// In en, this message translates to:
  /// **'Farm2Fork Access'**
  String get authWelcomeTitle;

  /// Subtitle on the mock authentication role selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose the account role you want to preview. Real login will connect here after the backend auth module is ready.'**
  String get authWelcomeSubtitle;

  /// Section heading for role selection
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseYourRole;

  /// Button label to continue as a selected role
  ///
  /// In en, this message translates to:
  /// **'Continue as {role}'**
  String continueAsRole(String role);

  /// User role label for farmers
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmer;

  /// User role label for buyers
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get roleBuyer;

  /// User role label for transporters
  ///
  /// In en, this message translates to:
  /// **'Transporter'**
  String get roleTransporter;

  /// User role label for financial partners
  ///
  /// In en, this message translates to:
  /// **'Financial Partner'**
  String get roleFinancialPartner;

  /// User role label for admins
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// Description for farmer role selection
  ///
  /// In en, this message translates to:
  /// **'Manage produce listings, orders, and community updates.'**
  String get farmerRoleDescription;

  /// Description for buyer role selection
  ///
  /// In en, this message translates to:
  /// **'Buy fresh produce, scan QR codes, and track your orders.'**
  String get buyerRoleDescription;

  /// Description for transporter role selection
  ///
  /// In en, this message translates to:
  /// **'View shipment tasks and update delivery progress.'**
  String get transporterRoleDescription;

  /// Description for financial partner role selection
  ///
  /// In en, this message translates to:
  /// **'Review loan requests and farmer finance activity.'**
  String get financialPartnerRoleDescription;

  /// Description for admin role selection
  ///
  /// In en, this message translates to:
  /// **'Monitor marketplace, orders, finance, and platform activity.'**
  String get adminRoleDescription;

  /// Profile label showing the current signed-in role
  ///
  /// In en, this message translates to:
  /// **'Signed in as {role}'**
  String signedInAsRole(String role);

  /// Farmer listings screen title
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get listingsTitle;

  /// Farmer listings placeholder description
  ///
  /// In en, this message translates to:
  /// **'Review active produce listings, update stock, and manage farm inventory.'**
  String get listingsDescription;

  /// Create produce listing screen title
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListingTitle;

  /// Create produce listing placeholder description
  ///
  /// In en, this message translates to:
  /// **'Add crop details, quantity, grade, price, and harvest information for buyers.'**
  String get createListingDescription;

  /// Community feed screen title
  ///
  /// In en, this message translates to:
  /// **'Farm Feed'**
  String get feedTitle;

  /// Community feed placeholder description
  ///
  /// In en, this message translates to:
  /// **'Share updates, ask questions, and follow trusted activity across the Farm2Fork network.'**
  String get feedDescription;

  /// Transporter shipments screen title
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get shipmentsTitle;

  /// Transporter shipments placeholder description
  ///
  /// In en, this message translates to:
  /// **'Track assigned pickups, delivery status, and QR-linked shipment movement.'**
  String get shipmentsDescription;

  /// Financial partner loans screen title
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansTitle;

  /// Financial partner loans placeholder description
  ///
  /// In en, this message translates to:
  /// **'Review farmer finance requests, repayment status, and partner decisions.'**
  String get loansDescription;

  /// Label for language switching action
  ///
  /// In en, this message translates to:
  /// **'تبدیل کریں (Change Language)'**
  String get changeLanguage;

  /// Category filter chip for all products
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// Vegetable product category label
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// Fruits product category label
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoryFruits;

  /// Grains product category label
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get categoryGrains;

  /// Dairy product category label
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// Placeholder text for the search field
  ///
  /// In en, this message translates to:
  /// **'Search products, farms...'**
  String get searchHint;

  /// Button label for adding a product to the cart
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Snackbar message after adding a product
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// Label shown when a product is unavailable
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// Screen title for product detail page
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// Section heading for farmer details
  ///
  /// In en, this message translates to:
  /// **'Farmer Info'**
  String get farmerInfo;

  /// Localized product price with unit
  ///
  /// In en, this message translates to:
  /// **'Rs {amount} / {unit}'**
  String priceAmountWithUnit(String amount, String unit);

  /// Localized Pakistani rupee amount
  ///
  /// In en, this message translates to:
  /// **'Rs {amount}'**
  String currencyAmount(String amount);

  /// Quantity with unit
  ///
  /// In en, this message translates to:
  /// **'{amount} {unit}'**
  String quantityAmountWithUnit(String amount, String unit);

  /// Kilogram unit label
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// Ton unit label
  ///
  /// In en, this message translates to:
  /// **'ton'**
  String get unitTon;

  /// Dozen unit label
  ///
  /// In en, this message translates to:
  /// **'dozen'**
  String get unitDozen;

  /// Piece unit label
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;

  /// Litre unit label
  ///
  /// In en, this message translates to:
  /// **'litre'**
  String get unitLitre;

  /// Label for quantity selector
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Section heading for product description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for quality grade
  ///
  /// In en, this message translates to:
  /// **'Quality Grade'**
  String get qualityGrade;

  /// Quality grade label with value
  ///
  /// In en, this message translates to:
  /// **'Quality Grade: {grade}'**
  String qualityGradeWithValue(String grade);

  /// Quality grade A
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get gradeA;

  /// Quality grade B
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get gradeB;

  /// Quality grade C
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get gradeC;

  /// Cart screen title
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// Message when cart has no items
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// Subtitle below empty cart message
  ///
  /// In en, this message translates to:
  /// **'Browse the marketplace and add fresh produce.'**
  String get cartEmptySubtitle;

  /// CTA button on empty cart screen
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// Subtotal label in cart group
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Platform fee label in cart group
  ///
  /// In en, this message translates to:
  /// **'Platform Fee ({percent}%)'**
  String platformFeeWithPercent(String percent);

  /// Grand total label in cart group
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// Checkout button label in farmer cart group
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// Snackbar message for farmer-specific checkout
  ///
  /// In en, this message translates to:
  /// **'Checkout for {farmerName}'**
  String checkoutForFarmer(String farmerName);

  /// Button to remove a cart item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// Snackbar message after removing a cart item
  ///
  /// In en, this message translates to:
  /// **'Item removed'**
  String get itemRemoved;

  /// Label for farmer/product rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Label prefix before farmer name on product card
  ///
  /// In en, this message translates to:
  /// **'Sold by'**
  String get soldBy;

  /// Label for farm location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Number of sales by a farmer
  ///
  /// In en, this message translates to:
  /// **'{count} sales'**
  String totalSales(int count);

  /// Status label for active products
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get productStatusActive;

  /// Status label for inactive products
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get productStatusInactive;

  /// Status label for sold out products
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get productStatusSoldOut;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Link to dismiss auth and stay as guest
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// Prompt before sign-up link on login screen
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Prompt before login link on signup screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Login email/phone field label
  ///
  /// In en, this message translates to:
  /// **'Email / Phone'**
  String get emailOrPhone;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link on login screen
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get invalidCredentials;

  /// Snackbar after successful signup
  ///
  /// In en, this message translates to:
  /// **'Account created! You are now logged in.'**
  String get signUpSuccess;

  /// Snackbar when session expires
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please login again.'**
  String get sessionExpiredMessage;

  /// Title for auth-required prompts
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// Auth prompt reason for cart
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to add products to your cart.'**
  String get loginToAddToCart;

  /// Auth prompt reason for checkout
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to checkout.'**
  String get loginToCheckout;

  /// Auth prompt reason for orders
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to view your orders.'**
  String get loginToViewOrders;

  /// Auth prompt reason for profile
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to manage your profile.'**
  String get loginToViewProfile;

  /// Dismiss button on auth-required sheet
  ///
  /// In en, this message translates to:
  /// **'Continue browsing'**
  String get authRequiredDismiss;

  /// Divider text between login and signup actions
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// Heading on signup role picker
  ///
  /// In en, this message translates to:
  /// **'I want to...'**
  String get signUpSelectRole;

  /// Name field label on signup
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signUpName;

  /// Phone field label on signup
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get signUpPhone;

  /// Step heading for personal info in multi-step signup
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Step heading for farm details in farmer signup
  ///
  /// In en, this message translates to:
  /// **'Farm Information'**
  String get farmInfo;

  /// Farm name field label
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// Farm location field label
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocation;

  /// Farm size field label
  ///
  /// In en, this message translates to:
  /// **'Farm Size (acres)'**
  String get farmSize;

  /// Crop types section label
  ///
  /// In en, this message translates to:
  /// **'Crop Types'**
  String get cropTypes;

  /// Certifications field label
  ///
  /// In en, this message translates to:
  /// **'Certifications (optional)'**
  String get certifications;

  /// Step heading for vehicle details in transporter signup
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// Vehicle type field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// Vehicle license number field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle License Number'**
  String get vehicleLicense;

  /// Service area field label
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceArea;

  /// CNIC field label
  ///
  /// In en, this message translates to:
  /// **'CNIC (optional)'**
  String get cnic;

  /// Availability status dropdown label
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availabilityStatus;

  /// Multi-step form progress label
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {m}'**
  String stepNofM(int n, int m);

  /// Next step button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back step button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Guest account screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farm2Fork'**
  String get welcomeToFarm2Fork;

  /// Guest account screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to access your orders, cart, and full profile.'**
  String get guestWelcomeSubtitle;

  /// Label for dev-mode credential hints
  ///
  /// In en, this message translates to:
  /// **'Dev test accounts'**
  String get devTestAccounts;

  /// Settings tile label for notifications
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Settings tile label for language & display settings
  ///
  /// In en, this message translates to:
  /// **'Language & Display'**
  String get languageDisplay;

  /// Settings font size label
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Tile label for Contact Us screen
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Tile label for FAQs screen
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// Tile label for About Us screen
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// Tile label for Privacy Policy screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Tile label for Terms & Conditions screen
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// Section header for application settings
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Section header for help and policies
  ///
  /// In en, this message translates to:
  /// **'Help & Information'**
  String get helpInformation;

  /// Notifications settings page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Notifications settings page subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to be notified'**
  String get notificationsSubtitle;

  /// Order updates notification switch label
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// Order updates notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when order status changes'**
  String get orderUpdatesDesc;

  /// Shipment updates notification switch label
  ///
  /// In en, this message translates to:
  /// **'Shipment Alerts'**
  String get shipmentUpdates;

  /// Shipment updates notification description
  ///
  /// In en, this message translates to:
  /// **'Track active shipments in real-time'**
  String get shipmentUpdatesDesc;

  /// Community updates notification switch label
  ///
  /// In en, this message translates to:
  /// **'Community Updates'**
  String get communityAlerts;

  /// Community updates notification description
  ///
  /// In en, this message translates to:
  /// **'Get alerts on new posts and comments'**
  String get communityAlertsDesc;

  /// Marketing updates notification switch label
  ///
  /// In en, this message translates to:
  /// **'Promotional Messages'**
  String get marketingAlerts;

  /// Marketing updates notification description
  ///
  /// In en, this message translates to:
  /// **'Stay updated on discounts and marketplace campaigns'**
  String get marketingAlertsDesc;

  /// Language & display settings page title
  ///
  /// In en, this message translates to:
  /// **'Language & Display'**
  String get languageDisplayTitle;

  /// Small font scale label
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// Medium font scale label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// Large font scale label
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// Extra large font scale label
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontSizeXLarge;

  /// Header for font size preview card
  ///
  /// In en, this message translates to:
  /// **'Font Size Preview Text'**
  String get textScalePreview;

  /// Preview text for font size scaling
  ///
  /// In en, this message translates to:
  /// **'This is a sample sentence to see how font scaling affects readability across the application.'**
  String get textScalePreviewDesc;

  /// Contact us page title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// Contact us page subtitle
  ///
  /// In en, this message translates to:
  /// **'Get in touch with support team'**
  String get contactUsSubtitle;

  /// Contact us subject field label
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactSubject;

  /// Subject general option
  ///
  /// In en, this message translates to:
  /// **'General Inquiry'**
  String get contactSubjectGeneral;

  /// Subject listing option
  ///
  /// In en, this message translates to:
  /// **'Listing Assistance'**
  String get contactSubjectListing;

  /// Subject payment option
  ///
  /// In en, this message translates to:
  /// **'Payment Issue'**
  String get contactSubjectPayment;

  /// Subject transport option
  ///
  /// In en, this message translates to:
  /// **'Transportation Support'**
  String get contactSubjectTransport;

  /// Contact us message field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// Contact us message hint
  ///
  /// In en, this message translates to:
  /// **'Describe your request in detail...'**
  String get contactMessageHint;

  /// Contact us submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit Inquiry'**
  String get contactSubmit;

  /// Support email label
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get contactEmail;

  /// Toll free Helpline label
  ///
  /// In en, this message translates to:
  /// **'Toll-Free Helpline'**
  String get contactPhone;

  /// Headquarters address label
  ///
  /// In en, this message translates to:
  /// **'Headquarters Address'**
  String get contactAddress;

  /// Contact us form success message
  ///
  /// In en, this message translates to:
  /// **'Your inquiry has been submitted successfully!'**
  String get contactMessageSuccess;

  /// Contact us form validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get pleaseEnterMessage;

  /// FAQs page title
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqsTitle;

  /// FAQ category General label
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get faqCategoryGeneral;

  /// FAQ category Marketplace label
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get faqCategoryMarketplace;

  /// FAQ category Security label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get faqCategorySecurity;

  /// FAQ category Delivery label
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get faqCategoryTransport;

  /// FAQ Question 1
  ///
  /// In en, this message translates to:
  /// **'How does Farm2Fork work?'**
  String get faqQ1;

  /// FAQ Answer 1
  ///
  /// In en, this message translates to:
  /// **'Farm2Fork connects farmers directly with buyers and transporters. Farmers list crops, buyers purchase them, and transporters deliver them, eliminating middlemen.'**
  String get faqA1;

  /// FAQ Question 2
  ///
  /// In en, this message translates to:
  /// **'Is my payment secure?'**
  String get faqQ2;

  /// FAQ Answer 2
  ///
  /// In en, this message translates to:
  /// **'Yes. Farm2Fork uses verified payment escrow models (JazzCash, Bank transfers) where funds are safely released only upon successful cargo delivery.'**
  String get faqA2;

  /// FAQ Question 3
  ///
  /// In en, this message translates to:
  /// **'What is the platform fee?'**
  String get faqQ3;

  /// FAQ Answer 3
  ///
  /// In en, this message translates to:
  /// **'The platform charges a small fee (up to 5%) on successful transactions to cover payment gateway costs, system maintenance, and support.'**
  String get faqA3;

  /// FAQ Question 4
  ///
  /// In en, this message translates to:
  /// **'How do transporters register?'**
  String get faqQ4;

  /// FAQ Answer 4
  ///
  /// In en, this message translates to:
  /// **'Transporters can sign up in the app by selecting the Transporter role and entering their vehicle details, area of service, and license information.'**
  String get faqA4;

  /// About us page title
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsTitle;

  /// About us page content
  ///
  /// In en, this message translates to:
  /// **'Farm2Fork is an agri-tech initiative built to empower local farmers, bypass predatory middlemen, and guarantee fresh produce for buyers. By securing transactions through transparent blockchain-grade ledger records, we build direct, trustworthy, and efficient supply networks.'**
  String get aboutUsContent;

  /// Privacy policy page title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Privacy policy page content
  ///
  /// In en, this message translates to:
  /// **'At Farm2Fork, we value your privacy. We collect profile details (name, email, phone number) and location data solely to facilitate transactions, listing maps, and shipment tracking. Transaction details are securely recorded to audit delivery steps, and we never sell user data to third parties.'**
  String get privacyPolicyContent;

  /// Terms & Conditions page title
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditionsTitle;

  /// Terms & conditions page content
  ///
  /// In en, this message translates to:
  /// **'By using the Farm2Fork application, you agree to fulfill order commitments. Farmers must guarantee correct quality grades, buyers must settle balances upon checkout, and transporters must complete delivery routes securely. Platform fee calculations are fixed by system rules and are non-refundable.'**
  String get termsConditionsContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
