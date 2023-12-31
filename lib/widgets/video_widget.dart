import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final File? file;

  const VideoWidget(this.file);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  Widget? videoStatusAnimation;

  @override
  void initState() {
    super.initState();

    videoStatusAnimation = Container();

    _controller = VideoPlayerController.file(widget.file!)
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        Timer(Duration(milliseconds: 0), () {
          if (!mounted) return;

          setState(() {});
          _controller.setVolume(0.0).then((value) {
            _controller.play();
          });
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: _controller.value.isInitialized ? videoPlayer() : Container(),
      );

  Widget videoPlayer() => SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Stack(
            children: [
              SizedBox(
                width: _controller.value.size
                    .width, //width: _controller.value.size?.width ?? 0,
                //height: _controller.value.size?.height ?? 0,
                height: _controller.value.size.height,
                child: video(),
              ),
              IconButton(
                onPressed: () {
                  if (_controller.value.volume == 1.0) {
                    setState(() {
                      _controller.setVolume(0.0);
                    });
                  } else {
                    setState(() {
                      _controller.setVolume(1.0);
                    });
                  }
                },
                icon: _controller.value.volume == 0.0
                    ? Icon(
                        FontAwesomeIcons.volumeMute,
                        color: Colors.white.withOpacity(0.5),
                        size: 66.3,
                      )
                    : Icon(
                        FontAwesomeIcons.volumeUp,
                        color: Colors.white.withOpacity(0.5),
                        size: 66.3,
                      ),
              ),
            ],
          ),
        ),
      );

  Widget video() => GestureDetector(
        child: VideoPlayer(_controller),
        onDoubleTap: () {
          if (!_controller.value.isInitialized) {
            return;
          }
          if (_controller.value.isPlaying) {
            videoStatusAnimation =
                FadeAnimation(child: const Icon(Icons.pause, size: 33.3));
            _controller.pause();
          } else {
            videoStatusAnimation =
                FadeAnimation(child: const Icon(Icons.play_arrow, size: 33.3));
            _controller.play();
          }
        },
      );
}

class FadeAnimation extends StatefulWidget {
  const FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 1000)});

  final Widget? child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => animationController.isAnimating
      ? Opacity(
          opacity: 1.0 - animationController.value,
          child: widget.child,
        )
      : Container();
}
