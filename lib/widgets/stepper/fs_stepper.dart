import 'package:flutter/material.dart';

class FsStepperController {
  final ValueNotifier<int> _count = ValueNotifier<int>(0);
  final TextEditingController _textEditingController = TextEditingController();

  FsStepperController() {
    _textEditingController.text = _count.value.toString();
  }

  void increment() {
    _count.value++;
    _textEditingController.text = _count.value.toString();
  }

  void decrement() {
    _count.value--;
    _textEditingController.text = _count.value.toString();
  }

  ValueNotifier<int> get count => _count;

  TextEditingController get textEditingController => _textEditingController;
}

class FsStepper extends StatefulWidget {
  const FsStepper({
    super.key,
    this.controller,
  });

  final FsStepperController? controller;

  @override
  State<FsStepper> createState() => _FsStepperState();
}

class _FsStepperState extends State<FsStepper> {
  late FsStepperController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? FsStepperController();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller._count,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  controller.decrement();
                },
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextField(
                  controller: controller._textEditingController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  controller.increment();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}
