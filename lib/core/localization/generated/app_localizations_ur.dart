// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'فارم ٹو فورک';

  @override
  String get selectLanguage => 'زبان منتخب کریں';

  @override
  String get english => 'انگریزی (English)';

  @override
  String get urdu => 'اردو (Urdu)';

  @override
  String get login => 'لاگ ان';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get welcome => 'خوش آمدید';

  @override
  String get marketplace => 'منڈی';

  @override
  String get cart => 'کارٹ';

  @override
  String get orders => 'آرڈرز';

  @override
  String get profile => 'پروفائل';

  @override
  String get settings => 'ترتیبات';

  @override
  String get navHome => 'منڈی';

  @override
  String get navCart => 'کارٹ';

  @override
  String get navOrders => 'آرڈرز';

  @override
  String get navProfile => 'پروفائل';

  @override
  String get navListings => 'میری فصلیں';

  @override
  String get navCreateListing => 'پیداوار درج کریں';

  @override
  String get navTrace => 'فصل کا سفر';

  @override
  String get navShipments => 'شپمنٹس';

  @override
  String get navLoans => 'قرضے';

  @override
  String get navFeed => 'کسان چوپال';

  @override
  String get errorOccurred => 'خرابی پیش آگئی ہے۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get noDataFound => 'کوئی ڈیٹا نہیں ملا۔';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

  @override
  String get featureComingSoon => 'جلد آ رہا ہے';

  @override
  String get traceScannerTitle => 'اسکین اور ٹریس';

  @override
  String get traceScannerDescription =>
      'مصنوعات کا QR کوڈ اسکین کریں تاکہ اصل جگہ، کسان، آرڈر کا سفر، شپمنٹ اپ ڈیٹس، اور بلاک چین ریکارڈز دیکھ سکیں۔';

  @override
  String get paymentOptionsNote =>
      'ادائیگی کے لیے کیش، JazzCash، اور دیگر گیٹ ویز جیسے کئی طریقے شامل کیے جائیں گے جب provider فائنل ہو جائے گا۔';

  @override
  String get authWelcomeTitle => 'فارم ٹو فورک رسائی';

  @override
  String get authWelcomeSubtitle =>
      'آپ جس اکاؤنٹ کی قسم کو دیکھنا چاہتے ہیں، اسے منتخب کریں۔ سسٹم مکمل ہونے پر آپ کا اصل لاگ ان یہاں کام کرے گا۔';

  @override
  String get chooseYourRole => 'اپنا رول منتخب کریں';

  @override
  String continueAsRole(String role) {
    return '$role کے طور پر جاری رکھیں';
  }

  @override
  String get roleFarmer => 'کاشتکار';

  @override
  String get roleBuyer => 'خریدار';

  @override
  String get roleTransporter => 'ٹرانسپورٹر';

  @override
  String get roleFinancialPartner => 'فنانشل پارٹنر';

  @override
  String get roleAdmin => 'ایڈمن';

  @override
  String get farmerRoleDescription =>
      'اپنی فصلوں، آرڈرز، اور کسان چوپال کی سرگرمیوں کا انتظام کریں۔';

  @override
  String get buyerRoleDescription =>
      'تازہ پیداوار خریدیں، تصدیق کے لیے کیو آر (QR) کوڈ اسکین کریں، اور اپنے آرڈرز کو ٹریک کریں۔';

  @override
  String get transporterRoleDescription =>
      'اپنی ترسیل کے کام دیکھیں اور اشیاء کی بروقت فراہمی کو اپ ڈیٹ کریں۔';

  @override
  String get financialPartnerRoleDescription =>
      'کسانوں کے لیے قرض کی درخواستیں اور مالی سرگرمیاں دیکھیں۔';

  @override
  String get adminRoleDescription =>
      'منڈی، آرڈرز، فنانس، اور پلیٹ فارم کی تمام سرگرمیوں کی نگرانی کریں۔';

  @override
  String signedInAsRole(String role) {
    return '$role کے طور پر لاگ ان';
  }

  @override
  String get listingsTitle => 'میری فصلیں';

  @override
  String get listingsDescription =>
      'اپنی فصلوں، اسٹاک اور فارم کی پیداوار کا انتظام کریں۔';

  @override
  String get createListingTitle => 'پیداوار درج کریں';

  @override
  String get createListingDescription =>
      'خریداروں کے لیے فصل کی تفصیلات، مقدار، کوالٹی، قیمت اور کٹائی کی معلومات درج کریں۔';

  @override
  String get feedTitle => 'کسان چوپال';

  @override
  String get feedDescription =>
      'اپنی معلومات شیئر کریں، سوالات پوچھیں، اور کسانوں کے نیٹ ورک سے جڑے رہیں۔';

  @override
  String get shipmentsTitle => 'شپمنٹس';

  @override
  String get shipmentsDescription =>
      'اپنی تفویض کردہ ترسیلات، منزل کی صورتحال اور کیو آر (QR) کوڈ سے منسلک معلومات ٹریک کریں۔';

  @override
  String get availableDeliveries => 'دستیاب ترسیلات';

  @override
  String get myDeliveries => 'میری ترسیلات';

  @override
  String get deliveryRequest => 'ترسیل کی درخواست';

  @override
  String deliveryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اشیاء',
      one: '1 شے',
    );
    return '$_temp0';
  }

  @override
  String get claimDelivery => 'ترسیل قبول کریں';

  @override
  String get loansTitle => 'قرضے';

  @override
  String get loansDescription =>
      'کسانوں کی مالی مدد، قرض کی واپسی کی صورتحال اور شراکت داروں کے فیصلے دیکھیں۔';

  @override
  String get changeLanguage => 'Change Language (زبان تبدیل کریں)';

  @override
  String get allCategories => 'سب';

  @override
  String get categoryVegetables => 'سبزیاں';

  @override
  String get categoryFruits => 'پھل';

  @override
  String get categoryGrains => 'اناج';

  @override
  String get categoryDairy => 'دودھ کی مصنوعات';

  @override
  String get searchHint => 'مصنوعات، فارم تلاش کریں...';

  @override
  String get addToCart => 'کارٹ میں شامل کریں';

  @override
  String get addedToCart => 'کارٹ میں شامل ہو گیا';

  @override
  String get outOfStock => 'ختم ہو چکا ہے';

  @override
  String get productDetails => 'مصنوع کی تفصیل';

  @override
  String get farmerInfo => 'کسان کی معلومات';

  @override
  String priceAmountWithUnit(String amount, String unit) {
    return '$amount روپے / $unit';
  }

  @override
  String currencyAmount(String amount) {
    return '$amount روپے';
  }

  @override
  String quantityAmountWithUnit(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get unitKg => 'کلو';

  @override
  String get unitTon => 'ٹن';

  @override
  String get unitDozen => 'درجن';

  @override
  String get unitPiece => 'عدد';

  @override
  String get unitLitre => 'لیٹر';

  @override
  String get quantity => 'مقدار';

  @override
  String get description => 'تفصیل';

  @override
  String get qualityGrade => 'معیار';

  @override
  String qualityGradeWithValue(String grade) {
    return 'معیار: $grade';
  }

  @override
  String get gradeA => 'اے';

  @override
  String get gradeB => 'بی';

  @override
  String get gradeC => 'سی';

  @override
  String get yourCart => 'آپ کا کارٹ';

  @override
  String get cartEmpty => 'آپ کا کارٹ خالی ہے';

  @override
  String get cartEmptySubtitle =>
      'مارکیٹ پلیس دیکھیں اور تازہ مصنوعات شامل کریں۔';

  @override
  String get shopNow => 'ابھی خریداری کریں';

  @override
  String get subtotal => 'ذیلی کل';

  @override
  String platformFeeWithPercent(String percent) {
    return 'پلیٹ فارم فیس ($percent%)';
  }

  @override
  String get grandTotal => 'کل رقم';

  @override
  String get checkout => 'ادائیگی کریں';

  @override
  String checkoutForFarmer(String farmerName) {
    return '$farmerName کے لیے چیک آؤٹ';
  }

  @override
  String get checkoutTitle => 'ادائیگی';

  @override
  String get shippingAddress => 'ترسیل کا پتہ';

  @override
  String get streetAddress => 'گلی کا پتہ';

  @override
  String get city => 'شہر';

  @override
  String get province => 'صوبہ';

  @override
  String get zipCode => 'پوسٹل کوڈ';

  @override
  String get orderSummary => 'آرڈر کا خلاصہ';

  @override
  String orderForFarmer(String farmerName) {
    return '$farmerName کے لیے آرڈر';
  }

  @override
  String get separateOrdersNote =>
      'مختلف کسانوں کی اشیاء الگ الگ آرڈرز کے طور پر دی جاتی ہیں۔';

  @override
  String placeOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آرڈرز دیں',
      one: '1 آرڈر دیں',
    );
    return '$_temp0';
  }

  @override
  String ordersPlacedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آرڈرز کامیابی سے دے دیے گئے',
      one: '1 آرڈر کامیابی سے دے دیا گیا',
    );
    return '$_temp0';
  }

  @override
  String get orderPlacementFailed =>
      'آپ کا آرڈر نہیں دیا جا سکا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get paymentTitle => 'ادائیگی';

  @override
  String get paymentPending => 'ادائیگی زیر التوا ہے';

  @override
  String get paymentPendingDescription =>
      'آپ کی ادائیگی بن گئی ہے اور تصدیق کا انتظار کر رہی ہے۔';

  @override
  String paymentOrdersReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آرڈرز ادائیگی کے لیے تیار ہیں',
      one: '1 آرڈر ادائیگی کے لیے تیار ہے',
    );
    return '$_temp0';
  }

  @override
  String get completeTestPayment => 'ٹیسٹ ادائیگی مکمل کریں';

  @override
  String get paymentComplete => 'ادائیگی مکمل ہو گئی';

  @override
  String paymentCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آرڈرز کی ادائیگیاں مکمل ہوئیں',
      one: '1 آرڈر کی ادائیگی مکمل ہوئی',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ادائیگی مکمل نہیں ہو سکی';

  @override
  String paymentFailedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آرڈرز کی ادائیگیاں ناکام ہوئیں',
      one: '1 آرڈر کی ادائیگی ناکام ہوئی',
    );
    return '$_temp0';
  }

  @override
  String get viewOrders => 'آرڈرز دیکھیں';

  @override
  String get fieldRequired => 'یہ خانہ ضروری ہے';

  @override
  String get removeItem => 'ہٹائیں';

  @override
  String get itemRemoved => 'آئٹم ہٹا دیا گیا';

  @override
  String get rating => 'درجہ بندی';

  @override
  String get soldBy => 'فروخت کنندہ';

  @override
  String get location => 'مقام';

  @override
  String totalSales(int count) {
    return '$count فروخت';
  }

  @override
  String get productStatusActive => 'دستیاب';

  @override
  String get productStatusInactive => 'غیر فعال';

  @override
  String get productStatusSoldOut => 'اسٹاک ختم';

  @override
  String get signUp => 'اکاؤنٹ بنائیں';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get continueAsGuest => 'مہمان کے طور پر جاری رکھیں';

  @override
  String get dontHaveAccount => 'اکاؤنٹ نہیں ہے؟';

  @override
  String get alreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟';

  @override
  String get emailOrPhone => 'ای میل / فون';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get confirmPassword => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get invalidCredentials => 'غلط ای میل یا پاس ورڈ۔ دوبارہ کوشش کریں۔';

  @override
  String get signUpSuccess => 'اکاؤنٹ بن گیا! آپ لاگ ان ہو گئے ہیں۔';

  @override
  String get sessionExpiredMessage =>
      'آپ کا سیشن ختم ہو گیا۔ دوبارہ لاگ ان کریں۔';

  @override
  String get loginRequired => 'لاگ ان ضروری ہے';

  @override
  String get loginToAddToCart =>
      'کارٹ میں مصنوعات شامل کرنے کے لیے لاگ ان کریں یا اکاؤنٹ بنائیں۔';

  @override
  String get loginToCheckout =>
      'چیک آؤٹ کرنے کے لیے لاگ ان کریں یا اکاؤنٹ بنائیں۔';

  @override
  String get loginToViewOrders =>
      'اپنے آرڈر دیکھنے کے لیے لاگ ان کریں یا اکاؤنٹ بنائیں۔';

  @override
  String get loginToViewProfile =>
      'اپنا پروفائل منظم کرنے کے لیے لاگ ان کریں یا اکاؤنٹ بنائیں۔';

  @override
  String get authRequiredDismiss => 'براؤز کرتے رہیں';

  @override
  String get authOr => 'یا';

  @override
  String get signUpSelectRole => 'میں چاہتا/چاہتی ہوں...';

  @override
  String get signUpName => 'پورا نام';

  @override
  String get signUpPhone => 'فون نمبر';

  @override
  String get personalInfo => 'ذاتی معلومات';

  @override
  String get farmInfo => 'فارم کی معلومات';

  @override
  String get farmName => 'فارم کا نام';

  @override
  String get farmLocation => 'فارم کا مقام';

  @override
  String get farmSize => 'فارم کا رقبہ (ایکڑ)';

  @override
  String get cropTypes => 'فصلوں کی اقسام';

  @override
  String get certifications => 'سرٹیفیکیشن (اختیاری)';

  @override
  String get vehicleInfo => 'گاڑی کی معلومات';

  @override
  String get vehicleType => 'گاڑی کی قسم';

  @override
  String get vehicleLicense => 'گاڑی کا لائسنس نمبر';

  @override
  String get serviceArea => 'سروس ایریا';

  @override
  String get cnic => 'شناختی کارڈ نمبر (اختیاری)';

  @override
  String get availabilityStatus => 'دستیابی';

  @override
  String stepNofM(int n, int m) {
    return 'مرحلہ $n از $m';
  }

  @override
  String get next => 'اگلا';

  @override
  String get back => 'واپس';

  @override
  String get welcomeToFarm2Fork => 'Farm2Fork میں خوش آمدید';

  @override
  String get guestWelcomeSubtitle =>
      'اپنے آرڈر، کارٹ اور پروفائل تک رسائی کے لیے لاگ ان کریں یا اکاؤنٹ بنائیں۔';

  @override
  String get devTestAccounts => 'ڈیو ٹیسٹ اکاؤنٹس';

  @override
  String get notificationSettings => 'اطلاعات کی ترتیبات';

  @override
  String get languageDisplay => 'زبان اور ڈسپلے';

  @override
  String get fontSize => 'فونٹ سائز';

  @override
  String get contactUs => 'ہم سے رابطہ کریں';

  @override
  String get faqs => 'اکثر پوچھے گئے سوالات';

  @override
  String get aboutUs => 'ہمارے بارے میں';

  @override
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get termsConditions => 'شرائط و ضوابط';

  @override
  String get appSettings => 'ایپ کی ترتیبات';

  @override
  String get helpInformation => 'مدد اور معلومات';

  @override
  String get notificationsTitle => 'اطلاعات';

  @override
  String get notificationsSubtitle => 'منتخب کریں کہ آپ کو کیسے اطلاع دی جائے';

  @override
  String get orderUpdates => 'آرڈر کی اپ ڈیٹس';

  @override
  String get orderUpdatesDesc =>
      'آرڈر کی صورتحال تبدیل ہونے پر اطلاع حاصل کریں';

  @override
  String get shipmentUpdates => 'شپمنٹ الرٹس';

  @override
  String get shipmentUpdatesDesc => 'فعال شپمنٹس کو حقیقی وقت میں ٹریک کریں';

  @override
  String get communityAlerts => 'کمیونٹی اپ ڈیٹس';

  @override
  String get communityAlertsDesc => 'نئی پوسٹس اور تبصروں پر الرٹ حاصل کریں';

  @override
  String get marketingAlerts => 'پروموشنل پیغامات';

  @override
  String get marketingAlertsDesc => 'ڈسکاؤنٹ اور مارکیٹ مہمات سے باخبر رہیں';

  @override
  String get languageDisplayTitle => 'زبان اور ڈسپلے';

  @override
  String get fontSizeSmall => 'چھوٹا';

  @override
  String get fontSizeMedium => 'درمیانہ';

  @override
  String get fontSizeLarge => 'بڑا';

  @override
  String get fontSizeXLarge => 'بہت بڑا';

  @override
  String get textScalePreview => 'پیش نظارہ';

  @override
  String get textScalePreviewDesc =>
      'یہ ایک نمونہ جملہ ہے یہ دیکھنے کے لیے کہ فونٹ سائز کی تبدیلی ایپ میں پڑھنے کی سہولت پر کیا اثر ڈالتی ہے۔';

  @override
  String get contactUsTitle => 'ہم سے رابطہ کریں';

  @override
  String get contactUsSubtitle => 'سپورٹ ٹیم سے رابطہ کریں';

  @override
  String get contactSubject => 'موضوع';

  @override
  String get contactSubjectGeneral => 'عام معلومات';

  @override
  String get contactSubjectListing => 'لسٹنگ میں مدد';

  @override
  String get contactSubjectPayment => 'ادائیگی کا مسئلہ';

  @override
  String get contactSubjectTransport => 'ٹرانسپورٹ سپورٹ';

  @override
  String get contactMessage => 'پیغام';

  @override
  String get contactMessageHint => 'اپنی درخواست کی تفصیلات یہاں لکھیں...';

  @override
  String get contactSubmit => 'درخواست جمع کروائیں';

  @override
  String get contactEmail => 'سپورٹ ای میل';

  @override
  String get contactPhone => 'ہیلپ لائن نمبر';

  @override
  String get contactAddress => 'مرکزی دفتر کا پتہ';

  @override
  String get contactMessageSuccess =>
      'آپ کا پیغام کامیابی سے جمع کر دیا گیا ہے!';

  @override
  String get pleaseEnterMessage => 'براہ کرم اپنا پیغام درج کریں';

  @override
  String get faqsTitle => 'اکثر پوچھے گئے سوالات';

  @override
  String get faqCategoryGeneral => 'عام';

  @override
  String get faqCategoryMarketplace => 'مارکیٹ پلیس';

  @override
  String get faqCategorySecurity => 'سیکورٹی';

  @override
  String get faqCategoryTransport => 'ڈیلیوری';

  @override
  String get faqQ1 => 'فارم ٹو فورک کیسے کام کرتا ہے؟';

  @override
  String get faqA1 =>
      'فارم ٹو فورک کسانوں کو براہ راست خریداروں اور ٹرانسپورٹرز سے جوڑتا ہے۔ کسان فصلیں لسٹ کرتے ہیں، خریدار انہیں خریدتے ہیں، اور ٹرانسپورٹرز فراہم کرتے ہیں۔';

  @override
  String get faqQ2 => 'کیا میری ادائیگی محفوظ ہے؟';

  @override
  String get faqA2 =>
      'جی ہاں۔ فارم ٹو فورک تصدیق شدہ ادائیگی کے طریقے (JazzCash، بینک ٹرانسفر) استعمال کرتا ہے جہاں رقم صرف ڈیلیوری کی کامیابی پر ہی جاری کی جاتی ہے۔';

  @override
  String get faqQ3 => 'پلیٹ فارم فیس کتنی ہے؟';

  @override
  String get faqA3 =>
      'کامیاب لین دین پر پلیٹ فارم 5% تک کی چھوٹی فیس وصول کرتا ہے تاکہ سسٹم اور سپورٹ کے اخراجات کو پورا کیا جا سکے۔';

  @override
  String get faqQ4 => 'ٹرانسپورٹرز کیسے رجسٹر ہوتے ہیں؟';

  @override
  String get faqA4 =>
      'ٹرانسپورٹرز ایپ میں ٹرانسپورٹر رول منتخب کر کے اپنی گاڑی کی تفصیلات، سروس ایریا اور لائسنس کی معلومات درج کر کے سائن اپ کر سکتے ہیں۔';

  @override
  String get aboutUsTitle => 'ہمارے بارے میں';

  @override
  String get aboutUsContent =>
      'فارم ٹو فورک ایک زرعی اقدام ہے جو مقامی کسانوں کو بااختیار بنانے، درمیانی خریداروں (آڑھتی) سے بچانے، اور خریداروں کے لیے تازہ پیداوار کی ضمانت فراہم کرنے کے لیے بنایا گیا ہے۔ بلاک چین ریکارڈز کے ذریعے ہم براہ راست اور قابل اعتماد سپلائی نیٹ ورک بناتے ہیں۔';

  @override
  String get privacyPolicyTitle => 'رازداری کی پالیسی';

  @override
  String get privacyPolicyContent =>
      'ہم آپ کی رازداری کا احترام کرتے ہیں۔ ہم نام، ای میل، فون نمبر اور لوکیشن ڈیٹا صرف لسٹنگ اور شپمنٹ ٹریکنگ کے لیے جمع کرتے ہیں۔ ہم کبھی بھی صارف کا ڈیٹا کسی تیسرے فریق کو فروخت نہیں کرتے۔';

  @override
  String get termsConditionsTitle => 'شرائط و ضوابط';

  @override
  String get termsConditionsContent =>
      'ایپ استعمال کر کے آپ آرڈر کے وعدوں کو پورا کرنے پر متفق ہوتے ہیں۔ کسانوں کو معیار کی ضمانت دینی ہو گی، خریداروں کو چیک آؤٹ پر ادائیگی کرنی ہو گی، اور ٹرانسپورٹرز کو محفوظ طریقے سے ڈیلیور کرنا ہو گا۔ پلیٹ فارم فیس ناقابل واپسی ہے۔';
}
