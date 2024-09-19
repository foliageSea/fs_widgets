import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FsRotatableController extends GetxController {
  RxInt quarterTurns = 0.obs;

  void rotate() {
    quarterTurns.value = (quarterTurns.value + 1) % 4;
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
    controller = Get.put(widget.controller ?? FsRotatableController());
  }

  @override
  Widget build(context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9, // 默认宽高比
        child: Obx(
          () => RotatedBox(
            quarterTurns: controller.quarterTurns.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
