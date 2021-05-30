import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/model/choice.dart';

class StoryItem extends StatelessWidget {
  StoryItem({
    required this.storyContent,
    required this.choicesSnapshot,
    required this.choiceCallback,
    required this.restartCallback,
  }) {}
  final String storyContent;
  final Stream<QuerySnapshot<Choice>> choicesSnapshot;
  final void Function(QueryDocumentSnapshot<Choice> chosenChoice)
      choiceCallback;
  final void Function() restartCallback;

  Widget get content {
    return Expanded(
        flex: 12,
        child: Center(
          child: Text(
            storyContent,
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
        ));
  }

  Widget buttonChoice() {
    return StreamBuilder<QuerySnapshot<Choice>>(
        stream: choicesSnapshot,
        builder: (ctx, choiceSnapshot) {
          if (choiceSnapshot.hasData) {
            final data = choiceSnapshot.requireData;
            if (data.docs.isEmpty) {
              return TextButton(
                onPressed: () {
                  restartCallback();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red)),
                child: Text(
                  "Restart..",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              );
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: data.size,
                itemBuilder: (ctx, i) {
                  return TextButton(
                    onPressed: () {
                      var selectedDoc = data.docs[i];
                      choiceCallback(selectedDoc);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red)),
                    child: Text(
                      data.docs[i].data().caption,
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  );
                });
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[content, buttonChoice()],
      ),
    );
  }
}
