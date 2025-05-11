import 'package:flutter/material.dart';

/// A widget that displays an animated circular indicator, optionally with an
/// image in the center.
///
/// This widget shows a [CircularProgressIndicator] that animates through a sequence
/// of colors. It can also display an [ImageProvider] in the center of the
/// indicator. The size of the indicator is determined by the `size` parameter.
/// The image to display in the center of the indicator.
class AnimatedIndicatorWidget extends StatefulWidget {
  /// The size of the indicator.
  final double size;

  /// If null, only the animated circular progress indicator is shown.
  final ImageProvider? image;

  /// Creates an [AnimatedIndicatorWidget].
  ///
  /// Requires a [size] for the indicator and an optional [image] to display
  /// in the center.
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
  /// The controller for managing the color animation.
  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true); // Repeat the animation with reversal.

  /// The animation that interpolates through a sequence of colors.
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
    // Dispose the animation controller when the widget is removed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to rebuild the widget whenever the color animation
    // value changes.
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (_, __) {
        // Using '_' for context and '__' for child is common when they are not used.
        return Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            color: Colors.black, // Background color of the container
            image:
                widget.image != null
                    ? DecorationImage(
                      image: widget.image!,
                      alignment: Alignment.center,
                      fit: BoxFit.scaleDown,
                      scale: 15, // Adjust scale for image fitting
                    )
                    : null, // No image if widget.image is null
            borderRadius: BorderRadius.circular(
              150,
            ), // Makes the container circular
            border: Border.all(color: Colors.white, width: .75), // White border
          ),
          // CircularProgressIndicator is placed inside the container to show
          // the animated progress.
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color?>(_colorAnimation.value),
          ),
        );
      },
    );
  }
}
