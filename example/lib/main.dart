import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glue_ui/glue_ui.dart';

void main() {
  GlueUI.instance.initialize(
    config: GlueUIConfig(
      defaultIndicator: const SizedBox(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(color: Colors.red),
      ),
      overlayColor: Colors.black.withValues(alpha: 0.5),
    ),
  );

  runApp(
    GlueAppDelegate(
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

GlobalKey<ScaffoldMessengerState> scaffoldMessengerStateKey = GlobalKey<ScaffoldMessengerState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void showIndicator2() async {
    try {
      print('indicator 2 starting');
      GlueUI.instance.loader.show();
      print('indicator 2 started');
      await Future.delayed(const Duration(seconds: 2));
      print('indicator 2 ending');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      GlueUI.instance.loader.hide();
    }
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
                  GlueUI.instance.loader.show();
                  print('before indicator 2');
                  showIndicator2();
                  print('after indicator 2');
                  await Future.delayed(const Duration(seconds: 2));
                  print('complete and hiding indicator 1');
                } catch (e) {
                  if (kDebugMode) print(e);
                } finally {
                  GlueUI.instance.loader.hide();
                }
              },
              child: const Text('show indicator'),
            ),
            ElevatedButton(onPressed: showIndicator2, child: const Text('show indicator 2')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final key = await GlueUI.instance.dialog.show(
                    context: context,
                    title: 'Dialog Title',
                    desc: 'Dialog Description',
                    type: DialogType.success,
                  );
                  await Future.delayed(const Duration(seconds: 2));
                  GlueUI.instance.dialog.hide(key);
                } catch (e) {
                  if (kDebugMode) print(e);
                }
              },
              child: const Text('show dialog for specific duration'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await GlueUI.instance.dialog.show(
                    context: context,
                    title: 'Dialog Title',
                    desc: 'Dialog Description',
                    type: DialogType.success,
                  );
                } catch (e) {
                  if (kDebugMode) print(e);
                }
              },
              child: const Text('show dialog for until user dismiss it'),
            ),
          ],
        ),
      ),
    );
  }
}
