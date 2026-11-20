import 'package:material_ui/material_ui.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Widget? customAction;

  const AppEmptyState({
    super.key,
    this.title = 'Belum ada konten',
    this.message = 'Silakan coba kembali nanti atau sesuaikan filter Anda.',
    this.icon = Icons.school_outlined,
    this.onAction,
    this.actionLabel,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.verticalLg,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading3,
            ),
            AppSpacing.verticalSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (customAction != null) ...[
              AppSpacing.verticalXl,
              customAction!,
            ] else if (onAction != null && actionLabel != null) ...[
              AppSpacing.verticalXl,
              AppButton(
                label: actionLabel!,
                icon: Icons.refresh_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
