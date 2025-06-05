import 'dart:async';

import 'package:flutter/cupertino.dart';

///The inherited widget that guarantees the behavior of the overlay
class IndicatorControllerWidget extends InheritedWidget {
  IndicatorControllerWidget({
    super.key,
    required super.child,
  });

  static IndicatorControllerWidget? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<IndicatorControllerWidget>();

  final StreamController<Map<String, dynamic>> visibilityController =
  StreamController();

  Stream<Map<String, dynamic>> get visibilityStream =>
      visibilityController.stream;

  ///Set the visibility of the overlay
  void setOverlayVisible(
      bool loading, {
        Widget Function(dynamic progress)? widgetBuilder,
        dynamic progress,
        bool showOverlay = true,
      }) =>
      visibilityController.add(<String, dynamic>{
        'loading': loading,
        'widget_builder': widgetBuilder,
        'progress': progress,
        'show_overlay': showOverlay,
      });

  ///Dispose the controller
  void dispose() => visibilityController.close();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
