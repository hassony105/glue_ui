import 'package:flutter/scheduler.dart';
import 'package:glue_ui/extensions/extensions.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/widgets/widgets.dart';
import 'package:sm_dialog/sm_dialog.dart';
import 'package:flutter/material.dart';

/// A service class to display and manage a stack of custom dialogs using [SnackBar].
///
/// This service leverages a [GlobalKey<ScaffoldMessengerState>] to display
/// dialogs as [SnackBar] widgets, effectively creating a layered dialog
/// experience. It maintains a stack of active dialogs and provides methods
/// to show, hide, and manage them.
class DialogService {
  /// Creates a [DialogService].
  ///
  /// Requires a [GlobalKey<ScaffoldMessengerState>] and a [BuildContext]
  /// to manage the display of dialogs as SnackBars.
  DialogService({
    required BuildContext context,
    required GlobalKey<NavigatorState> nsKey,
  }) : _context = context, _nsKey = nsKey;

  final BuildContext _context;
  final GlobalKey<NavigatorState> _nsKey;
  late OverlayState _overlayState;
  final List<_DialogEntry> _dialogsStack = [];

  /// Checks if there are any active dialogs in the stack.
  bool get isActive => _dialogsStack.isNotEmpty;
  void initialize(){
    final overlay = Overlay.maybeOf(_context, rootOverlay: true);
    if (overlay == null) {
      throw FlutterError('Could not find OverlayState from navigator context.');
    }

    _overlayState = overlay;
  }
  /// Displays a custom dialog.
  ///
  /// The dialog is shown as a [SnackBar] at the bottom of the screen.
  ///
  /// Optionally takes a [title], [desc] (description), and [type] of dialog.
  /// The [type] influences the appearance of the dialog.
  ///
  /// Returns a [Future] that resolves with a [UniqueKey] identifying the displayed dialog.
  /// This key can be used to hide the specific dialog later.
  ///
  /// If an error occurs during the process (e.g., [ScaffoldMessengerState] is null),
  /// a [CustomException] is thrown.
  Future<UniqueKey> show({
    String title = 'Error',
    String? desc,
    DialogType type = DialogType.error,
  }) async {
    try {
      FocusScope.of(_nsKey.currentContext!).unfocus();
      UniqueKey key = UniqueKey();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Overlay.maybeOf(_context) != null) {
          OverlayEntry overlayEntry = OverlayEntry(
            builder: (_) {
              return GestureDetector(
                onTap: () => hide(key),
                child: Container(
                  height: _context.screenSize.height,
                  width: _context.screenSize.width,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .5),
                  ),
                  child: AnimatedDialogWidget(
                    dialog: SMDialog(
                      context: _context,
                      dialogType: type,
                      alignment: Alignment.center,
                      animType: AnimType.bottomSlide,
                      width: double.infinity,
                      transitionAnimationDuration: Duration(milliseconds: 200),
                      buttonsBorderRadius: BorderRadius.circular(10),
                      dismissOnTouchOutside: false,
                      dismissOnBackKeyPress: false,
                      headerAnimationLoop: false,
                      title: title,
                      desc: desc,
                      showCloseIcon: true,
                      onClose: () => hide(key),
                    ),
                  ),
                ),
              );
            },
          );
          _overlayState.insert(overlayEntry);
      _dialogsStack.add(_DialogEntry(overlayEntry, key));
        }
      });
      return key;
    } catch (e, s) {
      throw CustomException(
        message: 'حصل خطأ في احدى الميزات, رمز الخطأ [SMK maybe null]',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }

  /// Hides a specific dialog or the most recently shown dialog.
  ///
  /// If a [key] is provided, the dialog with that specific key is hidden.
  /// If no [key] is provided, the dialog at the top of the stack (the most recent)
  /// is hidden.
  ///
  /// Throws a [CustomException] if the provided key is not found in the stack
  /// or if there's an error during the hiding process.
  void hide([UniqueKey? key]) {
    try {
      if (isActive) {
        _DialogEntry entry =
            key != null
                ? _dialogsStack.firstWhere(
                  (element) => element.key == key,
                  orElse:
                      () =>
                          throw CustomException(
                            message:
                                'حصل خطأ في احدى الميزات, رمز الخطأ [SKM-404]'
                          ),
                )
                : _dialogsStack.last;
        _dialogsStack.remove(entry);
        entry.overlayEntry?.remove();
        entry.overlayEntry?.dispose();
      }
    } on CustomException {
      rethrow;
    } catch (e, s) {
      throw CustomException(
        message: 'حصل خطأ في احدى الميزات, رمز الخطأ [SMK-null]',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }

  /// Hides all active dialogs in the stack.
  ///
  /// Clears the dialogs stack and closes all associated SnackBars.
  ///
  /// Throws a [CustomException] if an error occurs during the process.
  void hideAll() {
    try {
      for (_DialogEntry element in _dialogsStack) {
        element.overlayEntry?.remove();
        element.overlayEntry?.dispose();
      }
      _dialogsStack.clear();
    } on CustomException {
      rethrow;
    } catch (e, s) {
      throw CustomException(
        message: 'حصل خطأ في احدى الميزات, رمز الخطأ [SMK-null]',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }
}

/// A private helper class to store information about an active dialog.
///
/// Contains the [ScaffoldFeatureController] for the SnackBar and a [UniqueKey]
/// to identify the dialog in the stack.
class _DialogEntry {
  final OverlayEntry? overlayEntry;
  final UniqueKey key;

  _DialogEntry(this.overlayEntry, this.key);
}
