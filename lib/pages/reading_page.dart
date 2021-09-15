import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/component/banner_ad.dart';
import 'package:mugstory/model/choice.dart';
import 'package:mugstory/model/story.dart';

import '../constants.dart';

class ReadingPage extends StatefulWidget {
  final String id;
  final Story storyData;
  const ReadingPage({Key? key, required this.id, required this.storyData})
      : super(key: key);

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  late CollectionReference<Choice> _choiceReference;
  String _currentParent = "";
  int _currentLevel = 1;

  // audio
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioCache _audioCache = AudioCache();
  @override
  void initState() {
    _choiceReference = FirebaseFirestore.instance
        .collection('story')
        .doc(widget.id)
        .collection('choices')
        .withConverter<Choice>(
            fromFirestore: (snapshots, _) => Choice.fromJson(snapshots.data()!),
            toFirestore: (choice, _) => choice.toJson());
    _playBackgroundSound();
    super.initState();
  }

  Widget buildStoryContent() {
    var unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return SingleChildScrollView(
      child: Text(
        widget.storyData.content,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontSize: cTitleFontMultiplier * unitHeightValue),
      ),
    );
  }

  void _playBackgroundSound() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    var downloadUrl =
        await storage.refFromURL(widget.storyData.sound).getDownloadURL();

    int result = await _audioPlayer.play(downloadUrl);
    _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    if (result == 1) {
      // success
      log('playing');
    }
  }

  @override
  Widget build(BuildContext context) {
    var choiceQuery = _choiceReference.where('level', isEqualTo: _currentLevel);
    if (_currentParent != "")
      choiceQuery = choiceQuery.where('parents', arrayContains: _currentParent);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
        ),
        child: Column(
          children: [
            MBannerAd(),
            buildStoryContent(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }
}
