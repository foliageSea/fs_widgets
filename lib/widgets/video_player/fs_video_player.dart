import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'fs_video_player_src.dart';
import 'video_player_controls_overlay_ext.dart';

typedef FsVideoPlayerOnError = void Function(String? error);

class FsVideoPlayer extends StatefulWidget {
  const FsVideoPlayer({
    super.key,
    required this.src,
    this.onPlayOver,
    this.onError,
    this.onClick,
  });

  final FsVideoPlayerSrc src;
  final Function()? onPlayOver;
  final FsVideoPlayerOnError? onError;
  final Function? onClick;

  @override
  State<FsVideoPlayer> createState() => _FsVideoPlayerState();
}

class _FsVideoPlayerState extends State<FsVideoPlayer> {
  late VideoPlayerController _controller;

  late Future<void> _initializeVideoPlayerFuture;

  bool showControls = false;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.src is FsVideoPlayerFileSrc) {
      _controller = VideoPlayerController.file(File(widget.src.getSrc()));
    } else if (widget.src is FsVideoPlayerUrlSrc) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.src.getSrc()));
    } else {
      _controller = VideoPlayerController.asset(widget.src.getSrc());
    }

    _controller.addListener(_handleListener);
    _controller.setLooping(false);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
  }

  void _handleListener() async {
    var c = _controller;

    if (c.value.isCompleted && c.value.isLooping == false) {
      await c.seekTo(const Duration(seconds: 0));
      await c.pause();
      setState(() {});
      widget.onPlayOver?.call();
    }

    if (c.value.isBuffering) {
      // 视频正在缓冲，显示加载指示器
      setState(() {
        _isLoading = true;
      });
    } else {
      // 视频缓冲完成，隐藏加载指示器
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_handleListener);
    _controller.dispose();
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(AsyncSnapshot<void> snapshot) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.white,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '视频播放器加载出错了\n${snapshot.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    ));
  }

  Widget _buildVideo() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          showControls = !showControls;
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayerControlsOverlayExt(
            controller: _controller,
            child: VideoPlayer(_controller),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        late Widget child;
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = _buildLoading();
        } else if (snapshot.hasError) {
          child = _buildError(snapshot);
        } else {
          child = _buildVideo();
        }
        return Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
