import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

class NetworkPlayerWidget extends StatefulWidget {
  NetworkPlayerWidget({Key? key, required String this.url}) : super(key: key);
  String url;

  @override
  _NetworkPlayerWidgetState createState() => _NetworkPlayerWidgetState();
}

class _NetworkPlayerWidgetState extends State<NetworkPlayerWidget> {
  late VideoPlayerController controller;
  double volume = 0;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.url)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..setVolume(volume)
      ..initialize().then((_) => controller.play());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 2 / 1.5,
          child: controller.value.isInitialized
              ? VideoPlayer(controller)
              : Center(
                  child: Platform.isAndroid
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {
              if (volume == 0) {
                setState(() {
                  volume = 100;
                  controller.setVolume(volume);
                });
              } else {
                setState(() {
                  volume = 0;
                  controller.setVolume(volume);
                });
              }
            },
            icon: Icon(
              volume == 0
                  ? FontAwesomeIcons.volumeMute
                  : FontAwesomeIcons.volumeUp,
            ),
            color: Colors.black.withOpacity(
              0.6,
            ),
          ),
        )
      ],
    );
  }
}
