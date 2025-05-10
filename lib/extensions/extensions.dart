import 'package:flutter/widgets.dart';

extension OnBuildContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
}
