import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/bidi_utils.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/utils/trace_id_parser.dart';

/// Renders a product's public provenance: whether its origin is proven on
/// the ledger, the listing and farm, and every supply-chain event with its
/// own Hyperledger Fabric state. Pending and failed ledger states are shown
/// as exactly that - never with the green "verified" treatment.
class TraceJourneyView extends StatelessWidget {
  const TraceJourneyView({super.key, required this.trace});

  final ProductTrace trace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        _OriginBanner(origin: trace.origin),
        const SizedBox(height: AppSpacing.md),
        _ProductCard(trace: trace),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.traceJourneyTitle, style: AppTextStyles.h3),
            if (trace.totalEvents > 0)
              AppBadge(
                label: l10n.traceLedgerProgress(
                  trace.confirmedEvents,
                  trace.totalEvents,
                ),
                backgroundColor: AppColors.primaryGreenSoft,
                foregroundColor: AppColors.primaryGreenDark,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (trace.events.isEmpty)
          AppCard(
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              l10n.traceJourneyEmpty,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          for (var i = 0; i < trace.events.length; i++)
            _TimelineItem(
              event: trace.events[i],
              isLast: i == trace.events.length - 1,
            ),
      ],
    );
  }
}

class _OriginBanner extends StatelessWidget {
  const _OriginBanner({required this.origin});

  final TraceOrigin origin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, title, body, background, border, accent) = switch (origin) {
      TraceOrigin.verified => (
        Icons.verified_user_rounded,
        l10n.traceOriginVerified,
        l10n.traceOriginVerifiedDesc,
        AppColors.primaryGreenSoft,
        AppColors.surfaceStrong,
        AppColors.primaryGreenDark,
      ),
      TraceOrigin.pending => (
        Icons.hourglass_top_rounded,
        l10n.traceOriginPending,
        l10n.traceOriginPendingDesc,
        AppColors.accentYellowSoft,
        AppColors.accentYellow,
        AppColors.textDark,
      ),
      TraceOrigin.missing => (
        Icons.gpp_maybe_rounded,
        l10n.traceOriginMissing,
        l10n.traceOriginMissingDesc,
        AppColors.surfaceLight,
        AppColors.surfaceMedium,
        AppColors.textMuted,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: true,
      child: AppCard(
        backgroundColor: background,
        borderColor: border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.white,
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3.copyWith(color: accent)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
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
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.trace});

  final ProductTrace trace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = trace.product;
    final farm = trace.farm;
    final grade = product.qualityGrade;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _statusLabel(l10n, product.status),
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          const Divider(height: AppSpacing.xxl, color: AppColors.surfaceMedium),
          _DetailRow(
            label: l10n.traceSourceFarm,
            value: farm == null
                ? l10n.traceFarmUnknown
                : [farm.farmName, farm.place].whereType<String>().join(' · '),
            muted: farm == null,
          ),
          _DetailRow(
            label: l10n.traceQualityGrade,
            value: grade == null
                ? l10n.traceGradeNone
                : l10n.traceGradeValue(grade.name.toUpperCase()),
          ),
          _DetailRow(
            label: l10n.traceListedOn,
            value: _formatDateTime(context, product.listedAt),
          ),
          _DetailRow(
            label: l10n.traceProductId,
            value: isolateLtr(product.id),
            monospace: true,
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, ProductStatus status) =>
      switch (status) {
        ProductStatus.active => l10n.traceStatusActive,
        ProductStatus.soldOut => l10n.traceStatusSoldOut,
        ProductStatus.inactive => l10n.traceStatusInactive,
      };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool muted;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
              color: muted ? AppColors.textMuted : AppColors.textDark,
              fontFamily: monospace ? 'monospace' : null,
              fontSize: monospace ? AppTextStyles.small.fontSize : null,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Role { farmer, buyer, transporter }

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});

  final TraceEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, title, role) = switch (event.type) {
      TraceEventType.listed => (
        Icons.storefront_rounded,
        l10n.traceEventListed,
        _Role.farmer,
      ),
      TraceEventType.paymentConfirmed => (
        Icons.payments_rounded,
        l10n.traceEventPaymentConfirmed,
        _Role.buyer,
      ),
      TraceEventType.shipmentAssigned => (
        Icons.assignment_ind_rounded,
        l10n.traceEventShipmentAssigned,
        _Role.transporter,
      ),
      TraceEventType.shipmentPickedUp => (
        Icons.inventory_2_rounded,
        l10n.traceEventShipmentPickedUp,
        _Role.transporter,
      ),
      TraceEventType.shipmentInTransit => (
        Icons.local_shipping_rounded,
        l10n.traceEventShipmentInTransit,
        _Role.transporter,
      ),
      TraceEventType.shipmentDelivered => (
        Icons.check_circle_rounded,
        l10n.traceEventShipmentDelivered,
        _Role.transporter,
      ),
      TraceEventType.shipmentFailed => (
        Icons.cancel_rounded,
        l10n.traceEventShipmentFailed,
        _Role.transporter,
      ),
    };
    final (roleLabel, roleBackground, roleForeground) = switch (role) {
      _Role.farmer => (
        l10n.traceRoleFarmer,
        AppColors.primaryGreenSoft,
        AppColors.primaryGreenDark,
      ),
      _Role.buyer => (
        l10n.traceRoleBuyer,
        AppColors.secondaryBlueSoft,
        AppColors.secondaryBlue,
      ),
      _Role.transporter => (
        l10n.traceRoleTransporter,
        AppColors.accentYellowSoft,
        AppColors.textDark,
      ),
    };
    final failedEvent = event.type == TraceEventType.shipmentFailed;
    final committed = event.ledger.status == TraceLedgerStatus.confirmed;
    final dotColor = failedEvent
        ? AppColors.errorRed
        : committed
        ? AppColors.primaryGreen
        : AppColors.surfaceStrong;
    final reference = event.reference == null
        ? null
        : event.type == TraceEventType.paymentConfirmed
        ? l10n.traceReferenceSale(isolateLtr(event.reference!))
        : l10n.traceReferenceDelivery(isolateLtr(event.reference!));
    final place = [event.location, reference].whereType<String>().join(' · ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: committed && !failedEvent
                        ? AppColors.primaryGreenSoft
                        : AppColors.white,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: failedEvent
                        ? AppColors.errorRed
                        : committed
                        ? AppColors.primaryGreen
                        : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      color: AppColors.surfaceMedium,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            _formatDateTime(context, event.occurredAt),
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppBadge(
                      label: roleLabel,
                      backgroundColor: roleBackground,
                      foregroundColor: roleForeground,
                    ),
                    if (place.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              place,
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _LedgerProof(ledger: event.ledger),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerProof extends StatelessWidget {
  const _LedgerProof({required this.ledger});

  final TraceLedger ledger;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (
      icon,
      label,
      background,
      border,
      foreground,
    ) = switch (ledger.status) {
      TraceLedgerStatus.confirmed => (
        Icons.lock_rounded,
        l10n.traceLedgerConfirmed,
        AppColors.surfaceLight,
        AppColors.surfaceMedium,
        AppColors.success,
      ),
      TraceLedgerStatus.pending => (
        Icons.hourglass_top_rounded,
        l10n.traceLedgerPending,
        AppColors.accentYellowSoft,
        AppColors.accentYellow,
        AppColors.textDark,
      ),
      TraceLedgerStatus.failed => (
        Icons.error_outline_rounded,
        l10n.traceLedgerFailed,
        AppColors.white,
        AppColors.errorRed,
        AppColors.errorRed,
      ),
    };
    final hash = ledger.txHash;
    final block = ledger.blockNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.small.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (ledger.status == TraceLedgerStatus.confirmed &&
              (hash != null || block != null)) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              [
                if (hash != null) isolateLtr(shortenTxHash(hash)),
                if (block != null) l10n.traceLedgerBlock(block),
              ].join('  ·  '),
              style: AppTextStyles.small.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Date plus 12-hour time with a localized AM/PM marker. intl's own Urdu
/// data renders the marker as a bare "a"/"p", which readers don't recognise.
String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final marker = value.hour < 12 ? context.l10n.timeAm : context.l10n.timePm;
  return '${DateFormat.yMMMd(locale).format(value)} '
      '${DateFormat('h:mm', locale).format(value)} $marker';
}
