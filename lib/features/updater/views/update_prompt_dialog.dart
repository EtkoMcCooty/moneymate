import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_release.dart';
import '../services/apk_download_service.dart';

/// Modal dialog prompting the user when a new version of MoneyMate is available,
/// downloading and installing the update directly within the app.
class UpdatePromptDialog extends StatefulWidget {
  final AppRelease release;
  final String currentVersion;
  final ApkDownloadService? downloadService;

  const UpdatePromptDialog({
    super.key,
    required this.release,
    required this.currentVersion,
    this.downloadService,
  });

  /// Displays the update dialog modally.
  static Future<void> show(
    BuildContext context, {
    required AppRelease release,
    required String currentVersion,
    ApkDownloadService? downloadService,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdatePromptDialog(
        release: release,
        currentVersion: currentVersion,
        downloadService: downloadService,
      ),
    );
  }

  @override
  State<UpdatePromptDialog> createState() => _UpdatePromptDialogState();
}

class _UpdatePromptDialogState extends State<UpdatePromptDialog> {
  late final ApkDownloadService _downloadService;
  bool _isDownloading = false;
  bool _isInstalling = false;
  DownloadProgress? _progress;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadService = widget.downloadService ?? ApkDownloadService();
  }

  @override
  void dispose() {
    if (_isDownloading) {
      _downloadService.cancel();
    }
    super.dispose();
  }

  Future<void> _startInAppUpdate() async {
    final apkUrl = widget.release.apkUrl;
    if (apkUrl == null || apkUrl.isEmpty) {
      setState(() {
        _errorMessage = 'No download link available for this release.';
      });
      return;
    }

    // If not on Android or not an APK link, fall back to browser download
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isApk = apkUrl.toLowerCase().contains('.apk');

    if (!isAndroid || !isApk) {
      await _openInBrowser();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isDownloading = true;
      _isInstalling = false;
      _progress = null;
      _errorMessage = null;
    });

    try {
      final result = await _downloadService.downloadAndInstall(
        url: apkUrl,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _isInstalling = true;
      });

      if (result.type != ResultType.done) {
        setState(() {
          _isInstalling = false;
          _errorMessage = result.message.isNotEmpty
              ? result.message
              : 'Could not launch package installer.';
        });
      } else {
        // Successfully opened installer intent
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _isInstalling = false;
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      });
    }
  }

  Future<void> _openInBrowser() async {
    final urlString = widget.release.apkUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.tryParse(urlString);
      if (uri != null) {
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            await launchUrl(uri);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open browser: $e')),
            );
          }
        }
      }
    }
  }

  void _cancelDownload() {
    _downloadService.cancel();
    setState(() {
      _isDownloading = false;
      _progress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isDownloading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isDownloading) {
          _cancelDownload();
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _isDownloading
                  ? Icons.download_rounded
                  : Icons.system_update_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(_isDownloading ? 'Downloading Update...' : 'Update Available!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${widget.release.version} is now ready to download.',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Current: ${widget.currentVersion}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Downloading Progress Section
              if (_isDownloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress?.progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _progress?.percentString.isNotEmpty == true
                          ? '${_progress!.percentString} downloaded'
                          : 'Downloading...',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _progress != null
                          ? '${_progress!.receivedFormatted} / ${_progress!.totalFormatted}'
                          : '',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else if (_isInstalling) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Opening installer...',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 20, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Release Notes / What's New section
              if (widget.release.notes.isNotEmpty) ...[
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
                    widget.release.notes,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (_isDownloading) ...[
            TextButton(
              onPressed: _cancelDownload,
              child: const Text('Cancel'),
            ),
          ] else if (_errorMessage != null) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            TextButton(
              onPressed: () async {
                await _openInBrowser();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Open in Browser'),
            ),
            FilledButton(
              onPressed: _startInAppUpdate,
              child: const Text('Retry'),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: _isInstalling ? null : _startInAppUpdate,
              child: const Text('Update Now'),
            ),
          ],
        ],
      ),
    );
  }
}
