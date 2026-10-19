## 0.2.0

* add global snack bar service `GlueUI.instance.snackBar` (overlay-based, no `BuildContext` or `Scaffold` needed)
  * FIFO queue (one snack bar at a time), `replace` option, `hide(key)` / `hideAll()`
  * `SnackBarType` (normal, success, error, warning, info) and `SnackBarPosition` (top, bottom)
  * action button, close icon, swipe to dismiss, tap callback
  * `GlueSnackBarController` with `closed` future returning a `SnackBarClosedReason`
  * custom look via `GlueUIConfig.snackBarBuilder` or per-call `builder`
* add `snackBarDuration`, `snackBarPosition` and `snackBarBuilder` to `GlueUIConfig`
* stop exporting the unused `GlueScaffold` and `GlueSnackBarWidget` from `glue_ui.dart`

## 0.1.0

* fix indicator not showing first time problem.
* some improvement and make the dialog service works now
* update the version

## 0.0.1

* initial release.

## 0.0.2

* add isInitialized property
* add errorMessage property

## 0.0.3

* change isInitialized to getter and private setter
* change errorMessage to stored privately
* handling access to `indicator` and `dialog` if it isn't initialized