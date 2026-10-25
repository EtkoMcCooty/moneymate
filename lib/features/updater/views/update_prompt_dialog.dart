import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_release.dart';

/// Modal dialog prompting the user when a new version of MoneyMate is available.
class UpdatePromptDialog extends StatelessWidget {
  final AppRelease release;
  final String currentVersion;

  const UpdatePromptDialog({
    super.key,
    required this.release,
    required this.currentVersion,
  });

  /// Displays the update dialog modally.
  static Future<void> show(
    BuildContext context, {
    required AppRelease release,
    required String currentVersion,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpdatePromptDialog(
        release: release,
        currentVersion: currentVersion,
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context) async {
    final urlString = release.apkUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.tryParse(urlString);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Text('Update Available!'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${release.version} is now ready to download.',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Current: $currentVersion',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (release.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "What's New:",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  release.notes,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => _handleUpdate(context),
          child: const Text('Update Now'),
        ),
      ],
    );
  }
}
