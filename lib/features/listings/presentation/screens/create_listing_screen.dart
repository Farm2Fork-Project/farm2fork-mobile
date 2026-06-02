import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/listings/presentation/providers/listings_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentStep = 0;

  // Form Fields State
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  ProductCategory _category = ProductCategory.vegetables;
  QualityGrade _qualityGrade = QualityGrade.a;
  ProductUnit _unit = ProductUnit.kg;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
      setState(() => _currentStep = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (!_formKey2.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_qtyController.text) ?? 0.0;

    await ref
        .read(listingsControllerProvider.notifier)
        .addListing(
          name: _nameController.text.trim(),
          category: _category,
          description: _descController.text.trim(),
          price: price,
          quantity: quantity,
          unit: _unit,
          qualityGrade: _qualityGrade,
        );

    if (!mounted) return;
    context.pop(); // return to ListingsScreen
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(listingsControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.createListingTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.stepNofM(_currentStep + 1, 2),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                      Text(
                        _currentStep == 0
                            ? context
                                  .l10n
                                  .personalInfo // fallback/similar step label
                            : context.l10n.farmInfo,
                        style: AppTextStyles.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: AppColors.surfaceMedium,
                    color: AppColors.primaryGreen,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2()],
              ),
            ),

            // Sticky Bottom Button bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: AppButton(
                        label: context.l10n.back,
                        variant: AppButtonVariant.quiet,
                        onPressed: isLoading ? null : _prevStep,
                        expand: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 0
                          ? context.l10n.next
                          : context.l10n.checkout,
                      variant: AppButtonVariant.primary,
                      onPressed: isLoading ? null : _nextStep,
                      expand: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.personalInfo, // standard heading
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Name field
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Produce Name', // fallback string
                    hintText: 'e.g., Organic Tomatoes',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Category select
                DropdownButtonFormField<ProductCategory>(
                  initialValue: _category,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    DropdownMenuItem(
                      value: ProductCategory.vegetables,
                      child: Text(context.l10n.categoryVegetables),
                    ),
                    DropdownMenuItem(
                      value: ProductCategory.fruits,
                      child: Text(context.l10n.categoryFruits),
                    ),
                    DropdownMenuItem(
                      value: ProductCategory.grains,
                      child: Text(context.l10n.categoryGrains),
                    ),
                    DropdownMenuItem(
                      value: ProductCategory.dairy,
                      child: Text(context.l10n.categoryDairy),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Quality Grade select
                DropdownButtonFormField<QualityGrade>(
                  initialValue: _qualityGrade,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Quality Grade'),
                  items: [
                    DropdownMenuItem(
                      value: QualityGrade.a,
                      child: Text(
                        '${context.l10n.qualityGrade}: ${context.l10n.gradeA}',
                      ),
                    ),
                    DropdownMenuItem(
                      value: QualityGrade.b,
                      child: Text(
                        '${context.l10n.qualityGrade}: ${context.l10n.gradeB}',
                      ),
                    ),
                    DropdownMenuItem(
                      value: QualityGrade.c,
                      child: Text(
                        '${context.l10n.qualityGrade}: ${context.l10n.gradeC}',
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _qualityGrade = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Description field
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText:
                        'Describe freshness, farming practices, harvest date, etc.',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a description'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.farmInfo, // fallback heading
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Price field
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    labelText: 'Price (PKR)',
                    hintText: 'e.g., 150',
                    prefixIcon: Icon(
                      Icons.payments_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(v);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Quantity field
                TextFormField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'e.g., 250',
                    prefixIcon: Icon(
                      Icons.scale_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter quantity';
                    }
                    final qty = double.tryParse(v);
                    if (qty == null || qty <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Unit selector
                DropdownButtonFormField<ProductUnit>(
                  initialValue: _unit,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: [
                    DropdownMenuItem(
                      value: ProductUnit.kg,
                      child: Text(context.l10n.unitKg),
                    ),
                    DropdownMenuItem(
                      value: ProductUnit.ton,
                      child: Text(context.l10n.unitTon),
                    ),
                    DropdownMenuItem(
                      value: ProductUnit.dozen,
                      child: Text(context.l10n.unitDozen),
                    ),
                    DropdownMenuItem(
                      value: ProductUnit.piece,
                      child: Text(context.l10n.unitPiece),
                    ),
                    DropdownMenuItem(
                      value: ProductUnit.litre,
                      child: Text(context.l10n.unitLitre),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _unit = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
