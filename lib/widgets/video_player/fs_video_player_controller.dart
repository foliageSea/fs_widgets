import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class FsVideoPlayerController extends GetxController {
  FsVideoPlayerController({required this.videoUrl});
  String videoUrl;
  RxBool fullScreen = false.obs;
  RxBool loading = false.obs;
  RxDouble volume = 0.0.obs;
  RxBool showControls = true.obs;
  RxBool playing = false.obs;
  RxBool showPlaySpeed = false.obs;
  RxDouble playerSpeed = 1.0.obs;
  Rx<Duration> currentPosition = Duration.zero.obs;
  Rx<Duration> buffer = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;
  RxBool isBuffering = false.obs;
  RxBool completed = false.obs;

  Timer? hideTimer;
  Timer? playerTimer;

  late VideoPlayerController videoPlayerController;

  void handleTap() {
    if (!showControls.value) {
      hideTimer?.cancel();

      hideTimer = Timer(const Duration(seconds: 4), () {
        showControls.value = false;
        showControls.refresh();
        hideTimer?.cancel();
        hideTimer = null;
      });
    } else {
      hideTimer?.cancel();
    }
    showControls.value = !showControls.value;
    showControls.refresh();
  }

  Future pause() async {
    await videoPlayerController.pause();
    playing.value = false;
    playing.refresh();
  }

  Future play() async {
    await videoPlayerController.play();
    playing.value = true;
    playing.refresh();
  }

  Future seek(Duration duration) async {
    await videoPlayerController.seekTo(duration);
  }

  Future setPlaybackSpeed(double speed) async {
    playerSpeed.value = speed;
    try {
      videoPlayerController.setPlaybackSpeed(speed);
    } catch (_) {}
  }

  void onHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) {
    showControls.value = true;
    showControls.refresh();

    playerTimer?.cancel();

    pause();

    final double scale = 180000 / MediaQuery.sizeOf(context).width;
    currentPosition.value = Duration(
      milliseconds: currentPosition.value.inMilliseconds +
          (details.delta.dx * scale).round(),
    );
    currentPosition.refresh();
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    play();
    seek(currentPosition.value);
  }

  void createVideoController() {
    final ctrl = VideoPlayerController.asset(videoUrl);
    ctrl.initialize().then((_) => {});
    debugPrint('CreateVideoController Success: $videoUrl');
    videoPlayerController = ctrl;
  }

  Timer getPlayerTimer() {
    return Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        playing.value = videoPlayerController.value.isPlaying;
        isBuffering.value = videoPlayerController.value.isBuffering;
        currentPosition.value = videoPlayerController.value.position;
        buffer.value = videoPlayerController.value.buffered.isEmpty
            ? Duration.zero
            : videoPlayerController.value.buffered.first.end;
        duration.value = videoPlayerController.value.duration;
        completed.value = videoPlayerController.value.isCompleted;

        update();
      },
    );
  }
}
