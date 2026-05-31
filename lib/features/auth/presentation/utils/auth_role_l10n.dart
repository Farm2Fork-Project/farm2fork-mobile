import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';

extension AppUserRolePresentation on AppUserRole {
  String localizedLabel(BuildContext context) {
    return switch (this) {
      AppUserRole.farmer => context.l10n.roleFarmer,
      AppUserRole.buyer => context.l10n.roleBuyer,
      AppUserRole.transporter => context.l10n.roleTransporter,
      AppUserRole.financialPartner => context.l10n.roleFinancialPartner,
      AppUserRole.admin => context.l10n.roleAdmin,
    };
  }

  String localizedDescription(BuildContext context) {
    return switch (this) {
      AppUserRole.farmer => context.l10n.farmerRoleDescription,
      AppUserRole.buyer => context.l10n.buyerRoleDescription,
      AppUserRole.transporter => context.l10n.transporterRoleDescription,
      AppUserRole.financialPartner =>
        context.l10n.financialPartnerRoleDescription,
      AppUserRole.admin => context.l10n.adminRoleDescription,
    };
  }

  IconData get icon {
    return switch (this) {
      AppUserRole.farmer => Icons.agriculture_rounded,
      AppUserRole.buyer => Icons.shopping_basket_rounded,
      AppUserRole.transporter => Icons.local_shipping_rounded,
      AppUserRole.financialPartner => Icons.account_balance_rounded,
      AppUserRole.admin => Icons.admin_panel_settings_rounded,
    };
  }
}
