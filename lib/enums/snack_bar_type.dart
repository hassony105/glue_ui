/// The visual style of a snack bar shown by `GlueUI.instance.snackBar`.
///
/// Each type maps to a default background color and leading icon.
enum SnackBarType {
  /// A neutral snack bar that follows the app's [SnackBarThemeData].
  normal,

  /// A green snack bar with a check icon.
  success,

  /// A red snack bar with an error icon.
  error,

  /// An amber snack bar with a warning icon.
  warning,

  /// A blue snack bar with an info icon.
  info,
}

/// Where a snack bar appears on the screen.
enum SnackBarPosition {
  /// Slides in from the top edge, below the status bar.
  top,

  /// Slides in from the bottom edge, above the keyboard and system insets.
  bottom,
}
