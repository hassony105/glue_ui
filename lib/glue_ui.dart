import 'package:flutter/material.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/widgets/controller_widget.dart';
//
// // Export the DialogType enum from the sm_dialog package for convenience.
export 'package:sm_dialog/sm_dialog.dart' show DialogType;
export './widgets/widgets.dart';


class GlueUI {
  static GlueUI instance = GlueUI._();

  GlueUI._();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  IndicatorService? get loader => navigatorKey.currentContext?.loader;

}

extension _IndicatorControllerWidgetExtension on BuildContext {
  IndicatorService get loader => IndicatorService(IndicatorControllerWidget.of(this));
}