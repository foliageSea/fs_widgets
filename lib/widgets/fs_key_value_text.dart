import 'package:flutter/material.dart';

class FsKeyValueText extends StatefulWidget {
  final String keyText;
  final String? valueText;

  const FsKeyValueText(this.keyText, this.valueText, {super.key});

  @override
  State<FsKeyValueText> createState() => _FsKeyValueTextState();
}

class _FsKeyValueTextState extends State<FsKeyValueText> {
  @override
  Widget build(BuildContext context) {
    const keyTextStyle = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${widget.keyText}' ': ',
          style: keyTextStyle,
        ),
        Flexible(
          child: Text(
            widget.valueText ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
