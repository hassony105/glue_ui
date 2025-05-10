import 'package:flutter/material.dart';

class AnimatedIndicatorWidget extends StatefulWidget {
  final double size;
  final ImageProvider? image;
  const AnimatedIndicatorWidget({
    super.key,
    required this.size,
    required this.image,
  });

  @override
  State<AnimatedIndicatorWidget> createState() =>
      _AnimatedIndicatorWidgetState();
}

class _AnimatedIndicatorWidgetState extends State<AnimatedIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<Color?> _colorAnimation = TweenSequence<Color?>([
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.blue, end: Colors.green),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.green, end: Colors.yellow),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.yellow, end: Colors.red),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.red, end: Colors.purple),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.purple, end: Colors.blue),
      weight: 1,
    ),
  ]).animate(_controller);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (_, _) {
        return Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            color: Colors.black,
            image:
                widget.image != null
                    ? DecorationImage(
                      image: widget.image!,
                      alignment: Alignment.center,
                      fit: BoxFit.scaleDown,
                      scale: 15,
                    )
                    : null,
            borderRadius: BorderRadius.circular(150),
            border: Border.all(color: Colors.white, width: .75),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color?>(_colorAnimation.value),
          ),
        );
      },
    );
  }
}
