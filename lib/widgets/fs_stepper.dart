import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FsStepperController extends GetxController {
  late TextEditingController textEditingController;

  String get value => textEditingController.text;

  void setValue(int value) {
    textEditingController.text = value.toString();
  }

  void _handleSub() {
    var text = textEditingController.text;

    if (text.isEmpty) return;

    var value = int.parse(text);
    if (value > 1.0) {
      value--;
    }

    textEditingController.text = value.toString();
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: textEditingController.text.length,
      ),
    );
  }

  void _handlePlus() {
    var text = textEditingController.text;

    if (text.isEmpty) return;

    var value = int.parse(text);
    value++;

    textEditingController.text = value.toString();
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: textEditingController.text.length),
    );
  }
}

class FsStepper extends StatefulWidget {
  final FsStepperController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputFormatter? textInputFormatter;
  final bool readOnly;

  const FsStepper({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.textInputFormatter,
    this.readOnly = false,
  });

  @override
  State<FsStepper> createState() => _FsStepperState();
}

class _FsStepperState extends State<FsStepper> {
  late FsStepperController controller;

  List<Widget> _buildLabel() {
    if (widget.labelText != null) {
      return [
        Text(widget.labelText!),
        const SizedBox(
          height: 4,
        ),
      ];
    }
    return [];
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildLabel(),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: widget.readOnly ? null : controller._handleSub,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: TextField(
                readOnly: widget.readOnly,
                textAlign: TextAlign.center,
                controller: controller.textEditingController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: widget.hintText,
                ),
                inputFormatters: [
                  widget.textInputFormatter ?? IntegerInputFormatter()
                ],
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            IconButton.filledTonal(
              onPressed: widget.readOnly ? null : controller._handlePlus,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    controller = Get.put(widget.controller ?? FsStepperController());
    controller.textEditingController = TextEditingController();
    controller.setValue(0);
    super.initState();
  }

  @override
  void dispose() {
    controller.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextField();
  }
}

/// 正数输入校验器（包括小数）
class PositiveNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 检查新输入的文本是否为空
    if (newValue.text.isEmpty) {
      return newValue; // 如果文本为空，则允许输入
    }

    // 检查新输入的文本是否符合正数格式
    final String newText = newValue.text;

    // 正则表达式验证正数（包括小数）
    final RegExp regExp = RegExp(r'^\d*\.?\d*$');

    if (regExp.hasMatch(newText)) {
      // 解析为 double 以进一步验证
      try {
        final double parsed = double.parse(newText);
        if (parsed >= 0) {
          return newValue; // 允许输入正数
        }
      } catch (e) {
        log("$e");
        return oldValue;
      }
    }

    // 否则，拒绝输入
    return oldValue;
  }
}

/// 正整数输入校验器
class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 检查新输入的文本是否符合整数格式
    if (newValue.text.isEmpty) {
      return newValue; // 如果文本为空，则允许输入
    }

    late int? parsed;
    try {
      // 尝试将新输入的文本解析为整数
      parsed = int.tryParse(newValue.text);
    } catch (e) {
      log("$e");
      return oldValue;
    }

    // 如果解析成功，并且解析结果等于输入的文本，则允许输入
    if (parsed != null &&
        parsed.toString() == newValue.text &&
        parsed <= 999 &&
        parsed >= 0) {
      return newValue;
    }

    // 否则，拒绝输入
    return oldValue;
  }
}
