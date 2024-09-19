import 'package:flutter/material.dart';

class FsRotatableController {
  ValueNotifier<int> turns = ValueNotifier<int>(0);

  void rotate() {
    turns.value = (turns.value + 1) % 4;
  }
}

class FsRotatable extends StatefulWidget {
  const FsRotatable({
    super.key,
    this.controller,
    required this.child,
  });

  final FsRotatableController? controller;
  final Widget child;

  @override
  State<FsRotatable> createState() => _FsRotatableState();
}

class _FsRotatableState extends State<FsRotatable> {
  late FsRotatableController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? FsRotatableController();
  }

  @override
  Widget build(context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9, // 默认宽高比
        child: ValueListenableBuilder(
          valueListenable: controller.turns,
          builder: (BuildContext context, value, Widget? child) {
            return RotatedBox(
              quarterTurns: value,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
