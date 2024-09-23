import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FsRawKeyboardListenerController {
  final focus = ValueNotifier(false);
  late FocusNode focusNode;
  Timer? timer;

  void toggle() {
    focus.value = !focus.value;
  }

  FsRawKeyboardListenerController() {
    focus.addListener(_handleFocusStateChange);
  }

  void dispose() {
    focus.removeListener(_handleFocusStateChange);
    timer?.cancel();
    focusNode.dispose();
  }

  void _handleFocusStateChange() {
    if (focus.value) {
      startFocus();
    } else {
      endFocus();
    }
  }

  void endFocus() {
    debugPrint('✨结束获取焦点...');
    timer?.cancel();
  }

  void startFocus() {
    debugPrint('✨开始获取焦点');
    timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      focusNode.requestFocus();
      debugPrint('✨获取焦点中...');
    });
  }
}

class FsRawKeyboardListener extends StatefulWidget {
  final FsRawKeyboardListenerController? controller;
  final Widget child;
  final Future Function(String value)? onSubmit;

  const FsRawKeyboardListener({
    super.key,
    this.controller,
    required this.child,
    this.onSubmit,
  });

  @override
  State<FsRawKeyboardListener> createState() => _FsRawKeyboardListenerState();
}

class _FsRawKeyboardListenerState extends State<FsRawKeyboardListener> {
  late FsRawKeyboardListenerController controller;
  bool _disable = false;
  String text = "";

  @override
  void initState() {
    controller = widget.controller ?? FsRawKeyboardListenerController();
    controller.focusNode = FocusNode();

    if (controller.focus.value) {
      controller.startFocus();
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: controller.focusNode,
      onKey: _onKey,
      child: widget.child,
    );
  }

  void _onKey(RawKeyEvent event) async {
    if (_disable) {
      return;
    }
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.data is RawKeyEventDataAndroid) {
        final data = event.data as RawKeyEventDataAndroid;
        switch (data.logicalKey) {
          case LogicalKeyboardKey.enter:
            // 回车
            _disable = true;
            try {
              await widget.onSubmit?.call(text);
            } catch (_) {
            } finally {
              text = "";
              _disable = false;
            }
            break;
          case LogicalKeyboardKey.delete:
            // 删除
            String str = text;
            if (str.isNotEmpty) {
              text = str.substring(0, str.length - 1);
            }
            break;
          case LogicalKeyboardKey.space:
            // 空格
            text += ' ';
            break;
          default:
            // 修改这里以支持大写字母输入
            String keyLabel = data.keyLabel;
            if (data.isShiftPressed) {
              keyLabel = keyLabel.toUpperCase();
            }
            text += keyLabel;
            break;
        }
      }
    }
  }
}
