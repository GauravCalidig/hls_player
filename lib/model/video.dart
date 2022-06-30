class Video {
  int id;
  String title;
  String videoUrl;
  String coverPicture;

  Video({required this.id, required this.title, required this.videoUrl, required this.coverPicture});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      coverPicture: json['coverPicture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'coverPicture': coverPicture,
    };
  }
}
