import 'package:flutter/material.dart';

class FsCard extends StatelessWidget {
  const FsCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
  });

  final Widget child;
  final double? width;
  final double? height;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: child,
      ),
    );
  }
}
