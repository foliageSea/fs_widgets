import 'package:flutter/material.dart';

extension ListWidgetExtension on List<Widget> {
  List<Widget> insertSizedBoxBetween({double? width, double? height}) {
    if (isEmpty) return this;
    final List<Widget> newList = [];
    for (var i = 0; i < length; i++) {
      newList.add(this[i]);
      if (i != length - 1) {
        newList.add(SizedBox(width: width, height: height));
      }
    }
    return newList;
  }
}
