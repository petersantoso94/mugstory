import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ads
  late RewardedAd? _rewardedAd;

  // search bar
  late SearchBar searchBar;
  bool showSearchBar = true;
  String _searchText = "";

  // controller
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _titleScrollController = ScrollController();

  //stories
  late Stream<QuerySnapshot<Story>> _stories;
  final _storyCollection = FirebaseFirestore.instance
      .collection(cStoryCollectionName)
      .withConverter<Story>(
          fromFirestore: (snapshots, _) => Story.fromJson(snapshots.data()!),
          toFirestore: (story, _) => story.toJson());

  // bottom bar
  final _bottomBar = [
    cEXPLORE_BAR,
    cBOOKMARK_BAR,
    cCONTRIBUTE_BAR,
    cUPDATE_BAR
  ];
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    setState(() {});
  }

  // bookmark
  List<String> _bookmarks = [];
  bool _isBookmarked = false;

  // Shared preference
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: _onSubmitted,
        clearOnSubmit: false,
        closeOnSubmit: false,
        onCleared: () {
          _onSubmitted("");
        },
        onClosed: () {
          _onSubmitted("");
        });

    _stories = _storyCollection.snapshots();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _bookmarks = (prefs.getStringList(cBookmarkSharedPreferenceKey) ?? []);
      });
    });
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

  void _onSubmitted(String value) {
    _searchText = value;
    setState(() => {});
  }

  void _onButtonReadNowTapped(String id, Story storyData) {
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

  void _onCardTapped(String id, Story storyData) {
    var isBookmarked = _bookmarks.contains(id);
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomModal(
        storyData: storyData,
        onButtonReadNowTapped: _onButtonReadNowTapped,
        onBookmarkTapped: _addBookmarkOnSharedPreference,
        bookmarked: isBookmarked,
        id: id,
        titleController: _titleScrollController,
      ),
    );
  }

  void _addBookmarkOnSharedPreference(String storyId) async {
    final SharedPreferences prefs = await _prefs;
    var isBookmarked = _bookmarks.contains(storyId);
    if (isBookmarked) {
      _bookmarks.remove(storyId);
    } else {
      _bookmarks.add(storyId);
    }
    // remove duplicate
    _bookmarks = [
      ...{..._bookmarks}
    ];
    setState(() {});
    prefs.setStringList(cBookmarkSharedPreferenceKey, _bookmarks);
    Fluttertoast.showToast(
        msg:
            isBookmarked ? cSnackBarTextRemovedBookmark : cSnackBarTextBookmark,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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
          icon: Icon(MdiIcons.bookmarkOutline),
          label: 'Bookmarked',
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

  Iterable<QueryDocumentSnapshot<Story>> filterStories(
      QuerySnapshot<Story> stories) {
    var filteredStories = stories.docs.where((story) =>
        story.data().title.toLowerCase().contains(_searchText.toLowerCase()));
    switch (_bottomBar[_index]) {
      case cBOOKMARK_BAR:
        // if user choose bookmark bar, filter the stories based on the bookmarked stories
        filteredStories =
            filteredStories.where((story) => _bookmarks.contains(story.id));
        break;
    }
    return filteredStories;
  }

  Widget buildImageStory(QuerySnapshot<Story> data) {
    var stories = filterStories(data);
    return ResponsiveGridList(
        desiredItemWidth: cCardWidth,
        minSpacing: cCardSpacing,
        children: stories.map((i) {
          var storyData = i.data();
          return CardItem(
            id: i.id,
            storyData: storyData,
            onCardTapped: _onCardTapped,
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
