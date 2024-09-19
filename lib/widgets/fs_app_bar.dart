import 'package:flutter/material.dart';

import 'package:get/get.dart';

class FsAppBar extends StatefulWidget implements PreferredSizeWidget {
  const FsAppBar({
    super.key,
    this.title,
    this.actions,
  });

  final String? title;
  final List<Widget>? actions;

  @override
  State<FsAppBar> createState() => _FsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FsAppBarState extends State<FsAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title ?? '',
      ),
      actions: widget.actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
            ),
          ],
    );
  }
}
