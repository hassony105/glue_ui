import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glue_ui/glue_ui.dart';

/// A minimal app with **no Scaffold**, to prove snack bars don't need one.
Widget _app() => GlueAppDelegate(
  child: MaterialApp(
    navigatorKey: GlueUI.instance.navigatorKey,
    home: const SizedBox.expand(),
  ),
);

SnackBarService get _snackBar => GlueUI.instance.snackBar;

void main() {
  setUp(() => GlueUI.instance.initialize());

  tearDown(() => _snackBar.hideAll());

  testWidgets('throws when no navigator is attached', (tester) async {
    await tester.pumpWidget(const SizedBox());
    expect(() => _snackBar.show(message: 'x'), throwsA(isA<Exception>()));
  });

  testWidgets('shows without a Scaffold and hides on timeout', (tester) async {
    await tester.pumpWidget(_app());

    SnackBarClosedReason? reason;
    final controller = _snackBar.show(
      message: 'Hello',
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
    controller.closed.then((r) => reason = r);

    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(_snackBar.isActive, isTrue);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    expect(reason, SnackBarClosedReason.timeout);
    expect(_snackBar.isActive, isFalse);
  });

  testWidgets('queues snack bars and shows them one at a time', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    final first = _snackBar.show(message: 'First');
    _snackBar.show(message: 'Second');
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    expect(_snackBar.queueLength, 1);

    first.close();
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(await first.closed, SnackBarClosedReason.hide);

    _snackBar.hideAll();
    await tester.pumpAndSettle();
  });

  testWidgets('hide(key) removes a queued snack bar', (tester) async {
    await tester.pumpWidget(_app());

    _snackBar.show(message: 'Visible');
    final queued = _snackBar.show(message: 'Queued');
    await tester.pumpAndSettle();

    _snackBar.hide(queued.key);
    expect(await queued.closed, SnackBarClosedReason.remove);
    expect(_snackBar.queueLength, 0);
    expect(find.text('Visible'), findsOneWidget);

    _snackBar.hideAll();
    await tester.pumpAndSettle();
  });

  testWidgets('action button calls onAction and closes', (tester) async {
    await tester.pumpWidget(_app());

    var pressed = false;
    final controller = _snackBar.show(
      message: 'Deleted',
      actionLabel: 'UNDO',
      onAction: () => pressed = true,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
    expect(await controller.closed, SnackBarClosedReason.action);
    expect(find.text('Deleted'), findsNothing);
  });

  testWidgets('close icon dismisses', (tester) async {
    await tester.pumpWidget(_app());

    final controller = _snackBar.show(message: 'Bye', showCloseIcon: true);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(await controller.closed, SnackBarClosedReason.dismiss);
  });

  testWidgets('can be swiped away', (tester) async {
    await tester.pumpWidget(_app());

    final controller = _snackBar.show(message: 'Swipe me');
    await tester.pumpAndSettle();

    await tester.drag(find.text('Swipe me'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Swipe me'), findsNothing);
    expect(await controller.closed, SnackBarClosedReason.swipe);
    expect(_snackBar.isActive, isFalse);
  });

  testWidgets('replace clears the queue and shows the new one', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    final a = _snackBar.show(message: 'A');
    final b = _snackBar.show(message: 'B');
    await tester.pumpAndSettle();

    _snackBar.show(message: 'C', replace: true);
    await tester.pumpAndSettle();

    expect(await a.closed, SnackBarClosedReason.hide);
    expect(await b.closed, SnackBarClosedReason.remove);
    expect(find.text('C'), findsOneWidget);

    _snackBar.hideAll();
    await tester.pumpAndSettle();
  });

  testWidgets('uses the custom builder from config', (tester) async {
    GlueUI.instance.initialize(
      config: GlueUIConfig(
        snackBarBuilder: (context, data) => Text('custom: ${data.message}'),
      ),
    );
    await tester.pumpWidget(_app());

    _snackBar.show(message: 'hi', position: SnackBarPosition.top);
    await tester.pumpAndSettle();
    expect(find.text('custom: hi'), findsOneWidget);

    _snackBar.hideAll();
    await tester.pumpAndSettle();
  });

  testWidgets('show() is safe to call during build', (tester) async {
    await tester.pumpWidget(
      GlueAppDelegate(
        child: MaterialApp(
          navigatorKey: GlueUI.instance.navigatorKey,
          home: Builder(
            builder: (context) {
              if (!_snackBar.isActive) {
                _snackBar.show(message: 'From build', context: context);
              }
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('From build'), findsOneWidget);

    _snackBar.hideAll();
    await tester.pumpAndSettle();
  });
}
