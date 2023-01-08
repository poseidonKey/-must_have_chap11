import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../component/custom_video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  renderVideo() {
    return Center(
      child: CustomVideoPlayer(
          video: video!, onNewVideoPressed: onNewVideoPressed),
    );
  }

  renderEmpty() {
    return Container(
      decoration: getBoxDecoration(),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Logo(
            onTap: onNewVideoPressed,
          ),
          const SizedBox(
            height: 30,
          ),
          _AppName()
        ],
      ),
    );
  }

  BoxDecoration getBoxDecoration() {
    return const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xff2a3a7c), Color(0xff000118)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));
  }

  void onNewVideoPressed() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }
}

class _AppName extends StatelessWidget {
  final textStyle = const TextStyle(
      color: Colors.white, fontSize: 30, fontWeight: FontWeight.w300);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Video",
          style: textStyle,
        ),
        Text(
          "PLAYER",
          style: textStyle.copyWith(fontWeight: FontWeight.w700),
        )
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final GestureTapCallback onTap;

  const _Logo({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, child: Image.asset("asset/img/logo.png"));
  }
}
