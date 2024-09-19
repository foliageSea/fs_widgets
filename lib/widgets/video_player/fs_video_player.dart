import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'fs_video_player_src.dart';

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

  void _handleListener() {
    /// 播放结束
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    if (duration != const Duration(seconds: 0)) {
      if (position == duration) {
        _controller.seekTo(const Duration(seconds: 0));
        widget.onPlayOver?.call();
      }
    }

    /// 播放错误
    final hasError = _controller.value.hasError;
    final errorDescription = _controller.value.errorDescription;
    if (hasError) {
      widget.onError?.call(errorDescription);
    }

    setState(() {});
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
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '视频播放器加载出错了\n${snapshot.error}',
          textAlign: TextAlign.center,
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
          VideoPlayer(_controller),
          if (showControls)
            _ControlsOverlay(
              controller: _controller,
              onClick: widget.onClick,
            ),
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
        return Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: child,
          ),
        );
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final Function? onClick;
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller, this.onClick});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * 0.8,
          height: 95,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            children: <Widget>[
              VideoProgressIndicator(controller, allowScrubbing: true),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.value.position.inSeconds > 5) {
                        controller.seekTo(Duration(
                            seconds: controller.value.position.inSeconds - 5));
                      } else {
                        controller.seekTo(const Duration(seconds: 0));
                      }
                    },
                    icon: const Icon(
                      Icons.replay_5,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: () {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    },
                    icon: controller.value.isPlaying
                        ? const Center(
                            child: Icon(
                              Icons.pause,
                              color: Colors.white,
                              semanticLabel: 'Play',
                              size: iconSize,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              semanticLabel: 'Play',
                              size: iconSize,
                            ),
                          ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: () {
                      controller.seekTo(Duration(
                          seconds: controller.value.position.inSeconds + 5));
                    },
                    icon: const Icon(
                      Icons.forward_5,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
