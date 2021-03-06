import 'package:flutter/foundation.dart';

@immutable
class Choice {
  final String caption;
  final String content;
  final String? image;
  final String? sound;
  final int level;
  final List<String>? parents;

  Choice(
      {required this.caption,
      required this.content,
      required this.level,
      required this.image,
      required this.sound,
      this.parents});

  Choice.fromJson(Map<String, Object?> json)
      : this(
          content: json['content']! as String,
          caption: json['caption']! as String,
          image: json['image'] as String?,
          sound: json['sound'] as String?,
          level: json['level']! as int,
          parents: (json['parents'] as List?)?.cast<String>(),
        );

  Map<String, Object?> toJson() {
    return {
      'content': content,
      'caption': caption,
      'image': image,
      'sound': sound,
      'level': level,
      'parents': parents,
    };
  }
}
