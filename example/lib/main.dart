import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fs_widgets/fs_widgets.dart';

import 'widgets/test_fs_future_builder_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const TestFsFutureBuilderPage(),
    );
  }
}
