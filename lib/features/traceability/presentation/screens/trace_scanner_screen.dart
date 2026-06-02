import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/mock_traceability_repository.dart';

class TraceScannerScreen extends ConsumerStatefulWidget {
  const TraceScannerScreen({super.key});

  @override
  ConsumerState<TraceScannerScreen> createState() => _TraceScannerScreenState();
}

class _TraceScannerScreenState extends ConsumerState<TraceScannerScreen> {
  bool _isScanning = true;
  List<TraceabilityEvent> _journey = [];
  bool _isLoading = false;

  Future<void> _simulateScan() async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    final repo = ref.read(traceabilityRepositoryProvider);
    final journey = await repo.fetchTraceJourney('prod_001');

    if (!mounted) return;
    setState(() {
      _journey = journey;
      _isLoading = false;
    });
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _journey = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.traceScannerTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        actions: [
          if (!_isScanning)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryGreen,
              ),
              onPressed: _resetScanner,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : _isScanning
            ? _buildScannerMock()
            : _buildJourneyTimeline(),
      ),
    );
  }

  Widget _buildScannerMock() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing scan frame overlay
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryGreen, width: 4),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Stack(
                    children: [
                      // Scanner red scanning line animation simulation
                      Positioned(
                        top: 120,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.8),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.errorRed,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 160,
                  color: AppColors.textDark.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: Column(
              children: [
                Text(
                  context.l10n.traceScannerDescription,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _simulateScan,
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.white,
                    ),
                    label: Text(
                      'Simulate Scan (Scan Tomatoes)',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyTimeline() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Product Scanned summary header card
        AppCard(
          backgroundColor: AppColors.primaryGreenSoft,
          borderColor: AppColors.primaryGreen.withValues(alpha: 0.3),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGreen,
                child: Icon(Icons.verified_rounded, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organic Tomatoes', style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      'Verified Blockchain Trace Ledger',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primaryGreenDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Vertical Blockchain timeline
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _journey.length,
          itemBuilder: (context, index) {
            final event = _journey[index];
            final isLast = index == _journey.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            _getEventIcon(event.eventType),
                            size: 14,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2.5,
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.eventType,
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primaryGreenDark,
                                    ),
                                  ),
                                ),
                                AppBadge(
                                  label: event.actorRole,
                                  backgroundColor: AppColors.secondaryBlueSoft,
                                  foregroundColor: AppColors.secondaryBlue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(event.details, style: AppTextStyles.body),
                            const SizedBox(height: AppSpacing.md),

                            // Blockchain transaction footer box
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                border: Border.all(
                                  color: AppColors.surfaceMedium,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event.txHash,
                                      style: AppTextStyles.small.copyWith(
                                        fontFamily: 'Courier',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getEventIcon(String type) {
    if (type.contains('Listing')) return Icons.inventory_2_rounded;
    if (type.contains('Payment')) return Icons.payments_rounded;
    if (type.contains('Dispatch') || type.contains('transporter')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.verified_rounded;
  }
}
