import 'dart:convert';

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
      videos.add(Video.fromJson(v));
    });
    setState(() {});
  }

  List<Video> videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YouTube',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        leading: Image.network("https://www.iconpacks.net/icons/2/free-youtube-logo-icon-2431-thumb.png"),
        titleSpacing: 10,
        backgroundColor: Colors.white,
        actions: const [
          CircleAvatar(
            backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/44.jpg"),
          ),
          SizedBox(
            width: 10,
          )
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
