import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glue_ui/models/models.dart';
import 'package:glue_ui/enums/enums.dart';
import 'package:glue_ui/widgets/widgets.dart';

/// Hosts a single snack bar inside an [OverlayEntry].
///
/// Owns the entrance/exit animation, the auto-hide timer, swipe-to-dismiss
/// and the positioning (top/bottom, safe area and keyboard aware).
/// It is created and driven by `SnackBarService`; you normally don't need to
/// use it directly.
class GlueSnackBarHost extends StatefulWidget {
  /// Creates a [GlueSnackBarHost].
  const GlueSnackBarHost({
    super.key,
    required this.data,
    required this.duration,
    required this.onClosed,
    required this.onDisposed,
    this.dismissible = true,
    this.onTap,
    this.builder,
  });

  /// Description of the snack bar to render.
  final GlueSnackBarData data;

  /// How long the snack bar stays fully visible before hiding itself.
  final Duration duration;

  /// Whether the snack bar can be swiped away horizontally.
  final bool dismissible;

  /// Called when the snack bar body is tapped.
  final VoidCallback? onTap;

  /// Optional builder that replaces the default [GlueSnackBarView].
  final GlueSnackBarBuilder? builder;

  /// Called exactly once when the snack bar has finished leaving the screen.
  final ValueChanged<SnackBarClosedReason> onClosed;

  /// Called if the host is disposed without [onClosed] being called, e.g.
  /// when the whole overlay is torn down.
  final VoidCallback onDisposed;

  @override
  State<GlueSnackBarHost> createState() => GlueSnackBarHostState();
}

/// State of [GlueSnackBarHost]. Exposes [close] so the service can animate
/// the snack bar out.
class GlueSnackBarHostState extends State<GlueSnackBarHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 200),
    debugLabel: 'GlueSnackBar',
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  Timer? _timer;
  bool _closing = false;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatusChanged);
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _closing) return;
    // Like Material's SnackBar: with screen readers on, a snack bar that has an
    // action stays until the user deals with it.
    final bool keepForAccessibility =
        MediaQuery.maybeAccessibleNavigationOf(context) == true &&
        widget.data.onActionPressed != null;
    if (!keepForAccessibility) {
      _timer = Timer(
        widget.duration,
        () => close(SnackBarClosedReason.timeout),
      );
    }
  }

  /// Animates the snack bar out and then reports [reason] to the service.
  Future<void> close(SnackBarClosedReason reason) async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    try {
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // The host was disposed mid-animation; [dispose] reports it instead.
      return;
    }
    _notifyClosed(reason);
  }

  /// Reports [reason] without an exit animation (used after a swipe, where
  /// the [Dismissible] has already animated the snack bar away).
  void _closeImmediately(SnackBarClosedReason reason) {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    _notifyClosed(reason);
  }

  void _notifyClosed(SnackBarClosedReason reason) {
    if (_notified) return;
    _notified = true;
    widget.onClosed(reason);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_notified) {
      _notified = true;
      widget.onDisposed();
    }
    _controller.removeStatusListener(_onStatusChanged);
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlueSnackBarData data = widget.data;
    final bool isTop = data.position == SnackBarPosition.top;
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    Widget child =
        widget.builder?.call(context, data) ?? GlueSnackBarView(data: data);

    child = Semantics(container: true, liveRegion: true, child: child);

    if (widget.onTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: child,
      );
    }

    if (widget.dismissible) {
      child = Dismissible(
        key: ValueKey<UniqueKey>(data.key),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => _closeImmediately(SnackBarClosedReason.swipe),
        child: child,
      );
    }

    child = FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, isTop ? -1 : 1),
          end: Offset.zero,
        ).animate(_curve),
        child: child,
      ),
    );

    // Padding/Align don't absorb pointer events, so taps outside the snack
    // bar still reach the app underneath.
    return Padding(
      padding: EdgeInsets.only(
        left: safePadding.left + 12,
        right: safePadding.right + 12,
        top: isTop ? safePadding.top + 8 : 0,
        bottom: isTop ? 0 : safePadding.bottom + viewInsets.bottom + 12,
      ),
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}
