import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControlsOverlayExt extends StatefulWidget {
  final VideoPlayerController controller;
  final Widget child;
  final bool useControls;

  const VideoPlayerControlsOverlayExt({
    super.key,
    required this.controller,
    required this.child,
    this.useControls = true,
  });

  @override
  State<VideoPlayerControlsOverlayExt> createState() =>
      _VideoPlayerControlsOverlayExtState();
}

class _VideoPlayerControlsOverlayExtState
    extends State<VideoPlayerControlsOverlayExt> {
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

        return GestureDetector(
          onTap: () {
            setState(() {
              showControls = !showControls;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              widget.child,
              if (widget.useControls)
                _buildShowControls(maxWidth, context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShowControls(
      double maxWidth, BuildContext context, VideoPlayerController controller) {
    return showControls
        ? Positioned(
            bottom: 40,
            child: Container(
              width: maxWidth * 0.9,
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: _buildControls(context, controller),
            ),
          )
        : Container();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  Column _buildControls(
      BuildContext context, VideoPlayerController controller) {
    return Column(
      children: [
        _buildProgressIndicator(),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLeftControls(controller),
            _buildRightControls(controller),
            // _buildFullScreenButton(),
          ],
        ),
      ],
    );
  }

  SizedBox _buildProgressIndicator() {
    var videoProgressColors = VideoProgressColors(
      playedColor: Theme.of(context).primaryColor,
      bufferedColor: Theme.of(context).primaryColor.withOpacity(0.3),
    );

    return SizedBox(
      height: 25,
      child: VideoProgressIndicator(
        widget.controller,
        allowScrubbing: true,
        colors: videoProgressColors,
      ),
    );
  }

  Row _buildRightControls(VideoPlayerController controller) {
    return Row(
      children: [
        _buildJumpAction(controller),
        _buildSpeedAction(controller),
      ],
    );
  }

  Align _buildSpeedAction(VideoPlayerController controller) {
    return Align(
      alignment: Alignment.topRight,
      child: PopupMenuButton<double>(
        initialValue: controller.value.playbackSpeed,
        tooltip: '',
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
    );
  }

  Align _buildJumpAction(VideoPlayerController controller) {
    return Align(
      alignment: Alignment.topLeft,
      child: PopupMenuButton<Duration>(
        initialValue: controller.value.captionOffset,
        tooltip: '',
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
    );
  }

  Row _buildLeftControls(VideoPlayerController controller) {
    return Row(
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
        if (controller.value.isInitialized)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
