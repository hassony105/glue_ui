import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glue_ui/glue_ui.dart';

typedef OverlayWidgetBuilder = Widget Function(dynamic progress);
typedef OverlayTransitionBuilder = Widget Function(Widget, Animation<double>);
typedef OverlayLayoutBuilder = Widget Function(Widget?, List<Widget>);

/// Class that effectively display the overlay on the screen.
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

  /// The widget of the overlay.
  final Widget? indicatorWidget;

  static const _prefix = '@loader-overlay';
  static const defaultOverlayWidgetKey = Key('$_prefix/default-widget');
  static const containerForOverlayColorKey = Key('$_prefix/container-for-overlay-color');

  final Widget child;

  @override
  State<GlueAppDelegate> createState() => _GlueAppDelegateState();
}

class _GlueAppDelegateState extends State<GlueAppDelegate> {
  @override
  void dispose() {
    if (!kIsWeb) {
      BackButtonInterceptor.remove((stopDefaultButtonEvent, routeInfo) => true);
    }
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (GlueUI.instance.loader.visible && widget.closeOnBackButton) {
      GlueUI.instance.loader.hide();
    }
    return widget.disableBackButton;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: StreamBuilder<IndicatorState>(
        stream: GlueUI.instance.loader.visibilityStream,
        initialData: const IndicatorState(),
        builder: (_, snapshot) {
          final state = snapshot.data ?? const IndicatorState();
          
          if (!kIsWeb) {
            if (state.isLoading) {
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
                child: state.isLoading
                    ? Stack(
                        children: _getLoadingWidget(
                          state.isLoading,
                          widgetOverlayBuilder: state.widgetBuilder,
                          progress: state.progress,
                          showOverlay: state.showOverlay,
                        ),
                      )
                    : SizedBox.shrink(key: UniqueKey()),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _getLoadingWidget(
    bool isLoading, {
    Widget Function(dynamic progress)? widgetOverlayBuilder,
    dynamic progress,
    bool showOverlay = true,
  }) {
    final defaultOverlayColor = GlueUI.instance.config.overlayColor ?? Colors.black.withValues(alpha: .5);
    return [
      PopScope(
        canPop: !widget.disableBackButton,
        child: showOverlay
            ? widget.overlayWholeScreen
                ? SizedBox.expand(
                    child: ColoredBox(
                      key: GlueAppDelegate.containerForOverlayColorKey,
                      color: defaultOverlayColor,
                    ),
                  )
                : Center(
                    child: SizedBox(
                      child: ColoredBox(
                        key: GlueAppDelegate.containerForOverlayColorKey,
                        color: defaultOverlayColor,
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
      else if (GlueUI.instance.config.defaultIndicator != null)
        _OverlayWidgetBuilder(
          child: GlueUI.instance.config.defaultIndicator!,
        )
      else
        const _DefaultOverlayWidget(),
    ];
  }
}

class _OverlayWidgetBuilder extends StatelessWidget {
  const _OverlayWidgetBuilder({
    required this.child,
  });

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
  const _DefaultOverlayWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        key: GlueAppDelegate.defaultOverlayWidgetKey,
      ),
    );
  }
}


