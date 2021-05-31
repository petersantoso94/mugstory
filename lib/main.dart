import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  //storage
  final firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref();

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

  @override
  void initState() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: AdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();

    _stories = _storyCollection.snapshots();
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
                    final data = snapshot.requireData;
                    if (_chosenId > -1) {
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
    return Expanded(
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        crossAxisCount: 2,
        children: List.generate(
          data.size,
          (i) {
            var storyData = data.docs[i].data();
            var imageData = storageRef.child(storyData.image).getDownloadURL();
            return Stack(children: <Widget>[
              TextButton(
                onPressed: () {
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
                },
                child: FutureBuilder(
                  future: imageData,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.8),
                                    BlendMode.dstATop),
                                image: NetworkImage(
                                  snapshot.requireData,
                                ),
                              ),
                            ),
                          );
                    }
                  },
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  storyData.title,
                  style: TextStyle(
                    backgroundColor: Colors.blue.shade900,
                    color: Colors.white,
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  void restart() => setState(() {
        _currentLevel = 1;
        _currentParent = "";
        _storyContent = "";
        _chosenId = -1;
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
