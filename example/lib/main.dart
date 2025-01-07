import 'package:flutter/material.dart';
import 'package:fs_widgets/fs_widgets.dart';

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
      home: const HomePage(),
    );
  }
}

class Item {
  final ValueNotifier<String> name;

  Item(String name) : name = ValueNotifier<String>(name);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: FsVideoPlayer(
        src: FsVideoPlayerUrlSrc(
          'http://192.168.0.8/file/okmes/esop-file/2024-10-22/603743931510789/video/603743931510789.mp4?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBOYW1lIjoiT2tNZXMiLCJVc2VySWQiOjEyLCJUZW5hbnRJZCI6MSwiQWNjb3VudCI6InllaGFpbWluIiwiTmFtZSI6IuWPtua1t-awkSIsIklzU3VwZXJBZG1pbiI6ImZhbHNlIiwiaWF0IjoxNzM2MjM0MDkwLCJuYmYiOjE3MzYyMzQwOTAsImV4cCI6MTczNjgzODg5MCwiaXNzIjoiT2tNZXMtQmFja2VuZCIsImF1ZCI6Ik9rTWVzLUZyb250ZW5kIn0.FHwEZLCpprF1Mp4LOiVptga3IinuxBPmrA_5CrksJeg',
        ),
      ),
    );
  }
}
