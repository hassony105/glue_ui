import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glue_ui/glue_ui.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<ScaffoldMessengerState> scaffoldMessengerStateKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Glue UI Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'Glue UI'),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerStateKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        GlueUI.instance.initialize(
          context: context,
          nsKey: navigatorKey,
          logoImage: AssetImage('assets/glue-ui-logo.png'),
          errorMessage: 'Failed to initialize GlueUI.',
        );
      } catch (e){
        if (kDebugMode) {
          print(e);
        }
      }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ),
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
            ),
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
            ),
          ],
        ),
      ),
    );
  }
}
