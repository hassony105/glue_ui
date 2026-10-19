<div align="center">
<p>
<img src="https://github.com/hassony105/glue_ui/blob/master/example/assets/glue-ui-logo.png?raw=true" alt="Glue UI Flutter Header"/>
</p>
  <h1>Glue UI</h1>
  <div>
    <a title="pub.dev" href="https://pub.dartlang.org/packages/glue_ui" >
        <img alt="Pub Version" src="https://img.shields.io/pub/v/glue_ui">
    </a>
    <a title="GitHub License" href="https://github.com/hassony105/glue_ui/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/hassony105/glue_ui?color=f12253"  alt="LICENCE"/>
    </a>
    <a title="GitHub hassony105" href="https://github.com/hassony105">
      <img alt="Static Badge" src="https://img.shields.io/badge/hassony105-github-blue?link=https%3A%2F%2Fgithub.com%2Fhassony105%glue_ui">
    </a>
  </div>
  <div>
  </div>
  <br/>
  <p>Glue UI is a package that can trigger an indicator, a dialog and a snack bar to show them separately from context of the app. It dynamically overlays widgets on top of the Navigator — no <code>BuildContext</code> or <code>Scaffold</code> required.</p>
</div>

---

### Content

- [Installation](#installation)
- [Get Started](#get-started)
- [Methods And Properties](#methods-and-properties)
- [How To Use](#how-to-use)
- [Platforms](#platforms)
- [Contribution](#contribution)

## Installation

Add the package to your dependencies:

```yaml
dependencies:
  glue_ui: ^0.2.0
```

<p>OR</p>

```yaml
dependencies:
  glue_ui:
    git: https://github.com/hassony105/glue_ui.git
    ref: v0.2.0
```

Finally, run `dart pub get` to download the package.

Projects using this library can use any channel of Flutter.

## Get Started

You must initialize GlueUI by calling `initialize` (typically in your `main()` method) and configuring it with `GlueUIConfig`:

```dart
void main() {
  GlueUI.instance.initialize(
    config: GlueUIConfig(
      defaultIndicator: CircularProgressIndicator(),
      overlayColor: Colors.black.withValues(alpha: 0.5),
      // Optional snack bar defaults
      snackBarDuration: Duration(seconds: 4),
      snackBarPosition: SnackBarPosition.bottom,
    ),
  );
  
  runApp(const MyApp());
}
```

| `GlueUIConfig` field | Type                   | Default        | Description                                                         |
|:---------------------|:-----------------------|:---------------|:--------------------------------------------------------------------|
| `defaultIndicator`   | `Widget?`              | adaptive spinner | Widget shown by `loader.show()`.                                  |
| `overlayColor`       | `Color?`               | black 50%      | Barrier color behind the indicator.                                 |
| `snackBarDuration`   | `Duration`             | 4 seconds      | Default time a snack bar stays visible.                             |
| `snackBarPosition`   | `SnackBarPosition`     | `bottom`       | Default snack bar position (`top` / `bottom`).                      |
| `snackBarBuilder`    | `GlueSnackBarBuilder?` | `null`         | Replaces the default snack bar look for the whole app.              |

Next, wrap your `MaterialApp` with `GlueAppDelegate` and assign the `navigatorKey`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlueAppDelegate(
      child: MaterialApp(
        title: 'Flutter Glue UI Demo',
        theme: ThemeData.dark(useMaterial3: true),
        home: const MyHomePage(title: 'Glue UI'),
        navigatorKey: GlueUI.instance.navigatorKey, // Required!
      ),
    );
  }
}
```

## Methods And Properties

| Properties                           | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                        |
|:-------------------------------------|:-------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `initialize()`                       | `void`              | **Required**. Initializes the `GlueUI` singleton with an optional `GlueUIConfig`. This method ***must*** be called before accessing the `loader` or `dialog` services.                                                                                                                                                                                                                             |
| `GlueUI.instance`                    | `GlueUI`            | The singleton instance of `GlueUI`.                                                                                                                                                                                                                                                                                                                                                                |
| `GlueUI.instance.loader`             | `IndicatorService`  | Provides access to the `IndicatorService` for displaying loading indicators.                                                                                                                                                                                                                                                                                                                       |
| `GlueUI.instance.dialog`             | `DialogService`     | Provides access to the `DialogService` for displaying custom dialogs.                                                                                                                                                                                                                                                                                                                              |
| `GlueUI.instance.loader.show()`      | `void`              | Displays the indicator overlay.                                                                                                                                                                                                                                                                                                                                                                    |
| `GlueUI.instance.loader.hide()`      | `void`              | Hides the currently active indicator overlay.                                                                                                                                                                                                                                                                                                                                                      |
| `GlueUI.instance.loader.visible`     | `bool`              | Checks if the indicator is currently active (visible).                                                                                                                                                                                                                                                                                                                                             |
| `GlueUI.instance.dialog.show()`      | `Future<UniqueKey>` | Displays a custom dialog. The dialog is shown as an `OverlayEntry` at the center of the screen. Optionally takes a `title`, `desc` (description), and `type` of dialog. The `type` influences the appearance of the dialog. Returns a `Future` that resolves with a `UniqueKey` identifying the displayed dialog. This key can be used to hide the specific dialog later.                        |
| `GlueUI.instance.dialog.hide()`      | `void`              | Hides a specific dialog or the most recently shown dialog. If a `key` is provided, the dialog with that specific key is hidden. If no `key` is provided, the dialog at the top of the stack (the most recent) is hidden.                                                                                                                                                                           |
| `GlueUI.instance.dialog.hideAll()`   | `void`              | Hides all active dialogs in the stack.                                                                                                                                                                                                                                                                                                                                                             |
| `GlueUI.instance.dialog.isActive`    | `bool`              | Checks if there are any active dialogs in the stack.                                                                                                                                                                                                                                                                                                                                               |
| `GlueUI.instance.snackBar`           | `SnackBarService`   | Provides access to the `SnackBarService` for displaying snack bars.                                                                                                                                                                                                                                                                                                                                |
| `GlueUI.instance.snackBar.show()`    | `GlueSnackBarController` | Shows a snack bar, or queues it if one is already visible (one at a time, FIFO — like `ScaffoldMessenger`). Takes a required `message` and optional `title`, `type`, `duration`, `position`, `actionLabel`/`onAction`, `showCloseIcon`, `dismissible`, `onTap`, `builder` and `replace`. No `context` and no `Scaffold` needed.                                                           |
| `GlueUI.instance.snackBar.hide()`    | `void`              | Hides the visible snack bar. If a `key` is provided, hides that snack bar or removes it from the queue if it hasn't been shown yet.                                                                                                                                                                                                                                                                |
| `GlueUI.instance.snackBar.hideAll()` | `void`              | Clears the queue and hides the visible snack bar.                                                                                                                                                                                                                                                                                                                                                  |
| `GlueUI.instance.snackBar.isActive`  | `bool`              | Checks if a snack bar is currently visible.                                                                                                                                                                                                                                                                                                                                                        |
| `GlueUI.instance.snackBar.queueLength` | `int`             | Number of snack bars waiting in the queue.                                                                                                                                                                                                                                                                                                                                                         |
| `GlueSnackBarController.closed`      | `Future<SnackBarClosedReason>` | Completes when the snack bar is gone, with the reason: `timeout`, `action`, `dismiss`, `swipe`, `hide` or `remove`.                                                                                                                                                                                                                                                                     |
| `GlueSnackBarController.close()`     | `void`              | Hides this snack bar (or removes it from the queue).                                                                                                                                                                                                                                                                                                                                               |

---

## How To Use

It is very simple to use, just like these examples:

### Loader (Indicator)

```dart
ElevatedButton(  
  onPressed: () async {  
    try {  
      GlueUI.instance.loader.show();  
      
      // Execute any asynchronous method  
      await Future.delayed(Duration(seconds: 2));  
      
    } catch (e) {  
      if (kDebugMode) {  
        print(e);  
      }  
    } finally {  
      GlueUI.instance.loader.hide();  
    }  
  },  
  child: Text('Show Indicator'),  
);
```

### Dialog

```dart
ElevatedButton(  
  onPressed: () async {  
    try {  
      final dialogKey = await GlueUI.instance.dialog.show(  
        context: context, // required for overlay context resolution
        title: 'Dialog Title',  
        desc: 'Dialog Description',  
        type: DialogType.success,  
      );  
      
      // Close dialog programmatically after 2 seconds
      await Future.delayed(Duration(seconds: 2));  
      GlueUI.instance.dialog.hide(dialogKey);
      
    } catch (e) {  
      if (kDebugMode) {  
        print(e);  
      }  
    }  
  },  
  child: Text('Show dialog for specific duration'),  
)
```

### Snack Bar

Snack bars can be shown from anywhere — a button, a repository, a BLoC — without a `BuildContext` and without a `Scaffold`:

```dart
// Simple
GlueUI.instance.snackBar.show(
  title: 'Saved',
  message: 'Your changes were saved successfully.',
  type: SnackBarType.success, // normal, success, error, warning, info
);

// With an action, and waiting for the result
final controller = GlueUI.instance.snackBar.show(
  message: 'Item deleted.',
  type: SnackBarType.error,
  actionLabel: 'UNDO',
  onAction: () => restoreItem(),
  showCloseIcon: true,
);
final reason = await controller.closed; // e.g. SnackBarClosedReason.action

// At the top, replacing anything currently visible or queued
GlueUI.instance.snackBar.show(
  message: 'You are offline.',
  type: SnackBarType.warning,
  position: SnackBarPosition.top,
  replace: true,
);

// Close from code
controller.close();                 // or GlueUI.instance.snackBar.hide(controller.key)
GlueUI.instance.snackBar.hideAll(); // clear queue + hide visible one
```

Snack bars are shown **one at a time**; extra calls are queued and shown in order. They can be swiped away horizontally (`dismissible: true` by default), respect the safe area and move above the keyboard.

#### Custom snack bar look

Use `snackBarBuilder` in `GlueUIConfig` (app-wide) or `builder` in `show()` (single call). GlueUI still handles position, animation, swipe and the timer:

```dart
GlueUIConfig(
  snackBarBuilder: (context, data) => Card(
    child: ListTile(
      title: Text(data.title ?? ''),
      subtitle: Text(data.message),
      trailing: data.actionLabel == null
          ? null
          : TextButton(onPressed: data.onActionPressed, child: Text(data.actionLabel!)),
      onLongPress: data.dismiss,
    ),
  ),
);
```

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅      |
| IOS      | ✅      |
| Windows  | ✅      |
| MacOS    | ✅      |
| Linux    | ✅      |
| Web      | ✅      |

## Contribution

Feel free to [file an issue](https://github.com/hassony105/glue_ui/issues/new) if you find a problem
or [make pull requests](https://github.com/hassony105/glue_ui/pulls).

All contributions are welcome **:)**