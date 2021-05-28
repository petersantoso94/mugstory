import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/model/story.dart';

class StoryItem extends StatelessWidget {
  StoryItem(this.story);
  late final Story story;

  Widget get content {
    return Expanded(
        flex: 12,
        child: Center(
          child: Text(
            story.content,
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
        ));
  }

  Widget buttonChoice(String stringChoice) {
    return Expanded(
      flex: 2,
      child: TextButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
        child: Text(
          stringChoice,
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          content,
          buttonChoice("choice 1"),
          SizedBox(
            height: 20.0,
          ),
          buttonChoice("choice 2"),
        ],
      ),
    );
  }
}
