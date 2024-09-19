import 'package:flutter/material.dart';
import 'package:fs_widgets/widgets/stepper/fs_stepper.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  FsStepperController controller = FsStepperController();

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
  final List<Item> items = [
    Item('Item 1'),
    Item('Item 2'),
    Item('Item 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final Item item = items[index];

            return Dismissible(
              key: Key(item.name.value),
              onDismissed: (DismissDirection direction) {
                setState(() {
                  items.removeAt(index);
                });
              },
              child: ListTile(
                title: ValueListenableBuilder<String>(
                  valueListenable: item.name,
                  builder: (BuildContext context, String value, child) {
                    return Text(value);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
