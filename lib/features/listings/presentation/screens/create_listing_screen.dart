import 'package:farm2fork_mobile/core/widgets/product_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/media/photo_picker.dart';
import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/price_suggestion_card.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/quality_check_card.dart';
import 'package:farm2fork_mobile/features/listings/presentation/providers/listings_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key, this.initialProduct});
  final Product? initialProduct;

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentStep = 0;
  bool _submitting = false;
  bool _allowExit = false;
  bool _askingToLeave = false;
  bool _pickingPhoto = false;
  final List<ListingPhoto> _photos = [];
  List<String> _savedImages = [];

  // Form Fields State
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  ProductCategory _category = ProductCategory.vegetables;
  QualityGrade _qualityGrade = QualityGrade.a;
  QualityGrade? _gradeBeforeAi;
  String _gradingProductName = '';
  ProductUnit _unit = ProductUnit.kg;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;
    if (product != null) {
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toString();
      _qtyController.text = product.quantity.toString();
      _category = product.category;
      _qualityGrade = product.qualityGrade;
      _unit = product.unit;
      _savedImages = [...product.images];
      _visible = product.status == ProductStatus.active;
    }
    for (final controller in [
      _nameController,
      _descController,
      _priceController,
      _qtyController,
    ]) {
      controller.addListener(() {
        if (mounted) {
          setState(() {
            _allowExit = false;
          });
        }
      });
    }
    _nameController.addListener(() {
      final name = _nameController.text;
      if (name == _gradingProductName) return;
      _gradingProductName = name;
      _invalidateAiGrade();
    });
  }

  void _invalidateAiGrade() {
    final previous = _gradeBeforeAi;
    if (previous == null) return;
    setState(() {
      _qualityGrade = previous;
      _gradeBeforeAi = null;
    });
  }

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
      if (_dirty && !_allowExit) {
        _confirmLeave();
      } else {
        context.pop();
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey2.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_qtyController.text) ?? 0.0;

    bool published;
    try {
      if (_photos.isNotEmpty) {
        final uploaded = await ref
            .read(listingsRepositoryProvider)
            .uploadPhotos(_photos);
        if (uploaded.length != _photos.length) {
          throw StateError('Photo upload failed');
        }
        _savedImages = [..._savedImages, ...uploaded];
        _photos.clear();
      }
      published = await ref
          .read(listingsControllerProvider.notifier)
          .addListing(
            name: _nameController.text.trim(),
            category: _category,
            description: _descController.text.trim(),
            price: price,
            quantity: quantity,
            unit: _unit,
            qualityGrade: _qualityGrade,
            images: _savedImages,
            productId: widget.initialProduct?.id,
            original: widget.initialProduct,
            status: widget.initialProduct == null
                ? null
                : (_visible ? ProductStatus.active : ProductStatus.inactive),
          );
    } catch (_) {
      published = false;
    }
    if (mounted) setState(() => _submitting = false);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!published) {
      // Keep the form so nothing the farmer typed is lost.
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.listingPublishFailed),
          backgroundColor: AppColors.errorRed,
          duration: AppDurations.standardMessage,
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.initialProduct == null
              ? context.l10n.listingPublished
              : context.l10n.listingUpdated,
        ),
        backgroundColor: AppColors.success,
        duration: AppDurations.standardMessage,
      ),
    );
    // Reached either by push from My Listings or as its own bottom-nav tab.
    if (context.canPop()) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    } else {
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _qtyController.clear();
      setState(() {
        _currentStep = 0;
        _category = ProductCategory.vegetables;
        _qualityGrade = QualityGrade.a;
        _unit = ProductUnit.kg;
        _savedImages = [];
      });
      _pageController.jumpToPage(0);
      context.go(
        AppNavConfig.routeFor(AppUserRole.farmer, AppNavDestination.listings),
      );
    }
  }

  bool get _dirty {
    final product = widget.initialProduct;
    return _visible !=
            (product == null || product.status == ProductStatus.active) ||
        _nameController.text != (product?.name ?? '') ||
        _descController.text != (product?.description ?? '') ||
        _priceController.text != (product?.price.toString() ?? '') ||
        _qtyController.text != (product?.quantity.toString() ?? '') ||
        _category != (product?.category ?? ProductCategory.vegetables) ||
        _qualityGrade != (product?.qualityGrade ?? QualityGrade.a) ||
        _unit != (product?.unit ?? ProductUnit.kg) ||
        _photos.isNotEmpty ||
        _savedImages.join('|') != (product?.images.join('|') ?? '');
  }

  Future<void> _confirmLeave() async {
    if (_submitting || _askingToLeave) return;
    _askingToLeave = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.discardChangesTitle),
        content: Text(ctx.l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(ctx.l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(ctx.l10n.discardChanges),
          ),
        ],
      ),
    );
    _askingToLeave = false;
    if (discard == true && mounted) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _submitting || ref.watch(listingsControllerProvider).isLoading;

    return PopScope(
      canPop: !_submitting && (_allowExit || (_currentStep == 0 && !_dirty)),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_submitting) {
          if (_currentStep == 1) {
            _prevStep();
          } else {
            _confirmLeave();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            widget.initialProduct == null
                ? context.l10n.createListingTitle
                : context.l10n.editListingTitle,
            style: AppTextStyles.h2,
          ),
          elevation: 0,
          backgroundColor: AppColors.backgroundLight,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: isLoading ? null : _prevStep,
          ),
        ),
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: _submitting,
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
                          Flexible(
                            child: Text(
                              _currentStep == 0
                                  ? context.l10n.listingStepProduceDetails
                                  : context.l10n.listingStepPricingQuantity,
                              style: AppTextStyles.small.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
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
                              : widget.initialProduct == null
                              ? context.l10n.createListingTitle
                              : context.l10n.saveChanges,
                          isLoading: isLoading,
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
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (_pickingPhoto || _photos.length + _savedImages.length >= 4) return;
    setState(() => _pickingPhoto = true);
    try {
      final photo = await ref.read(photoPickerProvider)(ImageSource.gallery);
      if (photo == null || !mounted) return;
      final bytes = await photo.readAsBytes();
      final ext = photo.name.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => '',
      };
      if (mime.isEmpty || bytes.length > 5 * 1024 * 1024) {
        throw StateError('Invalid photo');
      }
      if (mounted) {
        setState(
          () => _photos.add(
            ListingPhoto(bytes: bytes, filename: photo.name, mimeType: mime),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.listingPhotoError)));
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Widget _buildPhotos() => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.listingPhotos, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(context.l10n.listingPhotosHint, style: AppTextStyles.small),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final url in _savedImages)
              SizedBox(
                width: 104,
                child: Column(
                  children: [
                    ProductPhoto(
                      url: url,
                      width: 104,
                      height: 88,
                      label: _nameController.text,
                    ),
                    IconButton(
                      tooltip: context.l10n.removeItem,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _savedImages.remove(url)),
                    ),
                    if (_savedImages.indexOf(url) > 0)
                      TextButton(
                        onPressed: () => setState(() {
                          _savedImages.remove(url);
                          _savedImages.insert(0, url);
                        }),
                        child: Text(context.l10n.listingUseCover),
                      ),
                  ],
                ),
              ),
            for (final photo in _photos)
              SizedBox(
                width: 104,
                child: Column(
                  children: [
                    Image.memory(
                      photo.bytes,
                      width: 104,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      tooltip: context.l10n.removeItem,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _photos.remove(photo)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (_savedImages.length + _photos.length < 4)
          AppButton(
            label: context.l10n.listingAddPhoto,
            icon: Icons.add_photo_alternate_outlined,
            isLoading: _pickingPhoto,
            variant: AppButtonVariant.quiet,
            onPressed: _pickPhoto,
          ),
      ],
    ),
  );

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: [
          _buildPhotos(),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.listingStepProduceDetails,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Name field
                AppTextField(
                  controller: _nameController,
                  label: context.l10n.produceName,
                  hintText: context.l10n.produceNameHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Category select
                DropdownButtonFormField<ProductCategory>(
                  isExpanded: true,
                  initialValue: _category,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(labelText: context.l10n.category),
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
                  isExpanded: true,
                  // Keyed so an AI-applied grade shows immediately.
                  key: ValueKey(_qualityGrade),
                  initialValue: _qualityGrade,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: context.l10n.qualityGrade,
                  ),
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
                    if (val != null) {
                      setState(() {
                        _qualityGrade = val;
                        _gradeBeforeAi = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // AI photo quality check (suggests a grade)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, name, _) => QualityCheckCard(
                    productName: name.text,
                    onInvalidateGrade: _invalidateAiGrade,
                    onApplyGrade: (grade) => setState(() {
                      _gradeBeforeAi ??= _qualityGrade;
                      _qualityGrade = grade;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description field
                AppTextField(
                  controller: _descController,
                  maxLines: 4,
                  alignLabelWithHint: true,
                  label: context.l10n.description,
                  hintText: context.l10n.descriptionHint,
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
                  context.l10n.listingStepPricingQuantity,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Price field
                AppTextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  label: context.l10n.priceWithCurrency,
                  hintText: context.l10n.priceHint,
                  prefixIcon: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.l10n.fieldRequired;
                    }
                    final price = double.tryParse(v);
                    if (price == null || !price.isFinite || price <= 0) {
                      return context.l10n.pleaseEnterValidPrice;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // AI fair-price suggestion (rule-based, labelled as such)
                PriceSuggestionCard(
                  productName: _nameController.text,
                  category: _category,
                  unit: _unit,
                  grade: _qualityGrade,
                  unitLabel: _unitLabel(context, _unit),
                  onApply: (price) => setState(
                    () => _priceController.text = price.toStringAsFixed(0),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Quantity field
                AppTextField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  label: context.l10n.quantity,
                  hintText: context.l10n.quantityHint,
                  prefixIcon: const Icon(
                    Icons.scale_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.l10n.fieldRequired;
                    }
                    final qty = double.tryParse(v);
                    if (qty == null ||
                        !qty.isFinite ||
                        qty < 0 ||
                        (widget.initialProduct == null && qty == 0)) {
                      return context.l10n.pleaseEnterValidQuantity;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                if (widget.initialProduct != null)
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile.adaptive(
                      title: Text(
                        context.l10n.listingShow,
                        style: AppTextStyles.body,
                      ),
                      value: _visible,
                      onChanged: (value) => setState(() => _visible = value),
                    ),
                  ),
                // Unit selector
                DropdownButtonFormField<ProductUnit>(
                  isExpanded: true,
                  initialValue: _unit,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(labelText: context.l10n.unit),
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

  String _unitLabel(BuildContext context, ProductUnit unit) => switch (unit) {
    ProductUnit.kg => context.l10n.unitKg,
    ProductUnit.ton => context.l10n.unitTon,
    ProductUnit.dozen => context.l10n.unitDozen,
    ProductUnit.piece => context.l10n.unitPiece,
    ProductUnit.litre => context.l10n.unitLitre,
  };
}
