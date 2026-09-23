import 'package:flutter/material.dart';

class GlueUIConfig {
  /// The default widget to show when indicating a loading state.
  final Widget? defaultIndicator;
  
  /// The default overlay color for loading indicators.
  final Color? overlayColor;
  
  const GlueUIConfig({
    this.defaultIndicator,
    this.overlayColor,
  });
}
