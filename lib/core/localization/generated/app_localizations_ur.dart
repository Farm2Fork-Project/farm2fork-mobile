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
  String get errorOccurred => 'خرابی پیش آگئی ہے۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get noDataFound => 'کوئی ڈیٹا نہیں ملا۔';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

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
  String pricePerUnit(String unit) {
    return 'قیمت / $unit';
  }

  @override
  String get pkr => 'روپے';

  @override
  String get quantity => 'مقدار';

  @override
  String get description => 'تفصیل';

  @override
  String get qualityGrade => 'معیار';

  @override
  String get gradeAPlus => 'اے+';

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
  String get cartEmptySubtitle => 'مارکیٹ پلیس دیکھیں اور تازہ مصنوعات شامل کریں۔';

  @override
  String get shopNow => 'ابھی خریداری کریں';

  @override
  String get subtotal => 'ذیلی کل';

  @override
  String get platformFee => 'پلیٹ فارم فیس (5%)';

  @override
  String get grandTotal => 'کل رقم';

  @override
  String get checkout => 'ادائیگی کریں';

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
  String get available => 'دستیاب';

  @override
  String get comingSoon => 'جلد آ رہا ہے';
}
