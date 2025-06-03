import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glue_ui/extensions/extensions.dart';
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
    Widget? indicatorWidget,
    ImageProvider? logoImage,
  }) : _context = context,
       _indicatorWidget = indicatorWidget,
       _logoImage = logoImage,
       assert(
         indicatorWidget != null || logoImage != null,
         'indicatorWidget or logoImage should be provided',
       );

  /// Checks if the indicator is currently active (visible).
  bool get isActive => _overlayEntry != null;

  final BuildContext _context;
  final Widget? _indicatorWidget;
  final ImageProvider? _logoImage;
  OverlayEntry? _overlayEntry;
  late OverlayState _overlayState;

  void initialize() {
    final overlay = Overlay.maybeOf(_context, rootOverlay: true);
    if (overlay == null) {
      throw FlutterError('Could not find OverlayState from navigator context.');
    }
    _overlayState = overlay;
  }

  /// Displays the indicator.
  ///
  /// If an indicator is already active, it will be hidden before showing the new one.
  /// It also unFocuses any active input fields.
  void show() {
    FocusScope.of(_context).unfocus();
    hide();
    double indicatorSize = _context.screenSize.shortestSide * .25;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Overlay.maybeOf(_context) != null) {
        _overlayEntry = OverlayEntry(
          builder: (_) {
            return Container(
                height: _context.screenSize.height,
                width: _context.screenSize.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .5),
                ),
              child: _indicatorWidget ?? AnimatedIndicatorWidget(size: indicatorSize, image: _logoImage),
            );
          },
        );
        _overlayState.insert(_overlayEntry!);
      }
    });
  }

  /// Hides the currently active indicator.
  ///
  /// It attempts to close the SnackBar gracefully. In case of an error
  /// during closing, it clears all current SnackBars from the
  /// [ScaffoldMessengerState].
  void hide() {
    try {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
    } catch (e, s) {
      if (kDebugMode) {
        print('e:$e\ns:$s');
      }
    }
  }
}
