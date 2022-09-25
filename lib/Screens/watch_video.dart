import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class video_screen extends StatefulWidget {
  final String videoId;
  const video_screen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<video_screen> createState() => _video_screenState();
}

class _video_screenState extends State<video_screen> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.youtube(
          'https://youtu.be/${widget.videoId}',
        ),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: false,
          isLooping: false,
          videoQualityPriority: [1080, 720],
        ))
      ..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerController _controller = YoutubePlayerController(
    //   initialVideoId: widget.videoId,
    //   flags: YoutubePlayerFlags(
    //     autoPlay: false,
    //     mute: false,
    //   ),
    // );

    return MaterialApp(
      title: 'PP Edtech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.black38,
          body: SafeArea(
            child: Center(
              child: PodVideoPlayer(controller: controller),
            ),
          )),
    );
  }
}
