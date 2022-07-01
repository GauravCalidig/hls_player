import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hls_player/model/video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../utils/duration.dart';
import 'components/play_button.dart';

class VideoTile extends StatefulWidget {
  final Video video;
  const VideoTile(this.video, {Key? key}) : super(key: key);

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  Video get video => widget.video;

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;

  double progressBar1 = 0;
  double progressBar2 = 0;
  double progressBar3 = 0;
  int maxAnimationHeight = 10;
  double animationBarHeight = 5;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(video.videoUrl, videoPlayerOptions: VideoPlayerOptions());
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.addListener(_updateState);

    _updateState();
    log(video.videoUrl);
  }

  void _updateState() {
    if (!mounted) return;

    progressBar1 = math.Random().nextDouble() * maxAnimationHeight;
    progressBar2 = math.Random().nextDouble() * maxAnimationHeight;
    progressBar3 = math.Random().nextDouble() * maxAnimationHeight;

    _latestValue = _controller.value;

    setState(() {});
  }

  @override
  void dispose() {
    // Ensuring disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  bool isVisible = false;

  Widget _wTile() {
    return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: const NetworkImage("https://i.pravatar.cc/300"),
        ),
        title: Text(
          video.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${video.totalViews} Views",
          style: const TextStyle(fontSize: 15),
        ),
        trailing: const Icon(Icons.more_vert));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return VisibilityDetector(
                key: Key(video.id.toString()),
                onVisibilityChanged: (visibilityInfo) {
                  var visiblePercentage = visibilityInfo.visibleFraction * 100;
                  log(visiblePercentage.toString());
                  if (visiblePercentage > 99) {
                    log("Playing video");
                    //  Playing the video if the user is looking at it
                    _controller.play();
                    isVisible = true;
                    if (mounted) {
                      setState(() {});
                    }
                  } else {
                    //Pausing the video if the user is not looking at it
                    _controller.pause();
                    isVisible = false;
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: isVisible
                              ? Stack(
                                  children: [
                                    VideoPlayer(_controller),
                                    Positioned(
                                        left: 10,
                                        bottom: 10,
                                        child: Row(
                                          children: [
                                            _buildPlayPauseButton(),
                                            _buildMuteButton(_controller),
                                          ],
                                        )),
                                    Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Row(
                                          children: [_buildAudioWave(), const SizedBox(width: 10), _buildPosition()],
                                        ))
                                  ],
                                )
                              : Image.network(video.coverPicture, fit: BoxFit.cover)),
                    ),
                    _wTile(),
                    const SizedBox(height: 20)
                  ],
                ),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner and thumbnail url
              return Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Image.network(
                              video.coverPicture,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        _wTile(),
                        const SizedBox(height: 20)
                      ],
                    ),
                  ),
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ],
              );
            }
          }),
    );
  }

  Widget _wAnimationBar(double height) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      duration: const Duration(milliseconds: 500),
      height: height,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(1),
            topRight: Radius.circular(1),
          ),
          color: Colors.white),
      width: animationBarHeight,
    );
  }

  Widget _buildAudioWave() {
    return SizedBox(
      height: double.tryParse(maxAnimationHeight.toString()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _wAnimationBar(progressBar1),
          _wAnimationBar(progressBar2),
          _wAnimationBar(progressBar3),
        ],
      ),
    );
  }

  Widget _buildPosition() {
    final position = _latestValue.position;
    final duration = _latestValue.duration;

    return Container(
      decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: RichText(
        text: TextSpan(
          text: '${formatDuration(position)} ',
          children: <InlineSpan>[
            TextSpan(
              text: '/ ${formatDuration(duration)}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(.75),
                fontWeight: FontWeight.normal,
              ),
            )
          ],
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: ClipRect(
        child: Container(
          // height: barHeight,
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Icon(
            _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        if (!_controller.value.isInitialized) {
          _controller.initialize().then((_) {
            _controller.play();
          });
        } else {
          if (isFinished) {
            _controller.seekTo(Duration.zero);
          }
          _controller.play();
        }
      }
    });
  }

  Widget _buildPlayPauseButton() {
    final bool isFinished = _latestValue.position >= _latestValue.duration;

    return SidePlayButton(
      backgroundColor: Colors.black54,
      iconColor: Colors.white,
      isFinished: isFinished,
      isPlaying: _controller.value.isPlaying,
      show: true,
      onPressed: _playPause,
    );
  }
}
