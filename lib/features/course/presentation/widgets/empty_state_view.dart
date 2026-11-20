import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateView({
    super.key,
    this.title = 'Belum ada kursus tersedia',
    this.message = 'Silakan coba kembali nanti atau ubah filter pencarian Anda.',
    this.icon = Icons.school_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: icon,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}
