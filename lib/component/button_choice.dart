import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/model/choice.dart';

import '../constants.dart';
import '../styles.dart';

class MButtonChoice extends StatelessWidget {
  const MButtonChoice({
    Key? key,
    required this.choicesSnapshot,
    required this.restartCallback,
    required this.choiceCallback,
  }) : super(key: key);

  final Stream<QuerySnapshot<Choice>> choicesSnapshot;
  final void Function(QueryDocumentSnapshot<Choice> chosenChoice)
      choiceCallback;
  final void Function() restartCallback;

  @override
  Widget build(BuildContext context) {
    var unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return StreamBuilder<QuerySnapshot<Choice>>(
        stream: choicesSnapshot,
        builder: (ctx, choiceSnapshot) {
          if (choiceSnapshot.hasData) {
            final data = choiceSnapshot.requireData;
            if (data.docs.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: TextButton(
                    onPressed: () {
                      restartCallback();
                    },
                    style: Styles().getStoryButtonStyle(context),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "Restart",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: cStoryFontMultiplier * unitHeightValue,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: false,
                itemCount: data.size,
                itemBuilder: (ctx, i) {
                  return SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: TextButton(
                        onPressed: () {
                          var selectedDoc = data.docs[i];
                          choiceCallback(selectedDoc);
                        },
                        style: Styles().getStoryButtonStyle(context),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            data.docs[i].data().caption,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                  fontSize:
                                      cStoryFontMultiplier * unitHeightValue,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}
