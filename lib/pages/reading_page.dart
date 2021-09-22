import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mugstory/component/banner_ad.dart';
import 'package:mugstory/component/button_choice.dart';
import 'package:mugstory/component/choice_card.dart';
import 'package:mugstory/model/choice.dart';
import 'package:mugstory/model/story.dart';

import '../ad_helper.dart';
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
  late RewardedAd? _rewardedAd;

  late CollectionReference<Choice> _choiceReference;
  String _currentParent = "";
  int _currentLevel = 1;
  String _storyContent = "";
  bool _restart = false;
  final ScrollController _scrollController = ScrollController();

  // audio
  AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    _createRewardedAd();

    _choiceReference = FirebaseFirestore.instance
        .collection('story')
        .doc(widget.id)
        .collection('choices')
        .withConverter<Choice>(
            fromFirestore: (snapshots, _) => Choice.fromJson(snapshots.data()!),
            toFirestore: (choice, _) => choice.toJson());
    _storyContent = widget.storyData.content;
    _playBackgroundSound();
    super.initState();
  }

  Widget buildStoryContent() {
    var unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return Padding(
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          _storyContent,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: cStoryFontMultiplier * unitHeightValue),
        ),
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

  void _scrollContentToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );
  }

  void _onChoiceChosen(QueryDocumentSnapshot<Choice> chosenChoice) {
    setState(() {
      _currentParent = chosenChoice.id;
      _storyContent = chosenChoice.data().content;
      _currentLevel++;
    });
    _scrollContentToTop();
  }

  void restart() => setState(() {
        _currentLevel = 1;
        _currentParent = "";
        _storyContent = widget.storyData.content;
        _restart = true;
      });

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _createRewardedAd();
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        _playBackgroundSound();

        setState(() {
          _restart = false;
        });
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }

  void showChoiceImage(QueryDocumentSnapshot<Choice> chosenChoice, int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return ChoiceCard(
          imageUrl: chosenChoice.data().image,
          isOdd: (index % 2 != 0),
        );
      },
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }

  Query<Choice> _getChoiceReference() {
    var choiceQuery = _choiceReference.where('level', isEqualTo: _currentLevel);
    if (_currentParent != "")
      choiceQuery = choiceQuery.where('parents', arrayContains: _currentParent);
    return choiceQuery;
  }

  @override
  Widget build(BuildContext context) {
    var choiceQuery = _getChoiceReference();
    if (_restart) {
      _audioPlayer.stop();
      _showRewardedAd();
      return Center(child: Image.asset('images/loading.gif'));
    }
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
        ),
        child: Column(
          children: [
            MBannerAd(),
            Expanded(
              flex: 8,
              child: buildStoryContent(),
            ),
            Expanded(
              flex: 2,
              child: MButtonChoice(
                choiceCallback: showChoiceImage,
                choicesSnapshot: choiceQuery.snapshots(),
                restartCallback: restart,
              ),
            ),
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
