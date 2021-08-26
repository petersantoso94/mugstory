import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// @dart=2.9
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mugstory/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../ad_helper.dart';
import '../component/shadow_text.dart';
import '../component/story_item.dart';
import '../constants.dart';
import '../model/choice.dart';
import '../model/story.dart';

class StoryPage extends StatefulWidget {
  StoryPage();
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  // ads
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late RewardedAd? _rewardedAd;

  // story
  final _storyCollection = FirebaseFirestore.instance
      .collection(cStoryCollectionName)
      .withConverter<Story>(
          fromFirestore: (snapshots, _) => Story.fromJson(snapshots.data()!),
          toFirestore: (story, _) => story.toJson());
  late Stream<QuerySnapshot<Story>> _stories;
  late CollectionReference<Choice> _choiceReference;
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];

  GlobalKey cardContainerKey = GlobalKey();
  int _chosenId = -1;
  int _currentLevel = 1;
  String _storyContent = "";
  String _currentParent = "";
  bool _swipeToRight = false;
  bool _restart = false;
  bool _isTutorialShowed = false;

  // Shared preference
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _createRewardedAd();
    _createBannerAd();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _stories = _storyCollection.snapshots();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _isTutorialShowed =
            (prefs.getBool(cTutorialSharedPreferenceKey) ?? false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/dark-background.png"),
              fit: BoxFit.cover,
            ),
          ),
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_isBannerAdReady)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    ),
                  ),
                SizedBox(
                  height: 10.0,
                ),
                StreamBuilder<QuerySnapshot<Story>>(
                    stream: _stories,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_restart) {
                        _showRewardedAd();
                        return Center(child: Image.asset('images/loading.gif'));
                      }
                      final data = snapshot.requireData;
                      if (_chosenId > -1 && _swipeToRight) {
                        return buildStoryItem();
                      }
                      Future.delayed(Duration.zero, _showTutorial);
                      return buildImageStory(data);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
          _createBannerAd();
        },
      ),
    );
    _bannerAd.load();
  }

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

  void _setSharedPreferenceForTutorial() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(cTutorialSharedPreferenceKey, true);
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

        setState(() {
          _chosenId = -1;
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

  void _showTutorial() {
    _initTargets();
    if (!_isTutorialShowed) {
      tutorialCoachMark = TutorialCoachMark(
        context,
        targets: targets,
        colorShadow: Colors.teal.shade200,
        textSkip: "Skip",
        paddingFocus: 10,
        opacityShadow: 0.8,
        onFinish: () {
          print("finish");
        },
        onClickTarget: (target) {
          print('onClickTarget: $target');
        },
        onSkip: _setSharedPreferenceForTutorial,
        onClickOverlay: (target) {
          print('onClickOverlay: $target');
        },
      )..show();
      setState(() {
        _isTutorialShowed = true;
        _setSharedPreferenceForTutorial();
      });
    }
  }

  Future<bool> _onWillPop() async {
    String question = isInStorySelection()
        ? 'Do you want to exit Mugstory?'
        : 'Do you want to exit current Story?';
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text(question),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: onConfirmationButtonClicked,
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void onConfirmationButtonClicked() {
    if (isInStorySelection())
      Navigator.of(context).pop(true);
    else {
      Navigator.of(context).pop(false);
      restart();
    }
  }

  bool isInStorySelection() {
    return _chosenId == -1 && !_swipeToRight;
  }

  Widget buildStoryItem() {
    var choiceQuery = _choiceReference.where('level', isEqualTo: _currentLevel);
    if (_currentParent != "")
      choiceQuery = choiceQuery.where('parents', arrayContains: _currentParent);

    return StoryItem(
      storyContent: _storyContent,
      choicesSnapshot: choiceQuery.snapshots(),
      choiceCallback: onChoiceClicked,
      restartCallback: restart,
    );
  }

  Widget buildImageStory(QuerySnapshot<Story> data) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: TinderSwapCard(
        allowVerticalMovement: false,
        orientation: AmassOrientation.BOTTOM,
        totalNum: data.size,
        stackNum: 3,
        swipeEdge: 4.0,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.width * 1.2,
        minWidth: MediaQuery.of(context).size.width * 0.8,
        minHeight: MediaQuery.of(context).size.width * 1,
        cardBuilder: (context, i) {
          var storyData = data.docs[i].data();
          return Card(
            child: Container(
              height: cCardContainerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                boxShadow: [
                  Styles().getNeonStyle(Colors.amber.shade50),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        key: i == 0 ? cardContainerKey : new Key(i.toString()),
                        child: Text(
                          storyData.title,
                          softWrap: true,
                          maxLines: 1,
                          style: Styles().getButtonTextStyle(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Image(
                        fit: BoxFit.cover,
                        image: FirebaseImage(
                          storyData.image,
                          shouldCache:
                              true, // The image should be cached (default: True)
                          maxSizeBytes:
                              3000 * 1000, // 3MB max file size (default: 2.5MB)
                          cacheRefreshStrategy: CacheRefreshStrategy
                              .NEVER, // Switch off update checking
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          );
        },
        cardController: CardController(),
        swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
          /// Get swiping card's alignment
          if (align.x < 0) {
            //Card is LEFT swiping
            setState(() {
              _swipeToRight = false;
            });
          } else if (align.x > 0) {
            //Card is RIGHT swiping
            setState(() {
              _swipeToRight = true;
            });
          }
        },
        swipeCompleteCallback: (CardSwipeOrientation orientation, int i) {
          /// Get orientation & index of swiped card!
          if (_swipeToRight) {
            var storyData = data.docs[i].data();
            setState(() {
              _chosenId = i;
              _storyContent = storyData.content;
              _choiceReference = FirebaseFirestore.instance
                  .collection('story')
                  .doc(data.docs[_chosenId].id)
                  .collection('choices')
                  .withConverter<Choice>(
                      fromFirestore: (snapshots, _) =>
                          Choice.fromJson(snapshots.data()!),
                      toFirestore: (choice, _) => choice.toJson());
            });
          } else if (data.docs.length - 1 == i) {
            debugPrint("ENTER: =====================================");
            setState(() {
              _restart = true;
            });
          }
        },
      ),
    );
  }

  void _initTargets() {
    RenderBox box =
        cardContainerKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "Target 0",
        targetPosition: TargetPosition(
            box.size,
            Offset(position.dx,
                position.dy + (cCardContainerHeight / 2.0) - box.size.height)),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new ShadowText(
                          "Story Cards",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: new ShadowText(
                            "Slide LEFT to skip.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: new ShadowText(
                            "Slide RIGHT to read the story.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void restart() => setState(() {
        _currentLevel = 1;
        _currentParent = "";
        _storyContent = "";
        _chosenId = -1;
        _swipeToRight = false;
        _restart = true;
      });

  void onChoiceClicked(QueryDocumentSnapshot<Choice> chosenChoice) =>
      setState(() {
        _currentParent = chosenChoice.id;
        _storyContent = chosenChoice.data().content;
        _currentLevel++;
      });

  @override
  void dispose() {
    _bannerAd.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
