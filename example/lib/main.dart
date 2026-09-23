import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glue_ui/glue_ui.dart';
import 'package:glue_ui/services/indicator_service.dart';

void main() {
  runApp(
    GlueAppDelegate(
      indicatorWidget: SizedBox(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(color: Colors.red),
      ),
      child: MaterialApp(
        title: 'Flutter Glue UI Demo',
        theme: ThemeData.dark(useMaterial3: true),
        home: const MyHomePage(title: 'Glue UI'),
        navigatorKey: GlueUI.instance.navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerStateKey,
      ),
    ),
  );
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<ScaffoldMessengerState> scaffoldMessengerStateKey = GlobalKey<ScaffoldMessengerState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

extension _IndicatorControllerWidgetExtension on BuildContext {
}

class _MyHomePageState extends State<MyHomePage> {
  void showIndicator2() async {
    try {
      print('indicator 2 starting');
      GlueUI.instance.loader?.show();
      print('indicator 2 started');
      //any method
      await Future.delayed(Duration(seconds: 2));
      print('indicator 2 ending');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      GlueUI.instance.loader?.hide();
    }
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   try {
    //     GlueUI.instance.initialize(
    //       context: context,
    //       logoImage: AssetImage('assets/glue-ui-logo.png'),
    //       errorMessage: 'Failed to initialize GlueUI.',
    //     );
    //   } catch (e){
    //     if (kDebugMode) {
    //       print(e);
    //     }
    //   }
    //   },
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  var loader = IndicatorService(IndicatorControllerWidget.of(context));
                  print(loader);
                  loader.show();
                  //any method
                  print('before indicator 2');
                  showIndicator2();
                  print('after indicator 2');
                  await Future.delayed(Duration(seconds: 2));
                  print('complete and hiding indicator 1');
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                } finally {
                  GlueUI.instance.loader?.hide();
                }
              },
              child: Text('show indicator'),
            ),
            ElevatedButton(onPressed: showIndicator2, child: Text('show indicator 2')),
            ElevatedButton(
              onPressed: () async {
                try {
                  // GlueUI.instance.dialog.show(
                  //   context: context,
                  //   title: 'Dialog Title',
                  //   desc: 'Dialog Description',
                  //   type: DialogType.success,
                  // );
                  //any method
                  print('before indicator 2');
                  showIndicator2();
                  print('after indicator 2');
                  await Future.delayed(Duration(seconds: 2));
                  print('complete and hiding indicator 1');
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                } finally {
                  // GlueUI.instance.dialog.hide();
                }
              },
              child: Text('show dialog for specific duration'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // GlueUI.instance.dialog.show(
                  //   context: context,
                  //   title: 'Dialog Title',
                  //   desc: 'Dialog Description',
                  //   type: DialogType.success,
                  // );
                  //any method
                  await Future.delayed(Duration(seconds: 2));
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              child: Text('show dialog for until user dismiss it'),
            ),
          ],
        ),
      ),
    );
  }
}
