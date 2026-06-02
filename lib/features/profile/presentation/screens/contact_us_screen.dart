import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _subject = 'General';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate network submission
    Future<void>.delayed(const Duration(milliseconds: 800)).then((_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.contactMessageSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.contactUsTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Text(
              context.l10n.contactUsSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Form card
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subject dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _subject,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        labelText: context.l10n.contactSubject,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'General',
                          child: Text(context.l10n.contactSubjectGeneral),
                        ),
                        DropdownMenuItem(
                          value: 'Listing',
                          child: Text(context.l10n.contactSubjectListing),
                        ),
                        DropdownMenuItem(
                          value: 'Payment',
                          child: Text(context.l10n.contactSubjectPayment),
                        ),
                        DropdownMenuItem(
                          value: 'Transport',
                          child: Text(context.l10n.contactSubjectTransport),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _subject = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Message field
                    TextFormField(
                      controller: _messageController,
                      style: AppTextStyles.body,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: context.l10n.contactMessage,
                        hintText: context.l10n.contactMessageHint,
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? context.l10n.pleaseEnterMessage
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppButton(
                      label: context.l10n.contactSubmit,
                      variant: AppButtonVariant.primary,
                      onPressed: _isSubmitting ? null : _submitForm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Help info details cards
            AppCard(
              child: Column(
                children: [
                  _buildContactInfoTile(
                    context,
                    title: context.l10n.contactEmail,
                    value: 'support@farm2fork.pk',
                    icon: Icons.email_outlined,
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _buildContactInfoTile(
                    context,
                    title: context.l10n.contactPhone,
                    value: '0800-FARM2FORK (32762)',
                    icon: Icons.phone_outlined,
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _buildContactInfoTile(
                    context,
                    title: context.l10n.contactAddress,
                    value: 'Awan-e-Zaraat Building, Lahore, Pakistan',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreenDark,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
