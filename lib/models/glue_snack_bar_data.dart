import 'package:flutter/widgets.dart';

import '../enums/snack_bar_type.dart';

/// Builds a fully custom snack bar body from [GlueSnackBarData].
///
/// The returned widget only replaces the *visual* part of the snack bar.
/// Positioning, entrance/exit animations, swipe-to-dismiss and the
/// auto-hide timer are still handled by GlueUI.
typedef GlueSnackBarBuilder =
    Widget Function(BuildContext context, GlueSnackBarData data);

/// Immutable description of a snack bar passed to a [GlueSnackBarBuilder].
class GlueSnackBarData {
  /// Unique identifier of the snack bar. Can be passed to
  /// `GlueUI.instance.snackBar.hide(key)`.
  final UniqueKey key;

  /// The main text of the snack bar.
  final String message;

  /// Optional bold text shown above [message].
  final String? title;

  /// The visual style of the snack bar.
  final SnackBarType type;

  /// Where the snack bar is displayed.
  final SnackBarPosition position;

  /// Label of the optional action button.
  final String? actionLabel;

  /// Whether a close icon should be shown.
  final bool showCloseIcon;

  /// Invokes the user's `onAction` callback and then hides the snack bar
  /// with [SnackBarClosedReason.action]. `null` when no action was provided.
  final VoidCallback? onActionPressed;

  /// Hides the snack bar with [SnackBarClosedReason.dismiss].
  final VoidCallback dismiss;

  /// Creates a [GlueSnackBarData].
  const GlueSnackBarData({
    required this.key,
    required this.message,
    required this.type,
    required this.position,
    required this.dismiss,
    this.title,
    this.actionLabel,
    this.onActionPressed,
    this.showCloseIcon = false,
  });
}
