import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FsMessagePanelController extends GetxController {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late ScrollController scrollController;
  final RxList<FsMessagePanelItem> items = <FsMessagePanelItem>[].obs;

  void addMessage(FsMessagePanelItem item) {
    items.insert(0, item);
    listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 500),
    );
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
  }
}

class FsMessagePanel extends StatefulWidget {
  const FsMessagePanel({super.key, this.controller, this.items});

  final FsMessagePanelController? controller;
  final List<FsMessagePanelItem>? items;

  @override
  State<FsMessagePanel> createState() => _FsMessagePanelState();
}

class _FsMessagePanelState extends State<FsMessagePanel> {
  late FsMessagePanelController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(widget.controller ?? FsMessagePanelController());
    controller.items.value = widget.items ?? [];
    controller.items.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.items;
    return AnimatedList(
      key: controller.listKey,
      controller: controller.scrollController,
      itemBuilder: (context, index, animation) {
        final item = items[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _buildMessageItemCard(item),
        );
      },
      initialItemCount: items.length,
    );
  }

  Widget _buildMessageItemCard(FsMessagePanelItem item) {
    final subTitle = item.subTitle;
    final title = item.title;
    Widget subTitleWidget = Container();
    Widget titleWidget = Text(
      '信息: $title',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
      ),
    );

    if (subTitle != null) {
      subTitleWidget = Text(
        '条码: $subTitle',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: item.state ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(3),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ),
              child: Text(
                item.state ? "OK" : "Fail",
                style: const TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subTitleWidget,
                  titleWidget,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FsMessagePanelItem {
  final String title;
  final bool state;
  final String? subTitle;

  FsMessagePanelItem(this.title, [this.subTitle, this.state = true]);
}

class FsMessagePanelPassItem extends FsMessagePanelItem {
  FsMessagePanelPassItem(super.title, [super.subTitle, super.state = true]);
}

class FsMessagePanelFailItem extends FsMessagePanelItem {
  FsMessagePanelFailItem(super.title, [super.subTitle, super.state = false]);
}
