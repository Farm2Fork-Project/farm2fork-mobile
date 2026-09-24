import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/core/media/photo_picker.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _tags = TextEditingController();
  final List<XFile> _photos = [];
  bool _posting = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> get _parsedTags => {
    for (final raw in _tags.text.split(RegExp(r'[,\s]+')))
      if (raw.trim().replaceFirst('#', '').isNotEmpty)
        raw.trim().replaceFirst('#', '').toLowerCase(),
  }.toList();

  Future<void> _addPhoto(ImageSource source) async {
    final photo = await ref.read(photoPickerProvider)(source);
    if (photo != null && mounted) setState(() => _photos.add(photo));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _posting = true);
    try {
      final post = await ref
          .read(communityRepositoryProvider)
          .create(
            title: _title.text.trim(),
            content: _content.text.trim(),
            tags: _parsedTags,
            photos: _photos,
          );
      ref.invalidate(communityFeedProvider);
      if (mounted) context.pushReplacement('/community/posts/${post.id}');
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.communityActionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.newPost, style: AppTextStyles.h3)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              AppTextField(
                controller: _title,
                label: l10n.postTitleLabel,
                maxLength: 140,
                validator: required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _content,
                label: l10n.postContentLabel,
                maxLines: 6,
                maxLength: 5000,
                validator: required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _tags,
                label: l10n.postTagsLabel,
                hintText: l10n.postTagsHint,
                validator: (_) => _parsedTags.length > maxPostTags
                    ? l10n.postTooManyTags(maxPostTags)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.postPhotosLabel(maxPostPhotos),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final photo in _photos)
                    InputChip(
                      avatar: const Icon(Icons.image_rounded, size: 18),
                      label: Text(photo.name, overflow: TextOverflow.ellipsis),
                      onDeleted: () => setState(() => _photos.remove(photo)),
                    ),
                  if (_photos.length < maxPostPhotos) ...[
                    ActionChip(
                      avatar: const Icon(Icons.photo_camera_rounded, size: 18),
                      label: Text(l10n.takePhoto),
                      onPressed: () => _addPhoto(ImageSource.camera),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(l10n.chooseFromGallery),
                      onPressed: () => _addPhoto(ImageSource.gallery),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.publishPost,
                icon: Icons.send_rounded,
                expand: true,
                isLoading: _posting,
                onPressed: _posting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
