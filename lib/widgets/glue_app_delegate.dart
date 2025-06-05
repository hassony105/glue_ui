import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glue_ui/services/indicator_service.dart';

import 'controller_widget.dart';

const String cLoading = 'loading';
const String cWidgetBuilder = 'widget_builder';
const String cProgress = 'progress';
const String cShowOverlay = 'show_overlay';

typedef OverlayWidgetBuilder = Widget Function(dynamic progress);
typedef OverlayTransitionBuilder = Widget Function(Widget, Animation<double>);
typedef OverlayLayoutBuilder = Widget Function(Widget?, List<Widget>);

/// Class that effectively display the overlay on the screen. It's a Stateful widget
/// so we can dispose when not needed anymore
class GlueAppDelegate extends StatefulWidget {
  const GlueAppDelegate({
    super.key,
    this.indicatorWidget,
    required this.child,
  });

  final bool useBackButtonInterceptor = !kIsWeb;

  final bool disableBackButton = true;

  final bool overlayWholeScreen = true;

  final bool closeOnBackButton = false;



  /// The widget of the overlay. This is great if you want to insert your own widget to serve as
  /// an overlay.
  final Widget? indicatorWidget;

  static const _prefix = '@loader-overlay';

  static const defaultOverlayWidgetKey = Key('$_prefix/default-widget');

  static Color defaultOverlayColor = Colors.grey.withValues(alpha: 0.4);

  static const containerForOverlayColorKey =
  Key('$_prefix/container-for-overlay-color');

  final Widget child;

  @override
  State<GlueAppDelegate> createState() => _GlueAppDelegateState();
}

class _GlueAppDelegateState extends State<GlueAppDelegate> {
  IndicatorControllerWidget? _overlayControllerWidget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _overlayControllerWidget = IndicatorControllerWidget.of(context);
    });
  }

  @override
  void dispose() {
    _overlayControllerWidget?.dispose();
    if (!kIsWeb) {
      BackButtonInterceptor.remove((stopDefaultButtonEvent, routeInfo) => true);
    }
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (context.loaderOverlay.visible && widget.closeOnBackButton) {
      context.loaderOverlay.hide();
    }
    return widget.disableBackButton;
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: IndicatorControllerWidget(
        child: Builder(
          builder: (innerContext) => StreamBuilder<Map<String, dynamic>>(
            stream: innerContext.loaderOverlay.overlayController.visibilityStream,
            initialData: const <String, dynamic>{
              cLoading: false,
              cWidgetBuilder: null,
              cProgress: null,
              cShowOverlay: true,
            },
            builder: (_, snapshot) {
              // ignore: unused_local_variable
              final visibilityStream =
                  innerContext.loaderOverlay.overlayController.visibilityStream;
              final isLoading = snapshot.data![cLoading] as bool;
              final widgetOverlayBuilder = snapshot.data![cWidgetBuilder]
              as Widget Function(dynamic progress)?;
              final progress = snapshot.data![cProgress] as dynamic;
              final showOverlay = snapshot.data![cShowOverlay] as bool;

              if (!kIsWeb) {
                if (isLoading) {
                  BackButtonInterceptor.add(myInterceptor);
                } else {
                  BackButtonInterceptor.remove(myInterceptor);
                }
              }
      
              return Stack(
                children: <Widget>[
                  widget.child,
                  AnimatedSwitcher(
                    duration: Duration.zero,
                    reverseDuration: Duration.zero,
                    switchInCurve: Curves.linear,
                    switchOutCurve: Curves.linear,
                    transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
                    layoutBuilder: AnimatedSwitcher.defaultLayoutBuilder,
                    child: isLoading
                        ? Stack(
                      children: _getLoadingWidget(
                        isLoading,
                        widgetOverlayBuilder: widgetOverlayBuilder,
                        progress: progress,
                        showOverlay: showOverlay,
                      ),
                    )
                        : SizedBox.shrink(key: UniqueKey()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _getLoadingWidget(
      bool isLoading, {
        Widget Function(dynamic progress)? widgetOverlayBuilder,
        dynamic progress,
        bool showOverlay = true,
      }) =>
      [
        PopScope(
          canPop: !widget.disableBackButton,
          child: showOverlay
              ? widget.overlayWholeScreen
              ? SizedBox.expand(
            child: ColoredBox(
              key: GlueAppDelegate.containerForOverlayColorKey,
              color: Colors.black.withValues(alpha: .5)
            ),
          )
              : Center(
            child: SizedBox(
              child: ColoredBox(
                key: GlueAppDelegate.containerForOverlayColorKey,
                color: Colors.black.withValues(alpha: .5),
              ),
            ),
          )
              : const SizedBox(),
        ),
        if (widgetOverlayBuilder != null)
          _OverlayWidgetBuilder(
            child: widgetOverlayBuilder(progress),
          )
        else if (widget.indicatorWidget != null)
          _OverlayWidgetBuilder(
            child: widget.indicatorWidget!,
          )
        else
          const _DefaultOverlayWidget(),
      ];
}

class _OverlayWidgetBuilder extends StatelessWidget {
  const _OverlayWidgetBuilder({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

class _DefaultOverlayWidget extends StatelessWidget {
  const _DefaultOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        key: GlueAppDelegate.defaultOverlayWidgetKey,
      ),
    );
  }
}


