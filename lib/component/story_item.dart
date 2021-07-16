import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/model/choice.dart';

import '../styles.dart';

class StoryItem extends StatelessWidget {
  StoryItem({
    required this.storyContent,
    required this.choicesSnapshot,
    required this.choiceCallback,
    required this.restartCallback,
  });
  final String storyContent;
  final Stream<QuerySnapshot<Choice>> choicesSnapshot;
  final void Function(QueryDocumentSnapshot<Choice> chosenChoice)
      choiceCallback;
  final void Function() restartCallback;

  Widget get content {
    return Expanded(
      flex: 12,
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber.shade100.withAlpha(50),
            boxShadow: [
              Styles().getNeonStyle(Colors.amber.shade50),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              storyContent,
              style: Styles().getStoryContentTextStyle(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonChoice() {
    return StreamBuilder<QuerySnapshot<Choice>>(
        stream: choicesSnapshot,
        builder: (ctx, choiceSnapshot) {
          if (choiceSnapshot.hasData) {
            final data = choiceSnapshot.requireData;
            if (data.docs.isEmpty) {
              return Padding(
                padding: EdgeInsetsDirectional.only(top: 5.0),
                child: TextButton(
                  onPressed: () {
                    restartCallback();
                  },
                  style: Styles().getStoryButtonStyle(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "Restart..",
                      style: Styles().getButtonTextStyle(),
                    ),
                  ),
                ),
              );
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: data.size,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(top: 5.0),
                    child: TextButton(
                      onPressed: () {
                        var selectedDoc = data.docs[i];
                        choiceCallback(selectedDoc);
                      },
                      style: Styles().getStoryButtonStyle(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          data.docs[i].data().caption,
                          style: Styles().getButtonTextStyle(),
                        ),
                      ),
                    ),
                  );
                });
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            content,
            buttonChoice(),
          ],
        ),
      ),
    );
  }
}
