import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/model/choice.dart';
import 'package:mugstory/model/story.dart';

class StoryItem extends StatelessWidget {
  StoryItem(this.storySnapshot) {
    this.story = storySnapshot.data();
    choicesCollection = FirebaseFirestore.instance
        .collection('story')
        .doc(storySnapshot.id)
        .collection('choices')
        .withConverter<Choice>(
            fromFirestore: (snapshots, _) => Choice.fromJson(snapshots.data()!),
            toFirestore: (choice, _) => choice.toJson())
        .where('level', isEqualTo: 1)
        .snapshots();
  }
  late final Story story;
  late final QueryDocumentSnapshot<Story> storySnapshot;
  late final choicesCollection;

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

  Widget buttonChoice() {
    return StreamBuilder<QuerySnapshot<Choice>>(
        stream: choicesCollection,
        builder: (ctx, choiceSnapshot) {
          final data = choiceSnapshot.requireData;
          return choiceSnapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: data.size,
                  itemBuilder: (ctx, i) {
                    return TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red)),
                      child: Text(
                        data.docs[i].data().caption,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    );
                  })
              : Center(child: CircularProgressIndicator());
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
