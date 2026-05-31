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
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noDataFound => 'No data found.';

  @override
  String get loading => 'Loading...';

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
  String pricePerUnit(String unit) {
    return 'Price / $unit';
  }

  @override
  String get pkr => 'PKR';

  @override
  String get quantity => 'Quantity';

  @override
  String get description => 'Description';

  @override
  String get qualityGrade => 'Quality Grade';

  @override
  String get gradeAPlus => 'A+';

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
  String get cartEmptySubtitle => 'Browse the marketplace and add fresh produce.';

  @override
  String get shopNow => 'Shop Now';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get platformFee => 'Platform Fee (5%)';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get checkout => 'Checkout';

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
  String get available => 'Available';

  @override
  String get comingSoon => 'Coming Soon';
}
