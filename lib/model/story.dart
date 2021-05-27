import 'package:flutter/foundation.dart';

@immutable
class Story {
  final String content;
  final String title;

  Story({required this.content, required this.title});

  Story.fromJson(Map<String, Object?> json)
      : this(
          content: json['content']! as String,
          title: json['title']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'content': content,
      'title': title,
    };
  }
}
