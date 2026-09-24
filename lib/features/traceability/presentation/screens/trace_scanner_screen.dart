import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository_provider.dart';
import 'package:farm2fork_mobile/features/traceability/data/utils/trace_id_parser.dart';
import 'package:farm2fork_mobile/features/traceability/presentation/widgets/trace_journey_view.dart';

sealed class _LookupState {
  const _LookupState();
}

class _Idle extends _LookupState {
  const _Idle({this.invalidInput = false});
  final bool invalidInput;
}

class _Loading extends _LookupState {
  const _Loading();
}

class _NotFound extends _LookupState {
  const _NotFound();
}

class _Failed extends _LookupState {
  const _Failed(this.productId);
  final String productId;
}

class _Loaded extends _LookupState {
  const _Loaded(this.trace);
  final ProductTrace trace;
}

/// Product trace lookup. Opened from the Trace tab (enter an id or paste a
/// QR link) or from a product/QR deep link with [initialProductId], in which
/// case it loads that journey straight away.
///
/// Camera scanning is not wired yet; the screen says so instead of showing
/// a fake viewfinder.
class TraceScannerScreen extends ConsumerStatefulWidget {
  const TraceScannerScreen({super.key, this.initialProductId});

  final String? initialProductId;

  @override
  ConsumerState<TraceScannerScreen> createState() => _TraceScannerScreenState();
}

class _TraceScannerScreenState extends ConsumerState<TraceScannerScreen> {
  final _inputController = TextEditingController();
  _LookupState _state = const _Idle();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProductId;
    if (initial != null) {
      final id = parseTraceProductId(initial);
      if (id == null) {
        _state = const _NotFound();
      } else {
        _state = const _Loading();
        // After the first frame so ref is safe to read.
        WidgetsBinding.instance.addPostFrameCallback((_) => _lookup(id));
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _lookup(String productId) async {
    setState(() => _state = const _Loading());
    try {
      final trace = await ref
          .read(traceabilityRepositoryProvider)
          .fetchProductTrace(productId);
      if (!mounted) return;
      setState(
        () => _state = trace == null ? const _NotFound() : _Loaded(trace),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _Failed(productId));
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final id = parseTraceProductId(_inputController.text);
    if (id == null) {
      setState(() => _state = const _Idle(invalidInput: true));
      return;
    }
    _lookup(id);
  }

  void _reset() {
    _inputController.clear();
    setState(() => _state = const _Idle());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showReset =
        widget.initialProductId == null &&
        (_state is _Loaded || _state is _NotFound);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.traceScannerTitle, style: AppTextStyles.h2),
        actions: [
          if (showReset)
            IconButton(
              tooltip: l10n.traceSearchAnother,
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryGreen,
              ),
              onPressed: _reset,
            ),
        ],
      ),
      body: SafeArea(
        child: switch (_state) {
          _Loading() => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryGreen),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.traceLoading,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _NotFound() => _NotFoundView(
            onSearchAgain: widget.initialProductId == null ? _reset : null,
          ),
          _Failed(:final productId) => AppErrorState(
            message: l10n.traceLoadFailed,
            onRetry: () => _lookup(productId),
          ),
          _Loaded(:final trace) => TraceJourneyView(trace: trace),
          _Idle(:final invalidInput) => _LookupForm(
            controller: _inputController,
            invalidInput: invalidInput,
            onSubmit: _submit,
          ),
        },
      ),
    );
  }
}

class _LookupForm extends StatelessWidget {
  const _LookupForm({
    required this.controller,
    required this.invalidInput,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool invalidInput;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryGreenSoft,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.traceScannerDescription,
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Directionality(
          // Ids and links are always left-to-right, even in Urdu.
          textDirection: TextDirection.ltr,
          child: AppTextField(
            controller: controller,
            label: l10n.traceInputLabel,
            hintText: l10n.traceInputHint,
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.link_rounded),
          ),
        ),
        if (invalidInput) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.traceInvalidInput,
              style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.traceSearchButton,
          icon: Icons.search_rounded,
          expand: true,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          backgroundColor: AppColors.surfaceLight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.traceCameraComingSoon,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({this.onSearchAgain});

  final VoidCallback? onSearchAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEmptyState(
              icon: Icons.search_off_rounded,
              message: l10n.traceNotFoundTitle,
              subtitle: l10n.traceNotFoundDesc,
            ),
            if (onSearchAgain != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.traceSearchAnother,
                variant: AppButtonVariant.secondary,
                onPressed: onSearchAgain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
