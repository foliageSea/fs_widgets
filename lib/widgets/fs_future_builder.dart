import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FsFutureBuilder<T> extends StatefulWidget {
  const FsFutureBuilder({
    super.key,
    this.future,
    required this.build,
  });

  final Future<T>? future;
  final Function(BuildContext context, T data) build;

  @override
  State<FsFutureBuilder> createState() => FsFutureBuilderState<T>();
}

class FsFutureBuilderState<T> extends State<FsFutureBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProgress();
        }

        if (snapshot.hasError) {
          if (snapshot.error is FsFutureBuilderDataEmptyError) {
            final err = snapshot.error as FsFutureBuilderDataEmptyError;
            return _buildEmpty(err);
          }
          return _buildError();
        }

        final data = snapshot.data as T;

        return widget.build(context, data);
      },
    );
  }

  Widget _buildEmpty(FsFutureBuilderDataEmptyError err) {
    if (err.emptyWidget != null) {
      return Center(child: err.emptyWidget!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(err.msg),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    if (Platform.isAndroid) {
      return const Center(child: CircularProgressIndicator());
    } else if (Platform.isIOS) {
      return const Center(child: CupertinoActivityIndicator());
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildError() {
    return GestureDetector(
      onTap: () {},
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
            Text('加载出错了'),
          ],
        ),
      ),
    );
  }
}

class FsFutureBuilderDataEmptyError extends Error {
  final String msg;
  final Widget? emptyWidget;
  FsFutureBuilderDataEmptyError({this.msg = '暂无数据', this.emptyWidget});
}
