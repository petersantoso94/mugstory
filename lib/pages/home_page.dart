import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mugstory/component/card_item.dart';
import 'package:mugstory/constants.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    setState(() {});
  }

  bool showSearchBar = true;

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

  PreferredSizeWidget? buildSearchBar() {
    return showSearchBar ? searchBar.build(context) : null;
  }

  Future<bool> _onWillPop() async {
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
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: buildSearchBar(),
        resizeToAvoidBottomInset: false,
        body: Container(
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              children: [
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
                    child: ResponsiveGridList(
                        desiredItemWidth: cCardWidth,
                        minSpacing: cCardSpacing,
                        children: [
                          1,
                          2,
                          3,
                          4,
                          5,
                          6,
                          7,
                          8,
                          9,
                          10,
                          11,
                          12,
                          13,
                          14,
                          15,
                          16,
                          17,
                          18,
                          19,
                          20
                        ].map((i) {
                          return CardItem();
                        }).toList()),
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
}