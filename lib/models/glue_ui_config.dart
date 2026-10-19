import 'package:flutter/material.dart';

import 'glue_snack_bar_data.dart';
import '../enums/snack_bar_type.dart';

class GlueUIConfig {
  /// The default widget to show when indicating a loading state.
  final Widget? defaultIndicator;
  
  /// The default overlay color for loading indicators.
  final Color? overlayColor;

  /// How long a snack bar stays visible when `duration` isn't passed to
  /// `GlueUI.instance.snackBar.show()`. Defaults to 4 seconds.
  final Duration snackBarDuration;

  /// Where snack bars appear when `position` isn't passed to
  /// `GlueUI.instance.snackBar.show()`. Defaults to [SnackBarPosition.bottom].
  final SnackBarPosition snackBarPosition;

  /// Optional builder that replaces the default snack bar look for every
  /// snack bar (unless a per-call `builder` is provided).
  final GlueSnackBarBuilder? snackBarBuilder;
  
  const GlueUIConfig({
    this.defaultIndicator,
    this.overlayColor,
    this.snackBarDuration = const Duration(seconds: 4),
    this.snackBarPosition = SnackBarPosition.bottom,
    this.snackBarBuilder,
  });
}
