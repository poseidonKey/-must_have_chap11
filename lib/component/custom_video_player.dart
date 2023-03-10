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
              // ??? ????????? ???????????? ????????? ????????? ??????
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    // ????????? ??????
                    onPressed: onReversePressed,
                    iconData: Icons.rotate_left,
                  ),
                  CustomIconButton(
                    // ?????? ??????
                    onPressed: onPlayPressed,
                    iconData: videoPlayerController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  CustomIconButton(
                    // ????????? ?????? ??????
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
    // ??? ????????? ?????? ????????? ??? ????????? ??????
    final currentPosition =
        videoPlayerController!.value.position; // ?????? ?????? ?????? ??????

    Duration position = const Duration(); // 0?????? ?????? ?????? ?????????

    if (currentPosition.inSeconds > 3) {
      // ?????? ??????????????? 3????????? ????????? 3??? ??????
      position = currentPosition - const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onForwardPressed() {
    // ??? ????????? ?????? ?????? ????????? ??? ????????? ??????
    final maxPosition = videoPlayerController!.value.duration; // ????????? ??????
    final currentPosition = videoPlayerController!.value.position;

    Duration position = maxPosition; // ????????? ????????? ?????? ?????? ?????????

    // ????????? ???????????? 3?????? ??? ????????? ?????? ????????? ?????? ?????? 3??? ?????????
    if ((maxPosition - const Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onPlayPressed() {
    // ??? ?????? ????????? ????????? ??? ????????? ??????
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
