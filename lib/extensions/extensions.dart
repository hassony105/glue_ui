import 'package:flutter/widgets.dart';

/// Extension methods on [BuildContext] to provide convenience accessors.
///
/// This extension adds helpful getters to [BuildContext] for easily
/// accessing common properties like screen size.
extension OnBuildContext on BuildContext {
  /// Returns the size of the screen associated with this [BuildContext].
  ///
  /// This is a shorthand for `MediaQuery.sizeOf(this)`.
  Size get screenSize => MediaQuery.sizeOf(this);
}
