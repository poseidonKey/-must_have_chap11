import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_have_chap11_vid_player/component/custom_icon_button.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final GestureTapCallback onNewVideoPressed;
  const CustomVideoPlayer(
      {super.key, required this.video, required this.onNewVideoPressed});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  bool showControls = false;
  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.path != widget.video.path) {
      initializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          showControls = !showControls;
        });
      },
      child: AspectRatio(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        child: Stack(children: [
          VideoPlayer(videoPlayerController!),
          if (showControls)
            Container(
              color: Colors.black.withOpacity(.5),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  renderTimeTextFromDuration(
                      videoPlayerController!.value.position),
                  Expanded(
                    child: Slider(
                      // value: 0,
                      value: videoPlayerController!.value.position.inSeconds
                          .toDouble(),
                      onChanged: (double value) {
                        videoPlayerController!
                            .seekTo(Duration(seconds: value.toInt()));
                      },
                      max: videoPlayerController!.value.duration.inSeconds
                          .toDouble(),
                    ),
                  ),
                  renderTimeTextFromDuration(
                      videoPlayerController!.value.duration)
                ],
              ),
            ),
          ),
          if (showControls)
            Align(
              alignment: Alignment.topRight,
              child: CustomIconButton(
                onPressed: widget.onNewVideoPressed,
                iconData: Icons.photo_camera_back,
              ),
            ),
          if (showControls)
            Align(
              // ➋ 동영상 재생관련 아이콘 중앙에 위치
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    // 되감기 버튼
                    onPressed: onReversePressed,
                    iconData: Icons.rotate_left,
                  ),
                  CustomIconButton(
                    // 재생 버튼
                    onPressed: onPlayPressed,
                    iconData: videoPlayerController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  CustomIconButton(
                    // 앞으로 감기 버튼
                    onPressed: onForwardPressed,
                    iconData: Icons.rotate_right,
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
  }

  void onReversePressed() {
    // ➊ 되감기 버튼 눌렀을 때 실행할 함수
    final currentPosition =
        videoPlayerController!.value.position; // 현재 실행 중인 위치

    Duration position = const Duration(); // 0초로 실행 위치 초기화

    if (currentPosition.inSeconds > 3) {
      // 현재 실행위치가 3초보다 길때만 3초 빼기
      position = currentPosition - const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onForwardPressed() {
    // ➋ 앞으로 감기 버튼 눌렀을 때 실행할 함수
    final maxPosition = videoPlayerController!.value.duration; // 동영상 길이
    final currentPosition = videoPlayerController!.value.position;

    Duration position = maxPosition; // 동영상 길이로 실행 위치 초기화

    // 동영상 길이에서 3초를 뺀 값보다 현재 위치가 짧을 때만 3초 더하기
    if ((maxPosition - const Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onPlayPressed() {
    // ➌ 재생 버튼을 눌렀을 때 실행할 함수
    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
    } else {
      videoPlayerController!.play();
    }
  }

  @override
  void dispose() {
    videoPlayerController!.removeListener(videoControllerListener);
    super.dispose();
  }

  void initializeController() async {
    final videoController = VideoPlayerController.file(File(widget.video.path));
    await videoController.initialize();
    videoController.addListener(videoControllerListener);
    setState(() {
      videoPlayerController = videoController;
    });
  }

  void videoControllerListener() {
    setState(() {});
  }

  Widget renderTimeTextFromDuration(Duration duration) {
    return Text(
      "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
      style: const TextStyle(color: Colors.white),
    );
  }
}
