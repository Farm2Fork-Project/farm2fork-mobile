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
  String get marketplace => 'مارکیٹ پلیس';

  @override
  String get cart => 'کارٹ';

  @override
  String get orders => 'آرڈرز';

  @override
  String get profile => 'پروفائل';

  @override
  String get settings => 'ترتیبات';

  @override
  String get navHome => 'ہوم';

  @override
  String get navCart => 'کارٹ';

  @override
  String get navOrders => 'آرڈرز';

  @override
  String get navProfile => 'پروفائل';

  @override
  String get navListings => 'لسٹنگز';

  @override
  String get navCreateListing => 'بنائیں';

  @override
  String get navTrace => 'ٹریس';

  @override
  String get navShipments => 'شپمنٹس';

  @override
  String get navLoans => 'قرضے';

  @override
  String get navFeed => 'فیڈ';

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
      'جس اکاؤنٹ رول کا preview دیکھنا ہے اسے منتخب کریں۔ backend auth module تیار ہونے کے بعد اصل login یہاں connect ہوگا۔';

  @override
  String get chooseYourRole => 'اپنا رول منتخب کریں';

  @override
  String continueAsRole(String role) {
    return '$role کے طور پر جاری رکھیں';
  }

  @override
  String get roleFarmer => 'کسان';

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
      'پیداوار کی listings، orders، اور community updates manage کریں۔';

  @override
  String get buyerRoleDescription =>
      'تازہ پیداوار خریدیں، QR code scan کریں، اور orders track کریں۔';

  @override
  String get transporterRoleDescription =>
      'shipment tasks دیکھیں اور delivery progress update کریں۔';

  @override
  String get financialPartnerRoleDescription =>
      'loan requests اور farmer finance activity review کریں۔';

  @override
  String get adminRoleDescription =>
      'marketplace، orders، finance، اور platform activity monitor کریں۔';

  @override
  String signedInAsRole(String role) {
    return '$role کے طور پر لاگ ان';
  }

  @override
  String get listingsTitle => 'میری لسٹنگز';

  @override
  String get listingsDescription =>
      'active produce listings، stock updates، اور farm inventory manage کریں۔';

  @override
  String get createListingTitle => 'لسٹنگ بنائیں';

  @override
  String get createListingDescription =>
      'buyers کے لیے crop details، quantity، grade، price، اور harvest information شامل کریں۔';

  @override
  String get feedTitle => 'فارم فیڈ';

  @override
  String get feedDescription =>
      'updates share کریں، سوالات پوچھیں، اور Farm2Fork network کی trusted activity follow کریں۔';

  @override
  String get shipmentsTitle => 'شپمنٹس';

  @override
  String get shipmentsDescription =>
      'assigned pickups، delivery status، اور QR-linked shipment movement track کریں۔';

  @override
  String get loansTitle => 'قرضے';

  @override
  String get loansDescription =>
      'farmer finance requests، repayment status، اور partner decisions review کریں۔';

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
}
