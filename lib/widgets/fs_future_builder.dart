import 'package:flutter/material.dart';

class FsFutureBuilder<T> extends StatefulWidget {
  const FsFutureBuilder({
    super.key,
    required this.future,
    required this.build,
  });

  final Future<T> Function() future;
  final Function(BuildContext context, T data) build;

  @override
  State<FsFutureBuilder> createState() => _FsFutureBuilderState<T>();
}

class _FsFutureBuilderState<T> extends State<FsFutureBuilder<T>> {
  late Future<T> Function() _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProgress();
        }

        if (snapshot.hasError) {
          if (snapshot.error is FsFutureBuilderDataEmptyError) {
            final err = snapshot.error as FsFutureBuilderDataEmptyError;
            return err.emptyWidget ?? Text(err.msg);
          }

          return _buildError();
        }

        final data = snapshot.data as T;

        return widget.build(context, data);
      },
    );
  }

  Widget _buildProgress() => const Center(child: CircularProgressIndicator());

  Widget _buildError() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _future = widget.future;
        });
      },
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
            ),
            SizedBox(
              height: 8,
            ),
            Text('加载出错了, 点击重试'),
          ],
        ),
      ),
    );
  }
}

class FsFutureBuilderDataEmptyError extends Error {
  final String msg;
  final Widget? emptyWidget;
  FsFutureBuilderDataEmptyError({this.msg = '暂无', this.emptyWidget});
}
