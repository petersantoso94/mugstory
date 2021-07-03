import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Styles {
  BoxShadow getNeonStyle(Color color) {
    return BoxShadow(
      color: color.withAlpha(60),
      blurRadius: 6.0,
      spreadRadius: 0.0,
      offset: Offset(
        0.0,
        3.0,
      ),
    );
  }

  TextStyle getButtonTextStyle() {
    return TextStyle(
      fontFamily: 'StoryTelling',
      fontSize: 30.0,
      color: Colors.teal.shade500,
    );
  }

  TextStyle getStoryContentTextStyle() {
    return TextStyle(
      fontFamily: 'StoryTelling',
      fontSize: 35.0,
      color: Colors.teal.shade800,
    );
  }

  ButtonStyle getStoryButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.amber.shade100),
    );
  }
}
