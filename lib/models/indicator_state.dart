import 'package:flutter/widgets.dart';

class IndicatorState {
  final bool isLoading;
  final Widget Function(dynamic)? widgetBuilder;
  final dynamic progress;
  final bool showOverlay;

  const IndicatorState({
    this.isLoading = false,
    this.widgetBuilder,
    this.progress,
    this.showOverlay = true,
  });
}
