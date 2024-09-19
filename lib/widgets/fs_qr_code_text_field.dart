// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FsQrCodeTextField extends StatefulWidget {
  const FsQrCodeTextField({
    super.key,
    this.controller,
    this.autofocus = false,
    this.decoration = const InputDecoration(),
    this.focusNode,
    this.onSubmitted,
    this.readOnly = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Future Function(String value)? onSubmitted;
  final InputDecoration? decoration;
  final bool autofocus;
  final bool readOnly;

  @override
  State<FsQrCodeTextField> createState() => _FsQrCodeTextFieldState();
}

class _FsQrCodeTextFieldState extends State<FsQrCodeTextField> {
  bool _disable = false;
  late TextEditingController _controller;

  bool _calReadOnly() {
    return Platform.isAndroid && widget.readOnly ? true : false;
  }

  Future _onSubmitted(String value) async {
    _disable = true;
    try {
      await widget.onSubmitted?.call(value);
    } catch (_) {
    } finally {
      _disable = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // 监听键盘事件
      focusNode: FocusNode(),
      onKey: onKey,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: widget.decoration?.copyWith(
          border: const OutlineInputBorder(),
        ),
        showCursor: true,
        readOnly: _calReadOnly(),
        autofocus: widget.autofocus,
        onSubmitted: (value) async {
          if (_disable) {
            return;
          }
          await _onSubmitted(value);
        },
      ),
    );
  }

  void onKey(event) async {
    if (_disable) {
      return;
    }
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.data is RawKeyEventDataAndroid) {
        RawKeyEventDataAndroid data = event.data as RawKeyEventDataAndroid;
        switch (data.keyCode) {
          case 66:
            if (!_calReadOnly()) {
              return;
            }
            // 回车
            await _onSubmitted(_controller.text);
            break;
          case 67:
            // 删除
            String str = _controller.text;
            if (str.isNotEmpty) {
              _controller.text = str.substring(0, str.length - 1);
            }
            break;
          case 62:
            // 空格
            _controller.text += ' ';
            break;
          default:
            // 修改这里以支持大写字母输入
            String keyLabel = data.keyLabel;
            if (data.isShiftPressed) {
              keyLabel = keyLabel.toUpperCase();
            }
            _controller.text += keyLabel;
            break;
        }
      }
    }
  }
}
