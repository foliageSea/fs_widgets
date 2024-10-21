import 'dart:io';

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
            VideoPlayerControlsOverlay(
              controller: _controller,
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

class VideoPlayerControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerControlsOverlay({super.key, required this.controller});

  @override
  State<VideoPlayerControlsOverlay> createState() =>
      _VideoPlayerControlsOverlayState();
}

class _VideoPlayerControlsOverlayState
    extends State<VideoPlayerControlsOverlay> {
  static const List<Duration> seekOffsets = <Duration>[
    Duration(seconds: -15),
    Duration(seconds: -10),
    Duration(seconds: -5),
    Duration.zero,
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 15),
  ];
  static const List<double> playbackRates = <double>[
    1.0,
    2.0,
  ];

  bool showControls = false;

  @override
  Widget build(BuildContext context) {
    var controller = widget.controller;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var maxWidth = constraints.maxWidth;
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showControls = !showControls;
                  });
                },
                onDoubleTap: () {},
              ),
            ),
            showControls
                ? Positioned(
                    bottom: 0,
                    child: Container(
                      width: maxWidth * 0.9,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: _buildControls(context, controller),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Column _buildControls(
      BuildContext context, VideoPlayerController controller) {
    return Column(
      children: [
        SizedBox(
            height: 25,
            child: VideoProgressIndicator(widget.controller,
                allowScrubbing: true)),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: widget.controller.value.isPlaying
                  ? const Icon(
                      Icons.pause,
                      color: Colors.white,
                      semanticLabel: 'Pause',
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      semanticLabel: 'Play',
                    ),
              onPressed: () {
                widget.controller.value.isPlaying
                    ? widget.controller.pause()
                    : widget.controller.play();
                setState(() {});
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: PopupMenuButton<Duration>(
                initialValue: controller.value.captionOffset,
                tooltip: 'Caption Offset',
                onSelected: (Duration delay) {
                  controller.seekTo(controller.value.position + delay);
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<Duration>>[
                    for (final Duration offsetDuration in seekOffsets)
                      PopupMenuItem<Duration>(
                        value: offsetDuration,
                        child: Text('${offsetDuration.inSeconds}秒'),
                      )
                  ];
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    // Using less vertical padding as the text is also longer
                    // horizontally, so it feels like it would need more spacing
                    // horizontally (matching the aspect ratio of the video).
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    '跳转',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<double>(
                initialValue: controller.value.playbackSpeed,
                tooltip: 'Playback speed',
                onSelected: (double speed) {
                  controller.setPlaybackSpeed(speed);
                  setState(() {});
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<double>>[
                    for (final double speed in playbackRates)
                      PopupMenuItem<double>(
                        value: speed,
                        child: Text('${speed}x'),
                      )
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    // Using less vertical padding as the text is also longer
                    // horizontally, so it feels like it would need more spacing
                    // horizontally (matching the aspect ratio of the video).
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    '${controller.value.playbackSpeed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.fullscreen,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     eventBus.fire(ToggleSopFullScreen());
            //   },
            // ),
          ],
        ),
      ],
    );
  }
}
