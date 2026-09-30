import 'package:flutter/scheduler.dart';
import 'package:glue_ui/extensions/extensions.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/widgets/widgets.dart';
import 'package:sm_dialog/sm_dialog.dart';
import 'package:flutter/material.dart';

import '../glue_ui.dart';

/// A service class to display and manage a stack of custom dialogs using [OverlayEntry].
///
/// This service leverages the navigator overlay to display
/// dialogs. It maintains a stack of active dialogs and provides methods
/// to show, hide, and manage them.
class DialogService {
  DialogService();

  final List<_DialogEntry> _dialogsStack = [];

  /// Checks if there are any active dialogs in the stack.
  bool get isActive => _dialogsStack.isNotEmpty;

  /// Displays a custom dialog.
  ///
  /// The dialog is shown as an [OverlayEntry] at the center of the screen.
  ///
  /// Optionally takes a [title], [desc] (description), and [type] of dialog.
  /// The [type] influences the appearance of the dialog.
  ///
  /// Returns a [Future] that resolves with a [UniqueKey] identifying the displayed dialog.
  /// This key can be used to hide the specific dialog later.
  Future<UniqueKey> show({
    required BuildContext context,
    String title = 'Error',
    String? desc,
    DialogType type = DialogType.error,
  }) async {
    try {
      FocusScope.of(context).unfocus();
      UniqueKey key = UniqueKey();
      
      final overlayState = GlueUI.instance.navigatorKey.currentState?.overlay ?? Overlay.maybeOf(context);
      
      if (overlayState == null) {
        throw CustomException(message: 'Could not find OverlayState to show dialog.');
      }
      
      SchedulerBinding.instance.addPostFrameCallback((_) {
        OverlayEntry overlayEntry = OverlayEntry(
          builder: (_) {
            return GestureDetector(
              onTap: () => hide(key),
              child: Container(
                height: context.screenSize.height,
                width: context.screenSize.width,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .5),
                ),
                child: AnimatedDialogWidget(
                  dialog: SMDialog(
                    context: context,
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
        overlayState.insert(overlayEntry);
        _dialogsStack.add(_DialogEntry(overlayEntry, key));
      });
      return key;
    } catch (e, s) {
      throw CustomException(
        message: 'An error occurred while showing the dialog.',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }

  /// Hides a specific dialog or the most recently shown dialog.
  void hide([UniqueKey? key]) {
    try {
      if (isActive) {
        _DialogEntry entry =
            key != null
                ? _dialogsStack.firstWhere(
                  (element) => element.key == key,
                  orElse: () => throw CustomException(
                    message: 'Dialog key not found.',
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
        message: 'An error occurred while hiding the dialog.',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }

  /// Hides all active dialogs in the stack.
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
        message: 'An error occurred while hiding all dialogs.',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }
}

/// A private helper class to store information about an active dialog.
class _DialogEntry {
  final OverlayEntry? overlayEntry;
  final UniqueKey key;

  _DialogEntry(this.overlayEntry, this.key);
}
