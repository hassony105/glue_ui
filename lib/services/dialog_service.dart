import 'package:flutter/foundation.dart';
import 'package:glue_ui/extensions/extensions.dart';
import 'package:glue_ui/services/services.dart';
import 'package:glue_ui/widgets/widgets.dart';
import 'package:sm_dialog/sm_dialog.dart';
import 'package:flutter/material.dart';

class DialogService {
  DialogService({
    required GlobalKey<ScaffoldMessengerState> smKey,
    required BuildContext context,
  }) : _smKey = smKey,
       _context = context;

  final BuildContext _context;
  final GlobalKey<ScaffoldMessengerState> _smKey;

  final List<_DialogEntry> _dialogsStack = [];

  bool get isActive => _dialogsStack.isNotEmpty;

  Future<UniqueKey> show({
    String title = 'Error',
    String? desc,
    DialogType type = DialogType.error,
  }) async {
    try {
      FocusScope.of(_context).unfocus();
      UniqueKey key = UniqueKey();
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller =
          _smKey.currentState?.showSnackBar(
            GlueSnackBarWidget(
              key: key,
              dismissOnBack: true,
              dismissOnTapOutside: true,
              margin: EdgeInsets.zero,
              hideCallback: () => hide(key),
              backgroundColor: Colors.black,
              elevation: 5,
              content: SizedBox(
                height: _context.screenSize.height,
                width: _context.screenSize.width,
                child: AnimatedDialogWidget(
                  dialog: SMDialog(
                    context: _context,
                    dialogType: type,
                    // alignment: Alignment.bottomCenter,
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
            ),
          );
      _dialogsStack.add(_DialogEntry(controller, key));
      SnackBarClosedReason? reason = await controller?.closed;
      if (kDebugMode) print(reason);
      return key;
    } catch (e, s) {
      throw CustomException(
        message: 'حصل خطأ في احدى الميزات, رمز الخطأ [SMK maybe null]',
        hiddenMessage: '{\ne: $e\ns:$s\n}',
      );
    }
  }

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
                                'حصل خطأ في احدى الميزات, رمز الخطأ [SKM-404]',
                          ),
                )
                : _dialogsStack.last;
        _dialogsStack.remove(entry);
        entry.controller?.close();
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

  void hideAll() {
    try {
      for (_DialogEntry element in _dialogsStack) {
        element.controller?.close();
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

class _DialogEntry {
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
  final UniqueKey key;

  _DialogEntry(this.controller, this.key);
}
