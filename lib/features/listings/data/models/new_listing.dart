import 'dart:typed_data';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// What a farmer submits to publish a listing. The server owns the id,
/// status, QR trace URL and first blockchain record, so they are not here.
class NewListing {
  const NewListing({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.qualityGrade,
    this.images = const [],
    this.status,
    this.original,
  });

  final String name;
  final ProductCategory category;
  final String description;
  final double price;
  final double quantity;
  final ProductUnit unit;
  final QualityGrade qualityGrade;
  final List<String> images;
  final ProductStatus? status;
  final Product? original;
}

class ListingPhoto {
  const ListingPhoto({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });
  final Uint8List bytes;
  final String filename;
  final String mimeType;
}
