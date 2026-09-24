import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';

/// A small circular icon button (quantity steppers, "add" actions) whose tap
/// target is always at least the 44x44 platform minimum, independent of how
/// small the visible circle looks. Wrap the decoration in an invisible
/// [SizedBox] rather than growing the decoration itself, so existing call
/// sites keep their current visual density.
class AppIconCircleButton extends StatelessWidget {
  const AppIconCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.filled = false,
    this.visibleSize = 32,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool filled;
  final double visibleSize;

  static const double minTapTarget = 44;

  @override
  Widget build(BuildContext context) {
    final iconSize = visibleSize * 0.5;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: minTapTarget,
        height: minTapTarget,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: visibleSize,
            height: visibleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? (enabled
                        ? AppColors.primaryGreen
                        : AppColors.textDark.withValues(alpha: 0.2))
                  : (enabled
                        ? AppColors.primaryGreenSoft
                        : AppColors.surfaceMedium),
              border: filled
                  ? null
                  : Border.all(
                      color: enabled
                          ? AppColors.primaryGreen.withValues(alpha: 0.5)
                          : AppColors.surfaceMedium,
                    ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: filled
                  ? (enabled
                        ? AppColors.white
                        : AppColors.textDark.withValues(alpha: 0.4))
                  : (enabled
                        ? AppColors.primaryGreen
                        : AppColors.textDark.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }
}
