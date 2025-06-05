import 'package:flutter/material.dart';
import 'package:glue_ui/glue_ui.dart';





///Just a extension to make it cleaner to show or hide the overlay
extension IndicatorControllerWidgetExtension on BuildContext {
  IndicatorService get loaderOverlay =>
      IndicatorService._(IndicatorControllerWidget.of(this));
}

class IndicatorService {
  late IndicatorControllerWidget _overlayController;

  Widget Function(dynamic progress)? _widgetBuilder;
  bool? _visible;

  IndicatorControllerWidget get overlayController => _overlayController;

  bool get visible => _visible ?? false;

  IndicatorService._(IndicatorControllerWidget? overlayController) {
    if (overlayController != null) {
      _overlayController = overlayController;
    }
  }

  void show({
    Widget Function(dynamic progress)? widgetBuilder,
    dynamic progress,
    bool showOverlay = true,
  }) {
    _widgetBuilder = widgetBuilder;
    _visible = true;
    _overlayController.setOverlayVisible(
      _visible!,
      widgetBuilder: _widgetBuilder,
      progress: progress,
      showOverlay: showOverlay,
    );
  }



  void hide() {
    _visible = false;
    _overlayController.setOverlayVisible(_visible!);
  }
}
