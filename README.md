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
  <p>Glue UI is a package that can trigger an indicator and dialog to show theme separately from context of the app. it depends on `ScaffoldMessengerKey` to do the purpose</p>


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
  glue_ui: ^0.0.1
```

<p>OR</p>

```yaml
dependencies:
  glue_ui:
    git: https://github.com/hassony105/glue_ui.git
    ref: v0.0.1
```

Finally, run `dart pub get` to download the package.

Projects using this library can use any channel of Flutter

## Get Started

You must to initialize GlueUI by calling :

``` dart
GlueUI.instance.initialize(
  context: navigatorKey.currentContext!,
  smKey: scaffoldMessengerStateKey,
  logoImage: AssetImage('assets/glue-ui-logo.png'),
);
```

because it takes a `GlobalKey<NavigatorState>` and `GlobalKey<ScaffoldMessengerState>` which they
assigned to `MaterialApp`:

 ``` dart
 MaterialApp(  
  title: 'Flutter Glue UI Demo',  
  theme: ThemeData.dark(useMaterial3: true),  
  home: const MyHomePage(title: 'Glue UI'),  
  navigatorKey: navigatorKey,  
  scaffoldMessengerKey: scaffoldMessengerStateKey,  
);
 ```

## Methods And Properties

| Properties                           | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|:-------------------------------------|:--------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `initializing()`                     | `Future<void>`      | **Required**. Initializes the `GlueUI` singleton with the necessary context and keys. This method ***must*** be called before accessing the `indicator` or `dialog` services.                                                                                                                                                                                                                                                                                                       |
| `GlueUI.instance`                    | `GlueUI`            | The singleton instance of `GlueUI`.                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `GlueUI.instance.indicator`          | `IndicatorService`  | Provides access to the `IndicatorService` for displaying loading indicators. This service is initialized upon first access after `initialize` has been called.                                                                                                                                                                                                                                                                                                                      |
| `GlueUI.instance.dialog`             | `DialogService`     | Provides access to the `DialogService` for displaying custom dialogs. This service is initialized upon first access after `initialize` has been called.                                                                                                                                                                                                                                                                                                                             |
| `GlueUI.instance.indicator.show()`   | `void`              | Displays the indicator. If an indicator is already active, it will be hidden before showing the new one. It also unFocuses any active input fields.                                                                                                                                                                                                                                                                                                                                 |
| `GlueUI.instance.indicator.hide()`   | `void`              | Hides the currently active indicator. It attempts to close the SnackBar gracefully. In case of an error during closing, it clears all current SnackBars from the  `ScaffoldMessengerState`.                                                                                                                                                                                                                                                                                         |
| `GlueUI.instance.indicator.isActive` | `bool`              | Checks if the indicator is currently active (visible).                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `GlueUI.instance.dialog.show()`      | `Future<UniqueKey>` | displays a custom dialog. The dialog is shown as a `SnackBar` at the bottom of the screen. Optionally takes a `title`, `desc` (description), and `type` of dialog. The `type` influences the appearance of the dialog. Returns a `Future` that resolves with a `UniqueKey` identifying the displayed dialog. This key can be used to hide the specific dialog later. If an error occurs during the process (e.g., `ScaffoldMessengerState` is null), a `CustomException` is thrown. |
| `GlueUI.instance.dialog.hide()`      | `void`              | Hides a specific dialog or the most recently shown dialog. If a `key` is provided, the dialog with that specific key is hidden. If no `key` is provided, the dialog at the top of the stack (the most recent) is hidden. Throws a `CustomException` if the provided key is not found in the stack or if there's an error during the hiding process.                                                                                                                                 |
| `GlueUI.instance.dialog.hideAll()`   | `void`              | Hides all active dialogs in the stack. Clears the dialogs stack and closes all associated SnackBars. Throws a `CustomException` if an error occurs during the process.                                                                                                                                                                                                                                                                                                              |
| `GlueUI.instance.indicator.isActive` | `bool`              | Checks if there are any active dialogs in the stack.                                                                                                                                                                                                                                                                                                                                                                                                                                |

---

## How To Use

It is very simple to use, just like these examples:

- Indicator

``` dart
ElevatedButton(  
  onPressed: () async {  
    try {  
      GlueUI.instance.indicator.show();  
      //any method  
	  await Future.delayed(Duration(seconds: 2));  
    } catch (e) {  
      if (kDebugMode) {  
        print(e);  
      }  
    } finally {  
      GlueUI.instance.indicator.hide();  
    }  
  },  
  child: Text('show indicator'),  
)
```

- Dialog

``` dart
ElevatedButton(  
  onPressed: () async {  
    try {  
      GlueUI.instance.dialog.show(  
        title: 'Dialog Title',  
        desc: 'Dialog Description',  
        type: DialogType.success,  
      );  
      //any method  
	  await Future.delayed(Duration(seconds: 2));  
    } catch (e) {  
      if (kDebugMode) {  
        print(e);  
      }  
    } finally {  
      GlueUI.instance.dialog.hide();  
    }  
  },  
  child: Text('show dialog for specific duration'),  
)

```

``` dart
ElevatedButton(  
  onPressed: () async {  
    try {  
      GlueUI.instance.dialog.show(  
        title: 'Dialog Title',  
        desc: 'Dialog Description',  
        type: DialogType.success,  
      );  
      //any method  
	  await Future.delayed(Duration(seconds: 2));  
    } catch (e) {  
      if (kDebugMode) {  
        print(e);  
      }  
    }  
  },  
  child: Text('show dialog for until user dismiss it'),  
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