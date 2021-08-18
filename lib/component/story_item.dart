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
  final ScrollController _scrollController = ScrollController();

  Widget get content {
    return Expanded(
      flex: 12,
      child: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber.shade100.withAlpha(90),
            boxShadow: [
              Styles().getNeonStyle(Colors.amber.shade50),
            ],
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
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

  void _scrollContentToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
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
                        _scrollContentToTop();
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
        padding: EdgeInsetsDirectional.all(15.0),
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
