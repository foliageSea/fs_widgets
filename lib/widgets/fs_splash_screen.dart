import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FsSplashScreenController extends GetxController {
  RxString text = "加载中".obs;

  void setText(String t) {
    text.value = t;
    text.refresh();
  }
}

///
/// SplashScreen 加载屏
///
class FsSplashScreen extends StatefulWidget {
  final FsSplashScreenController? controller;
  final bool loading;
  final Widget child;

  const FsSplashScreen({
    super.key,
    this.controller,
    required this.loading,
    required this.child,
  });

  @override
  State<FsSplashScreen> createState() => _FsSplashScreenState();
}

class _FsSplashScreenState extends State<FsSplashScreen> {
  late FsSplashScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(widget.controller ?? FsSplashScreenController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildSplashScreen(Widget child) {
    return widget.loading
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon/icon.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const CupertinoActivityIndicator(),
                  // const CircularProgressIndicator(),
                  const SizedBox(
                    height: 8,
                  ),
                  Obx(() => Text(controller.text.value)),
                ],
              ),
            ),
          )
        : child;
  }

  @override
  Widget build(BuildContext context) {
    return _buildSplashScreen(widget.child);
  }
}
