import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FsTouchMouseScrollable extends StatelessWidget {
  const FsTouchMouseScrollable({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: TouchMouseScrollBehavior(),
      child: child,
    );
  }
}

class TouchMouseScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
