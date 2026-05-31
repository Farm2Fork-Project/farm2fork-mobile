import 'package:Farm2Fork/features/marketplace/data/models/farmer_summary.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product_category.dart';

// ─── Farmers ────────────────────────────────────────────────────────────────

const _farmerAli = FarmerSummary(
  id: 'farmer_001',
  name: 'Ali Hassan',
  farmName: 'Hassan Organic Farm',
  farmLocationAddress: 'Multan, Punjab',
  rating: 4.8,
  totalSales: 312,
);

const _farmerFatima = FarmerSummary(
  id: 'farmer_002',
  name: 'Fatima Bibi',
  farmName: 'Sindh Mango Estate',
  farmLocationAddress: 'Hyderabad, Sindh',
  rating: 4.9,
  totalSales: 540,
);

const _farmerTariq = FarmerSummary(
  id: 'farmer_003',
  name: 'Tariq Mehmood',
  farmName: 'Punjab Grain Fields',
  farmLocationAddress: 'Faisalabad, Punjab',
  rating: 4.5,
  totalSales: 198,
);

const _farmerSaima = FarmerSummary(
  id: 'farmer_004',
  name: 'Saima Noor',
  farmName: 'Green Dairy Valley',
  farmLocationAddress: 'Lahore, Punjab',
  rating: 4.7,
  totalSales: 425,
);

// ─── Products ───────────────────────────────────────────────────────────────

final List<Product> mockProducts = [
  // Vegetables
  const Product(
    id: 'prod_001',
    farmerId: 'farmer_001',
    name: 'Organic Tomatoes',
    category: ProductCategory.vegetables,
    description:
        'Sun-ripened organic tomatoes grown without pesticides. Rich in lycopene and perfect for cooking.',
    pricePerUnit: 120,
    availableQuantity: 200,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.aPlus,
    status: ProductStatus.available,
    farmer: _farmerAli,
  ),
  const Product(
    id: 'prod_002',
    farmerId: 'farmer_001',
    name: 'Fresh Spinach',
    category: ProductCategory.vegetables,
    description: 'Tender baby spinach leaves, hand-picked daily. High in iron and vitamins.',
    pricePerUnit: 80,
    availableQuantity: 150,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.a,
    status: ProductStatus.available,
    farmer: _farmerAli,
  ),
  const Product(
    id: 'prod_003',
    farmerId: 'farmer_001',
    name: 'Desi Onions',
    category: ProductCategory.vegetables,
    description:
        'Pungent desi onions from Multan, stored under optimal conditions for long shelf life.',
    pricePerUnit: 60,
    availableQuantity: 500,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.a,
    status: ProductStatus.available,
    farmer: _farmerAli,
  ),

  // Fruits
  const Product(
    id: 'prod_004',
    farmerId: 'farmer_002',
    name: 'Sindhri Mangoes',
    category: ProductCategory.fruits,
    description:
        'Premium Sindhri mangoes from Sindh — the king of Pakistani mangoes. Sweet, fibre-free, and aromatic.',
    pricePerUnit: 350,
    availableQuantity: 80,
    unit: 'dozen',
    imageUrls: [],
    qualityGrade: QualityGrade.aPlus,
    status: ProductStatus.available,
    farmer: _farmerFatima,
  ),
  const Product(
    id: 'prod_005',
    farmerId: 'farmer_002',
    name: 'Kinnow Oranges',
    category: ProductCategory.fruits,
    description:
        'Juicy kinnow oranges, grown in the fertile plains of Sindh. Excellent for fresh juice.',
    pricePerUnit: 150,
    availableQuantity: 300,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.a,
    status: ProductStatus.available,
    farmer: _farmerFatima,
  ),
  const Product(
    id: 'prod_006',
    farmerId: 'farmer_002',
    name: 'Guava (Amrood)',
    category: ProductCategory.fruits,
    description: 'Crunchy Pakistani guava with a distinctive flavour. Rich in Vitamin C.',
    pricePerUnit: 100,
    availableQuantity: 0,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.b,
    status: ProductStatus.outOfStock,
    farmer: _farmerFatima,
  ),

  // Grains
  const Product(
    id: 'prod_007',
    farmerId: 'farmer_003',
    name: 'Basmati Rice (1121)',
    category: ProductCategory.grains,
    description:
        'Long-grain 1121 Basmati rice from Faisalabad. Aged 2 years for perfect aroma and texture.',
    pricePerUnit: 320,
    availableQuantity: 1000,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.aPlus,
    status: ProductStatus.available,
    farmer: _farmerTariq,
  ),
  const Product(
    id: 'prod_008',
    farmerId: 'farmer_003',
    name: 'Whole Wheat Flour',
    category: ProductCategory.grains,
    description:
        'Stone-ground whole wheat flour, retaining natural bran and germ. Ideal for roti and bread.',
    pricePerUnit: 85,
    availableQuantity: 800,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.a,
    status: ProductStatus.available,
    farmer: _farmerTariq,
  ),
  const Product(
    id: 'prod_009',
    farmerId: 'farmer_003',
    name: 'Maize (Corn)',
    category: ProductCategory.grains,
    description:
        'Yellow maize grain from Punjab fields. Great for corn flour, animal feed, and popcorn.',
    pricePerUnit: 55,
    availableQuantity: 2000,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.b,
    status: ProductStatus.available,
    farmer: _farmerTariq,
  ),

  // Dairy
  const Product(
    id: 'prod_010',
    farmerId: 'farmer_004',
    name: 'Fresh Doodh (Milk)',
    category: ProductCategory.dairy,
    description: 'Pure, unprocessed buffalo milk collected twice daily. Rich in fat and protein.',
    pricePerUnit: 180,
    availableQuantity: 100,
    unit: 'litre',
    imageUrls: [],
    qualityGrade: QualityGrade.aPlus,
    status: ProductStatus.available,
    farmer: _farmerSaima,
  ),
  const Product(
    id: 'prod_011',
    farmerId: 'farmer_004',
    name: 'Desi Ghee',
    category: ProductCategory.dairy,
    description:
        'Hand-churned desi ghee made from buffalo cream. Traditional recipe, no additives.',
    pricePerUnit: 2200,
    availableQuantity: 50,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.aPlus,
    status: ProductStatus.available,
    farmer: _farmerSaima,
  ),
  const Product(
    id: 'prod_012',
    farmerId: 'farmer_004',
    name: 'Yoghurt (Dahi)',
    category: ProductCategory.dairy,
    description: 'Thick, creamy set yoghurt made from whole buffalo milk. No preservatives.',
    pricePerUnit: 160,
    availableQuantity: 120,
    unit: 'kg',
    imageUrls: [],
    qualityGrade: QualityGrade.a,
    status: ProductStatus.available,
    farmer: _farmerSaima,
  ),
];
