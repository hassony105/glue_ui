import 'package:flutter/material.dart';
import 'package:glue_ui/extensions/extensions.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/widgets/widgets.dart';

/// A service class to display and manage a custom indicator using a [SnackBar].
///
/// This service allows showing a persistent indicator, such as a loading spinner
/// or an animation with a logo, typically used to indicate ongoing processes
/// like network requests. It leverages a [GlobalKey<ScaffoldMessengerState>]
/// to display the indicator as a [SnackBar] at the bottom of the screen.
///
/// An indicator widget or a logo image must be provided during initialization.
/// If both are provided, the custom [indicatorWidget] takes precedence.
class IndicatorService {
  /// Creates an [IndicatorService].
  ///
  /// Requires a [BuildContext] and a [GlobalKey<ScaffoldMessengerState>]
  /// to manage the SnackBar display.
  ///
  /// You can optionally provide a custom [indicatorWidget] to be displayed.
  /// If no [indicatorWidget] is provided, an [AnimatedIndicatorWidget] will
  /// be created using the provided [logoImage].
  ///
  /// Throws an assertion error if neither [indicatorWidget] nor [logoImage]
  /// is provided.
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

  /// Checks if the indicator is currently active (visible).
  bool get isActive => _indicatorController != null;

  final BuildContext _context;
  final GlobalKey<ScaffoldMessengerState> _smKey;
  final Widget? _indicatorWidget;
  final ImageProvider? _logoImage;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _indicatorController;

  /// Displays the indicator.
  ///
  /// If an indicator is already active, it will be hidden before showing the new one.
  /// It also unFocuses any active input fields.
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

  /// Hides the currently active indicator.
  ///
  /// It attempts to close the SnackBar gracefully. In case of an error
  /// during closing, it clears all current SnackBars from the
  /// [ScaffoldMessengerState].
  void hide() {
    try {
      _indicatorController?.close();
      _indicatorController = null;
    } catch (e, s) {
      _indicatorController = null;
      _smKey.currentState?.hideCurrentSnackBar();
      print('e: $e\ns: $s');
    }
  }
}
