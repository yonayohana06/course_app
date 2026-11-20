import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }
}
