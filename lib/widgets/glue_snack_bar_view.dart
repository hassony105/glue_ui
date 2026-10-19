import 'package:flutter/material.dart';
import 'package:glue_ui/models/models.dart';
import 'package:glue_ui/enums/enums.dart';

/// The default look of a GlueUI snack bar.
///
/// Uses a type-based color and icon (see [SnackBarType]); [SnackBarType.normal]
/// follows the app's [SnackBarThemeData].
class GlueSnackBarView extends StatelessWidget {
  /// Creates a [GlueSnackBarView].
  const GlueSnackBarView({super.key, required this.data});

  /// The snack bar to render.
  final GlueSnackBarData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SnackBarThemeData snackTheme = theme.snackBarTheme;
    final TextTheme textTheme = theme.textTheme;

    final (Color background, Color foreground, IconData? icon) =
        switch (data.type) {
          SnackBarType.normal => (
            snackTheme.backgroundColor ?? theme.colorScheme.inverseSurface,
            snackTheme.contentTextStyle?.color ??
                theme.colorScheme.onInverseSurface,
            null,
          ),
          SnackBarType.success => (
            const Color(0xFF2E7D32),
            Colors.white,
            Icons.check_circle_rounded,
          ),
          SnackBarType.error => (
            const Color(0xFFC62828),
            Colors.white,
            Icons.error_rounded,
          ),
          SnackBarType.warning => (
            const Color(0xFFF9A825),
            const Color(0xFF1F1B16),
            Icons.warning_amber_rounded,
          ),
          SnackBarType.info => (
            const Color(0xFF1565C0),
            Colors.white,
            Icons.info_rounded,
          ),
        };

    final bool hasAction =
        data.actionLabel != null && data.onActionPressed != null;
    final String closeTooltip =
        Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        )?.closeButtonTooltip ??
        'Close';

    return Material(
      color: background,
      elevation: snackTheme.elevation ?? 6,
      shape:
          snackTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 16,
            end: hasAction || data.showCloseIcon ? 4 : 16,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.title != null)
                      Text(
                        data.title!,
                        style: textTheme.titleSmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      data.message,
                      style: (snackTheme.contentTextStyle ??
                              textTheme.bodyMedium)
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              if (hasAction)
                TextButton(
                  onPressed: data.onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(data.actionLabel!),
                ),
              if (data.showCloseIcon)
                IconButton(
                  onPressed: data.dismiss,
                  icon: const Icon(Icons.close_rounded),
                  color: foreground,
                  tooltip: closeTooltip,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
