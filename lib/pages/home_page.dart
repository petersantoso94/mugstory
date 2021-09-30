import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mugstory/component/banner_ad.dart';
import 'package:mugstory/component/bottom_modal.dart';
import 'package:mugstory/component/card_item.dart';
import 'package:mugstory/constants.dart';
import 'package:mugstory/model/story.dart';
import 'package:mugstory/pages/reading_page.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ads
  late RewardedAd? _rewardedAd;

  late SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    setState(() {});
  }

  bool showSearchBar = true;
  final _titleScrollController = ScrollController();

  //stories
  late Stream<QuerySnapshot<Story>> _stories;
  final _storyCollection = FirebaseFirestore.instance
      .collection(cStoryCollectionName)
      .withConverter<Story>(
          fromFirestore: (snapshots, _) => Story.fromJson(snapshots.data()!),
          toFirestore: (story, _) => story.toJson());

  @override
  void initState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          print("closed");
        });

    _stories = _storyCollection.snapshots();

    super.initState();
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text(cApplicationName),
        actions: [searchBar.getSearchAction(context)]);
  }

  void _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      showSearchBar = false;
    });
  }

  void _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      showSearchBar = true;
    });
  }

  void onSubmitted(String value) {
    setState(() => _scaffoldKey.currentState!
        .showSnackBar(new SnackBar(content: new Text('You wrote $value!'))));
  }

  void onButtonReadNowTapped(String id, Story storyData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: RouteSettings(name: "/read"),
          builder: (context) => ReadingPage(
                id: id,
                storyData: storyData,
              )),
    );
  }

  void onCardTapped(String id, Story storyData) {
    showBarModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => BottomModal(
              storyData: storyData,
              onButtonReadNowTapped: onButtonReadNowTapped,
              id: id,
              titleController: _titleScrollController,
            ));
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (value) => index = value,
      currentIndex: index,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).primaryColor,
      selectedFontSize: 11.5,
      unselectedFontSize: 11.5,
      unselectedItemColor: const Color(0xFF4d4d4d),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeVariantOutline),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeCityOutline),
          label: 'Commute',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.bookmarkOutline),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.plusCircleOutline),
          label: 'Contribute',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.bellOutline),
          label: 'Updates',
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    inspect(ModalRoute.of(context)!.settings.name);
    if (!Navigator.canPop(context) ||
        (ModalRoute.of(context) != null &&
            ModalRoute.of(context)!.settings.name == '/read'))
      return (await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to exit Mugstory?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      ));
    else
      return true;
  }

  Widget buildImageStory(QuerySnapshot<Story> data) {
    return ResponsiveGridList(
        desiredItemWidth: cCardWidth,
        minSpacing: cCardSpacing,
        children: data.docs.map((i) {
          var storyData = i.data();
          return CardItem(
            id: i.id,
            storyData: storyData,
            onCardTapped: onCardTapped,
          );
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              children: [
                AnimatedContainer(
                  height: showSearchBar ? 56.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: searchBar.build(context),
                ),
                MBannerAd(),
                Expanded(
                  flex: 8,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollStartNotification) {
                        _onStartScroll(scrollNotification.metrics);
                      } else if (scrollNotification is ScrollEndNotification) {
                        _onEndScroll(scrollNotification.metrics);
                      }
                      return true;
                    },
                    child: StreamBuilder<QuerySnapshot<Story>>(
                      stream: _stories,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final data = snapshot.requireData;
                        return buildImageStory(data);
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: buildBottomNavigationBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
