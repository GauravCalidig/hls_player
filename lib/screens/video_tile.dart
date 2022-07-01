import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hls_player/model/video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(video.videoUrl, videoPlayerOptions: VideoPlayerOptions());
    _initializeVideoPlayerFuture = _controller.initialize();
    log(video.videoUrl);
  }

  @override
  void dispose() {
    // Ensuring disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  bool isVisible = false;

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
                          child:
                              //  isVisible
                              //     ?
                              VideoPlayer(_controller)),
                      // :
                      //  Image.network(video.coverPicture, fit: BoxFit.cover)),
                    ),
                    ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                        ),
                        title: Text(video.title),
                        trailing: const Icon(Icons.more_vert)),
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
                        ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                            ),
                            title: Text(video.title),
                            trailing: const Icon(Icons.more_vert)),
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
}
