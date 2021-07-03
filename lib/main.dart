import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
// @dart=2.9
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'component/story_item.dart';
import 'constants.dart';
import 'model/choice.dart';
import 'model/story.dart';

Future<InitializationStatus> _initGoogleMobileAds() {
  // TODO: Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  await _initGoogleMobileAds();
  runApp(Mugstory());
}

class Mugstory extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoryPage(),
    );
  }
}

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
  bool _isRewardedAdReady = false;

  // story
  final _storyCollection = FirebaseFirestore.instance
      .collection(storyCollectionName)
      .withConverter<Story>(
          fromFirestore: (snapshots, _) => Story.fromJson(snapshots.data()!),
          toFirestore: (story, _) => story.toJson());
  late Stream<QuerySnapshot<Story>> _stories;
  late CollectionReference<Choice> _choiceReference;
  int _chosenId = -1;
  int _currentLevel = 1;
  String _storyContent = "";
  String _currentParent = "";
  bool _swipeToRight = false;
  bool _restart = false;

  @override
  void initState() {
    _createRewardedAd();
    _createBannerAd();
    _stories = _storyCollection.snapshots();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 15.0),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_isBannerAdReady)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
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
                    return buildImageStory(data);
                  }),
            ],
          ),
        ),
      ),
    );
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
      height: MediaQuery.of(context).size.height * 0.7,
      child: TinderSwapCard(
        allowVerticalMovement: false,
        orientation: AmassOrientation.BOTTOM,
        totalNum: data.size,
        stackNum: 3,
        swipeEdge: 4.0,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.width * 0.9,
        minWidth: MediaQuery.of(context).size.width * 0.8,
        minHeight: MediaQuery.of(context).size.width * 0.8,
        cardBuilder: (context, i) {
          var storyData = data.docs[i].data();
          return Card(
            child: Container(
              height: 300,
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          storyData.title,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
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
    // TODO: Dispose a BannerAd object
    _bannerAd.dispose();

    super.dispose();
  }
}
