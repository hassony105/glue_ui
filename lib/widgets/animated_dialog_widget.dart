import 'package:sm_dialog/sm_dialog.dart';
import 'package:flutter/material.dart';

class AnimatedDialogWidget extends StatefulWidget {
  final SMDialog dialog;

  const AnimatedDialogWidget({super.key, required this.dialog});

  @override
  State<AnimatedDialogWidget> createState() => _AnimatedDialogWidgetState();
}

class _AnimatedDialogWidgetState extends State<AnimatedDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
    vsync: this,
    duration: widget.dialog.transitionAnimationDuration,
  );

  @override
  void initState() {
    (() async {
      await controller.animateTo(1);
      setState(() {});
    })();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
    return AnimatedContainer(
      duration: widget.dialog.transitionAnimationDuration,
      alignment: controller.value == 0 ? getInitialAlignment : Alignment.center,
      child: AnimatedScale(
        duration: widget.dialog.transitionAnimationDuration,
        scale: controller.value,
        child: widget.dialog.buildDialog,
      ),
    );
  }
}
