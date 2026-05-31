/// Enum representing the top-level product categories in the marketplace.
enum ProductCategory {
  vegetables,
  fruits,
  grains,
  dairy;

  /// Returns a lowercase, display-friendly key for localization lookup.
  String get l10nKey => name;
}
