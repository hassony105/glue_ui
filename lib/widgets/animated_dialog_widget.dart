import 'package:sm_dialog/sm_dialog.dart';
import 'package:flutter/material.dart';

/// A widget that provides an animated transition for an [SMDialog].
///
/// This widget wraps an [SMDialog] and animates its appearance based on the
/// [animType] and [transitionAnimationDuration] properties of the provided
/// [SMDialog].
class AnimatedDialogWidget extends StatefulWidget {
  /// The [SMDialog] to be animated.
  final SMDialog dialog;

  /// Creates an [AnimatedDialogWidget].
  ///
  /// Requires the [dialog] to be animated.
  const AnimatedDialogWidget({super.key, required this.dialog});

  @override
  State<AnimatedDialogWidget> createState() => _AnimatedDialogWidgetState();
}

class _AnimatedDialogWidgetState extends State<AnimatedDialogWidget>
    with SingleTickerProviderStateMixin {
  /// The controller for managing the animation.
  late AnimationController controller = AnimationController(
    vsync: this,
    duration: widget.dialog.transitionAnimationDuration,
  );

  @override
  void initState() {
    (() async {
      // Animate the controller to the end to trigger the transition.
      await controller.animateTo(1);
      // Trigger a rebuild after the animation completes to ensure the final
      // alignment is applied.
      setState(() {});
    })();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the animation controller when the widget is removed.
    controller.dispose();
    super.dispose();
  }

  /// Determines the initial alignment of the dialog based on its animation type.
  Alignment get getInitialAlignment {
    switch (widget.dialog.animType) {
      case AnimType.scale:
        return Alignment(0.0, 0.0);
      case AnimType.leftSlide:
        return Alignment(1, 0.0);
      case AnimType.rightSlide:
        return Alignment(0.0, 0.0);
      case AnimType.bottomSlide:
        return Alignment(0.0, 2.0);
      case AnimType.topSlide:
        return Alignment(0.0, -2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedContainer and AnimatedScale to create the animation.
    return AnimatedContainer(
      duration: widget.dialog.transitionAnimationDuration,
      // Align the dialog based on the animation value. It starts at the
      // initial alignment and moves to the center.
      alignment: controller.value == 0 ? getInitialAlignment : Alignment.center,
      child: AnimatedScale(
        duration: widget.dialog.transitionAnimationDuration,
        // Scale the dialog based on the animation value. It scales from 0 to 1.
        scale: controller.value,
        child: widget.dialog.buildDialog,
      ),
    );
  }
}
