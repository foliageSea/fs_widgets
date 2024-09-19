import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FsDescriptions extends StatefulWidget {
  const FsDescriptions({
    super.key,
    required this.items,
    required this.height,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });

  final List<FsDescriptionsItem> items;
  final double height;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  State<FsDescriptions> createState() => _FsDescriptionsState();
}

class _FsDescriptionsState extends State<FsDescriptions> {
  late List<FsDescriptionsItem> items;

  void updateProps() {
    items = widget.items;
  }

  @override
  void initState() {
    super.initState();
    updateProps();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AlignedGridView.count(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        itemBuilder: (context, index) {
          var item = items[index];

          var valueTextStyle = item.valueTextStyle;

          return Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Flexible(
                child: Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: item.value,
                  child: Text(
                    item.value ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueTextStyle?.copyWith(),
                  ),
                ),
              ),
              if (item.slot != null) item.slot!
            ],
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

class FsDescriptionsItem {
  final String title;
  final String? value;
  final TextStyle? valueTextStyle;
  final Widget? slot;
  FsDescriptionsItem({
    required this.title,
    this.value,
    this.valueTextStyle,
    this.slot,
  });
}
