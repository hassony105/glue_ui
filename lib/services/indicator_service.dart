import 'package:flutter/material.dart';
import 'package:glue_ui/extensions/extensions.dart';
import 'package:glue_ui/widgets/widgets.dart';

class IndicatorService {
  IndicatorService({
    required BuildContext context,
    required GlobalKey<ScaffoldMessengerState> smKey,
    Widget? indicatorWidget,
    ImageProvider? logoImage,
  }) : _context = context,
       _smKey = smKey,
       _indicatorWidget = indicatorWidget,
       _logoImage = logoImage,
       assert(
         indicatorWidget != null || logoImage != null,
         'indicatorWidget or logoImage should be provided',
       );

  bool get isActive => _indicatorController != null;

  final BuildContext _context;
  final GlobalKey<ScaffoldMessengerState> _smKey;
  final Widget? _indicatorWidget;
  final ImageProvider? _logoImage;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _indicatorController;

  void show() {
    FocusScope.of(_context).unfocus();
    hide();
    double indicatorSize = _context.screenSize.shortestSide * .25;
    _indicatorController = _smKey.currentState?.showSnackBar(
      GlueSnackBarWidget(
        key: ValueKey('indicator-service'),
        hideCallback: hide,
        dismissOnBack: true,
        dismissOnTapOutside: false,
        content: Center(
          child:
              _indicatorWidget ??
              AnimatedIndicatorWidget(size: indicatorSize, image: _logoImage),
        ),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.black,
        elevation: 2.5,
        margin: EdgeInsets.zero,
      ),
    );
  }

  void hide() async {
    try {
      _indicatorController?.close();
      _indicatorController = null;
    } catch (e) {
      _smKey.currentState?.clearSnackBars();
    }
  }
}
