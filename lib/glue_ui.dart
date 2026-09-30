import 'package:flutter/material.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/models/models.dart';

export 'package:sm_dialog/sm_dialog.dart' show DialogType;
export 'package:glue_ui/widgets/glue_app_delegate.dart';
export 'package:glue_ui/widgets/glue_scaffold.dart';
export 'package:glue_ui/widgets/glue_snack_bar_widget.dart';
export 'package:glue_ui/models/models.dart';
export 'package:glue_ui/services/services.dart' hide CustomException;

class GlueUI {
  static final GlueUI instance = GlueUI._();

  GlueUI._();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  final IndicatorService _loader = IndicatorService();
  final DialogService _dialog = DialogService();
  
  GlueUIConfig config = const GlueUIConfig();

  IndicatorService get loader => _loader;
  DialogService get dialog => _dialog;

  void initialize({GlueUIConfig config = const GlueUIConfig()}) {
    this.config = config;
  }
}