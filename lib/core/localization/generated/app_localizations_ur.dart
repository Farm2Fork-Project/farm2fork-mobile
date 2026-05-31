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
}
