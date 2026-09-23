import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glue_ui/models/models.dart';

class IndicatorService {
  final StreamController<IndicatorState> _visibilityController = StreamController<IndicatorState>.broadcast();

  bool _visible = false;

  Stream<IndicatorState> get visibilityStream => _visibilityController.stream;

  bool get visible => _visible;

  IndicatorService();

  void show({
    Widget Function(dynamic progress)? widgetBuilder,
    dynamic progress,
    bool showOverlay = true,
  }) {
    _visible = true;
    _visibilityController.add(IndicatorState(
      isLoading: true,
      widgetBuilder: widgetBuilder,
      progress: progress,
      showOverlay: showOverlay,
    ));
  }

  void hide() {
    _visible = false;
    _visibilityController.add(const IndicatorState(isLoading: false));
  }
  
  void dispose() {
    _visibilityController.close();
  }
}
