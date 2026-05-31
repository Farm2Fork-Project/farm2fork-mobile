import 'package:flutter/widgets.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

String productUnitLabel(BuildContext context, ProductUnit unit) =>
    switch (unit) {
      ProductUnit.kg => context.l10n.unitKg,
      ProductUnit.ton => context.l10n.unitTon,
      ProductUnit.dozen => context.l10n.unitDozen,
      ProductUnit.piece => context.l10n.unitPiece,
      ProductUnit.litre => context.l10n.unitLitre,
    };

String qualityGradeLabel(BuildContext context, QualityGrade grade) =>
    switch (grade) {
      QualityGrade.a => context.l10n.gradeA,
      QualityGrade.b => context.l10n.gradeB,
      QualityGrade.c => context.l10n.gradeC,
    };

String productStatusLabel(BuildContext context, ProductStatus status) =>
    switch (status) {
      ProductStatus.active => context.l10n.productStatusActive,
      ProductStatus.inactive => context.l10n.productStatusInactive,
      ProductStatus.soldOut => context.l10n.productStatusSoldOut,
    };
