import 'package:flutter/foundation.dart';

@immutable
class Story {
  final String content;
  final String title;
  final String narration;
  final String image;
  final String sound;

  Story({
    required this.content,
    required this.title,
    required this.image,
    required this.narration,
    required this.sound,
  });

  Story.fromJson(Map<String, Object?> json)
      : this(
          content: json['content']! as String,
          title: json['title']! as String,
          image: json['image']! as String,
          narration: json['narration']! as String,
          sound: json['sound']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'content': content,
      'title': title,
      'image': image,
      'narration': narration,
      'sound': sound,
    };
  }
}
