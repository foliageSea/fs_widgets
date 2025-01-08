import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fs_widgets/fs_widgets.dart';

class TestFsFutureBuilderPage extends StatefulWidget {
  const TestFsFutureBuilderPage({super.key});

  @override
  State<TestFsFutureBuilderPage> createState() =>
      _TestFsFutureBuilderPageState();
}

class _TestFsFutureBuilderPageState extends State<TestFsFutureBuilderPage> {
  Future<List<int>>? _future;

  Future<List<int>> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));

    var res = getRandomInt(0, 2);

    if (res == 0) {
      throw Exception('出错了');
    }

    if (res == 1) {
      throw FsFutureBuilderDataEmptyError();
    }

    return [1, 2, 3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        actions: [
          IconButton(
            onPressed: () {
              _future = _loadData();
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FsFutureBuilder(
        future: _future,
        build: (BuildContext context, data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              var item = data[index];
              return ListTile(
                title: Text(item.toString()),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }
}

/// 生成范围内的随机整数
/// [min] 最小值
/// [max] 最大值
/// 返回 [min, max] 范围内的随机整数
int getRandomInt(int min, int max) {
  Random random = Random();
  return min + random.nextInt(max - min + 1);
}
