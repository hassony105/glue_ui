import 'package:flutter/material.dart';
import 'package:glue_ui/services/services.dart';

// Export the DialogType enum from the sm_dialog package for convenience.
export 'package:sm_dialog/sm_dialog.dart' show DialogType;
export 'package:glue_ui/widgets/glue_scaffold.dart';

/// A singleton class to initialize and access the services provided by the GlueUI library.
///
/// This class provides a centralized point of access to the [IndicatorService]
/// and [DialogService], which are essential for displaying indicators and
/// dialogs within the application. It requires initialization with a
/// [BuildContext] and a [GlobalKey<ScaffoldMessengerState>] to function correctly.
class GlueUI {
  /// Private constructor to prevent external instantiation.
  GlueUI._();

  /// Initializes the [GlueUI] singleton with the necessary context and keys.
  ///
  /// This method must be called before accessing the [indicator] or [dialog]
  /// services.
  ///
  /// - [context]: The [BuildContext] from which the services will operate.
  /// - [smKey]: The [GlobalKey<ScaffoldMessengerState>] used by the services
  ///   to display SnackBars (for indicators and dialogs).
  /// - [indicatorWidget]: An optional custom widget to be used as the indicator.
  ///   If not provided, a default indicator will be used.
  /// - [logoImage]: An optional image to display within the indicator.
  void initialize({required BuildContext context, Widget? indicatorWidget, ImageProvider? logoImage, String? errorMessage = 'An error occurred during initializing some feature.'}) {
    if (isInitialized) return;
    try {
      _indicatorWidget = indicatorWidget;
      _logoImage = logoImage;
      _indicator.initialize(context: context);
      _dialog.initialize(context: context);
      _isInitialized = true;
    } catch (e, s) {
      throw CustomException(message: errorMessage, hiddenMessage: '$e\n$s');
    }
  }

  Widget? _indicatorWidget;
  ImageProvider? _logoImage;
  bool _isInitialized = false;

  /// A flag indicating whether the [GlueUI] instance has been successfully
  /// initialized by calling the [initialize] method.
  ///
  /// Accessing services like [indicator] or [dialog] before `isInitialized`
  /// is `true` will likely result in runtime errors because the necessary
  /// context and keys will not have been set.
  bool get isInitialized => _isInitialized;

  /// The singleton instance of [GlueUI].
  static GlueUI instance = GlueUI._();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  BuildContext get _context => navigatorKey.currentContext!;


  /// Provides access to the [IndicatorService] for displaying loading indicators.
  ///
  /// This service is initialized upon first access after [initialize] has been called.
  late final IndicatorService _indicator = IndicatorService(indicatorWidget: _indicatorWidget, logoImage: _logoImage);

  IndicatorService get indicator => _indicator;

  /// Provides access to the [DialogService] for displaying custom dialogs.
  ///
  /// This service is initialized upon first access after [initialize] has been called.
  final DialogService _dialog = DialogService();

  DialogService get dialog => _dialog;
}
