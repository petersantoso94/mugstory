import 'package:flutter/foundation.dart';

@immutable
class Choice {
  final String caption;
  final String content;
  final int level;
  final List<String>? parents;

  Choice(
      {required this.caption,
      required this.content,
      required this.level,
      this.parents});

  Choice.fromJson(Map<String, Object?> json)
      : this(
          content: json['content']! as String,
          caption: json['caption']! as String,
          level: json['level']! as int,
          parents: (json['parents'] as List?)?.cast<String>(),
        );

  Map<String, Object?> toJson() {
    return {
      'content': content,
      'caption': caption,
      'level': level,
      'parents': parents,
    };
  }
}
