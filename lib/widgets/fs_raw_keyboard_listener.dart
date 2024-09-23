import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FsRawKeyboardListenerController extends GetxController {
  final focus = false.obs;

  void toggle() {
    focus.value = !focus.value;
    focus.refresh();
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
  late FocusNode focusNode;
  bool _disable = false;
  String text = "";

  Timer? _timer;

  @override
  void initState() {
    controller =
        Get.put(widget.controller ?? FsRawKeyboardListenerController());
    focusNode = FocusNode();

    if (controller.focus.value) {
      _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
        focusNode.requestFocus();
        debugPrint('获取焦点中...');
      });
    }

    ever(controller.focus, (callback) {
      _timer?.cancel();

      if (controller.focus.value) {
        _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
          focusNode.requestFocus();
          debugPrint('获取焦点中...');
        });
      } else {
        _timer?.cancel();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (RawKeyEvent event) async {
        if (_disable) return;
        if (event.runtimeType == RawKeyDownEvent) {
          if (event.data is RawKeyEventDataAndroid) {
            RawKeyEventDataAndroid data = event.data as RawKeyEventDataAndroid;
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
      },
      child: widget.child,
    );
  }
}
