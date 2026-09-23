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
  <p>Glue UI is a package that can trigger an indicator and dialog to show them separately from context of the app. It dynamically overlays widgets on top of the Navigator.</p>
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
  glue_ui: ^0.1.0
```

<p>OR</p>

```yaml
dependencies:
  glue_ui:
    git: https://github.com/hassony105/glue_ui.git
    ref: v0.1.0
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
      overlayColor: Colors.black.withOpacity(0.5),
    ),
  );
  
  runApp(const MyApp());
}
```

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
)
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