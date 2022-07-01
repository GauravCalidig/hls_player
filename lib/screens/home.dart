import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hls_player/model/video.dart';

import 'video_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getVideos();
  }

  Future<String> getJson() {
    return rootBundle.loadString('assets/videos.json');
  }

  getVideos() async {
    String jsonString = await getJson();
    json.decode(jsonString).forEach((v) {
      videos.add(Video.fromJson(v)..totalViews = Random().nextInt(50000));
    });
    setState(() {});
  }

  List<Video> videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/youtube.png", height: 20, width: 90),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.cast,
              )),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
              )),
          IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: const NetworkImage("https://randomuser.me/api/portraits/men/44.jpg"),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          Video video = videos[index];
          return VideoTile(video);
        },
      ),
    );
  }
}
