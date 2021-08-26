import 'package:flutter/material.dart';
import 'package:mugstory/color_palette.dart';
import 'package:mugstory/component/card_item.dart';
import 'package:mugstory/constants.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(cTeal)),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
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
    );
  }
}
