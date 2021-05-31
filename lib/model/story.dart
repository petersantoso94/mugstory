import 'package:flutter/foundation.dart';

@immutable
class Story {
  final String content;
  final String title;
  final String image;

  Story({required this.content, required this.title, required this.image});

  Story.fromJson(Map<String, Object?> json)
      : this(
          content: json['content']! as String,
          title: json['title']! as String,
          image: json['image']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'content': content,
      'title': title,
      'image': image,
    };
  }
}
