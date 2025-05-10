import 'package:flutter/material.dart';
import 'package:glue_ui/services/services.dart';
export 'package:sm_dialog/sm_dialog.dart' show DialogType;

class GlueUI {
  GlueUI._();

  void initialize({
    required BuildContext context,
    required GlobalKey<ScaffoldMessengerState> smKey,
    Widget? indicatorWidget,
    ImageProvider? logoImage,
  }) {
    _context = context;
    _smKey = smKey;
    _indicatorWidget = indicatorWidget;
    _logoImage = logoImage;
  }

  late BuildContext _context;
  late GlobalKey<ScaffoldMessengerState> _smKey;
  Widget? _indicatorWidget;
  ImageProvider? _logoImage;

  static GlueUI instance = GlueUI._();

  late IndicatorService indicator = IndicatorService(
    context: _context,
    smKey: _smKey,
    indicatorWidget: _indicatorWidget,
    logoImage: _logoImage,
  );

  late DialogService dialog = DialogService(smKey: _smKey, context: _context);
}
