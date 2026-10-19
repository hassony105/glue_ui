import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glue_ui/glue_ui.dart';
import 'package:glue_ui/services/custom_exeption.dart';
import 'package:glue_ui/widgets/glue_snack_bar_host.dart';

/// A service that displays snack bars from anywhere in the app, without a
/// [BuildContext] and without needing a [Scaffold].
///
/// Like [DialogService], snack bars are inserted as [OverlayEntry]s into the
/// overlay of [GlueUI.navigatorKey], so they appear above every route (and
/// above dialogs that were opened before them).
///
/// Like Flutter's `ScaffoldMessenger`, snack bars are shown **one at a time**:
/// calling [show] while one is visible puts the new one in a FIFO queue.
class SnackBarService {
  SnackBarService();

  final Queue<_SnackBarRequest> _queue = Queue<_SnackBarRequest>();
  _SnackBarRequest? _current;

  /// Whether a snack bar is currently visible (or about to be).
  bool get isActive => _current != null;

  /// Number of snack bars waiting in the queue (not counting the visible one).
  int get queueLength => _queue.length;

  /// Shows a snack bar, or queues it if another one is visible.
  ///
  /// - [message]: the main text. [title] adds bold text above it.
  /// - [type]: picks the default color and icon.
  /// - [duration]: how long it stays visible. Defaults to
  ///   [GlueUIConfig.snackBarDuration].
  /// - [position]: top or bottom. Defaults to [GlueUIConfig.snackBarPosition].
  /// - [actionLabel] / [onAction]: an optional action button. Pressing it
  ///   calls [onAction] and hides the snack bar.
  /// - [showCloseIcon]: shows an "X" button.
  /// - [dismissible]: allows swiping the snack bar away horizontally.
  /// - [onTap]: called when the snack bar body is tapped.
  /// - [builder]: replaces the default look for this snack bar. Defaults to
  ///   [GlueUIConfig.snackBarBuilder].
  /// - [replace]: when `true`, clears the queue and hides the current snack
  ///   bar so this one is shown right away.
  /// - [context]: optional fallback used to find an [Overlay] if
  ///   [GlueUI.navigatorKey] isn't attached to a navigator.
  ///
  /// Returns a [GlueSnackBarController] to close the snack bar or await
  /// [GlueSnackBarController.closed].
  ///
  /// Throws a `CustomException` if no [Overlay] can be found.
  GlueSnackBarController show({
    required String message,
    String? title,
    SnackBarType type = SnackBarType.normal,
    Duration? duration,
    SnackBarPosition? position,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseIcon = false,
    bool dismissible = true,
    VoidCallback? onTap,
    GlueSnackBarBuilder? builder,
    bool replace = false,
    BuildContext? context,
  }) {
    if (_resolveOverlay(context) == null) {
      throw CustomException(
        message: 'Could not find OverlayState to show snack bar. Make sure '
            'GlueUI.instance.navigatorKey is assigned to your MaterialApp.',
      );
    }

    final GlueUIConfig config = GlueUI.instance.config;
    final UniqueKey key = UniqueKey();
    late final _SnackBarRequest request;

    final GlueSnackBarData data = GlueSnackBarData(
      key: key,
      message: message,
      title: title,
      type: type,
      position: position ?? config.snackBarPosition,
      actionLabel: actionLabel,
      showCloseIcon: showCloseIcon,
      onActionPressed: actionLabel == null
          ? null
          : () {
              onAction?.call();
              _close(request, SnackBarClosedReason.action);
            },
      dismiss: () => _close(request, SnackBarClosedReason.dismiss),
    );

    request = _SnackBarRequest(
      data: data,
      duration: duration ?? config.snackBarDuration,
      dismissible: dismissible,
      onTap: onTap,
      builder: builder ?? config.snackBarBuilder,
      context: context,
    );

    if (replace) {
      _clearQueue();
      final _SnackBarRequest? current = _current;
      if (current != null) _close(current, SnackBarClosedReason.hide);
    }

    _queue.add(request);
    _showNext();

    return GlueSnackBarController._(
      key: key,
      closed: request.completer.future,
      onClose: () => hide(key),
    );
  }

  /// Hides a snack bar.
  ///
  /// With no [key], hides the visible snack bar (the next queued one then
  /// appears). With a [key], hides that snack bar if it's visible, or removes
  /// it from the queue if it hasn't been shown yet. Unknown or already-closed
  /// keys are ignored.
  void hide([UniqueKey? key]) {
    final _SnackBarRequest? current = _current;
    if (key == null || current?.data.key == key) {
      if (current != null) _close(current, SnackBarClosedReason.hide);
      return;
    }
    for (final _SnackBarRequest request in _queue) {
      if (request.data.key == key) {
        _close(request, SnackBarClosedReason.remove);
        return;
      }
    }
  }

  /// Clears the queue and hides the visible snack bar.
  void hideAll() {
    _clearQueue();
    final _SnackBarRequest? current = _current;
    if (current != null) _close(current, SnackBarClosedReason.hide);
  }

  void _clearQueue() {
    while (_queue.isNotEmpty) {
      final _SnackBarRequest request = _queue.removeFirst();
      if (!request.completer.isCompleted) {
        request.completer.complete(SnackBarClosedReason.remove);
      }
    }
  }

  OverlayState? _resolveOverlay(BuildContext? context) {
    final OverlayState? overlay =
        GlueUI.instance.navigatorKey.currentState?.overlay;
    if (overlay != null) return overlay;
    if (context != null && context.mounted) return Overlay.maybeOf(context);
    return null;
  }

  /// Shows the next queued snack bar if none is visible.
  void _showNext() {
    if (_current != null || _queue.isEmpty) return;
    final _SnackBarRequest request = _queue.removeFirst();
    _current = request;
    // Insert after the current frame so [show] is safe to call from build
    // methods, initState, etc. Make sure a frame is actually coming.
    SchedulerBinding.instance.addPostFrameCallback((_) => _insert(request));
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _insert(_SnackBarRequest request) {
    // Closed (e.g. via hide/replace) before it ever reached the screen.
    final SnackBarClosedReason? pending = request.pendingCloseReason;
    if (pending != null) {
      _finish(request, pending);
      return;
    }

    final OverlayState? overlay = _resolveOverlay(request.context);
    if (overlay == null) {
      debugPrint('GlueUI: no Overlay available, snack bar was dropped.');
      _finish(request, SnackBarClosedReason.remove);
      return;
    }

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => GlueSnackBarHost(
        key: request.hostKey,
        data: request.data,
        duration: request.duration,
        dismissible: request.dismissible,
        onTap: request.onTap,
        builder: request.builder,
        onClosed: (SnackBarClosedReason reason) => _finish(request, reason),
        onDisposed: () => _finish(
          request,
          SnackBarClosedReason.remove,
          removeEntry: false,
        ),
      ),
    );
    request.entry = entry;
    overlay.insert(entry);
  }

  /// Asks [request] to close with [reason], wherever it currently is.
  void _close(_SnackBarRequest request, SnackBarClosedReason reason) {
    if (request.completer.isCompleted) return;

    if (_queue.remove(request)) {
      request.completer.complete(reason);
      return;
    }

    if (identical(request, _current)) {
      final GlueSnackBarHostState? host = request.hostKey.currentState;
      if (host != null) {
        host.close(reason); // Animates out, then calls _finish.
      } else {
        request.pendingCloseReason ??= reason; // Not inserted yet.
      }
    }
  }

  /// Removes [request] from the screen, completes its future and shows the
  /// next queued snack bar.
  ///
  /// [removeEntry] is `false` when the host is being disposed by the
  /// framework, where touching the overlay is not allowed.
  void _finish(
    _SnackBarRequest request,
    SnackBarClosedReason reason, {
    bool removeEntry = true,
  }) {
    final OverlayEntry? entry = request.entry;
    request.entry = null;
    if (removeEntry && entry != null) {
      entry.remove();
      entry.dispose();
    }

    if (!request.completer.isCompleted) request.completer.complete(reason);
    if (identical(_current, request)) _current = null;
    _showNext();
  }
}

/// Handle to a snack bar returned by [SnackBarService.show].
class GlueSnackBarController {
  GlueSnackBarController._({
    required this.key,
    required this.closed,
    required VoidCallback onClose,
  }) : _onClose = onClose;

  /// Identifies the snack bar; can be passed to [SnackBarService.hide].
  final UniqueKey key;

  /// Completes when the snack bar is gone, with the reason it closed:
  /// [SnackBarClosedReason.timeout], `action`, `dismiss` (close icon),
  /// `swipe`, `hide` (closed from code) or `remove` (dropped from the queue).
  final Future<SnackBarClosedReason> closed;

  final VoidCallback _onClose;

  /// Hides this snack bar, or removes it from the queue if it's still waiting.
  void close() => _onClose();
}

/// A private helper class that holds a snack bar request and its runtime state.
class _SnackBarRequest {
  _SnackBarRequest({
    required this.data,
    required this.duration,
    required this.dismissible,
    this.onTap,
    this.builder,
    this.context,
  });

  final GlueSnackBarData data;
  final Duration duration;
  final bool dismissible;
  final VoidCallback? onTap;
  final GlueSnackBarBuilder? builder;
  final BuildContext? context;

  final Completer<SnackBarClosedReason> completer =
      Completer<SnackBarClosedReason>();
  final GlobalKey<GlueSnackBarHostState> hostKey =
      GlobalKey<GlueSnackBarHostState>();

  OverlayEntry? entry;
  SnackBarClosedReason? pendingCloseReason;
}
