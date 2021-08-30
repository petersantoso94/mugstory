import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mugstory/component/pocket.dart';
import 'package:mugstory/constants.dart';

import '../color_palette.dart';

class CardItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: cCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cCardRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cCardRadius),
        ),
        width: cCardWidth,
        height: cCardHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cCardRadius),
                    image: DecorationImage(
                      image: AssetImage('images/spiderman.jpg'),
                      fit: BoxFit.cover,
                    )),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cCardRadius),
                  splashColor: Color(cYellow),
                  onTap: () {
                    print('Card tapped.');
                  },
                ),
              ),
            ),
            Pocket(),
          ],
        ),
      ),
    );
  }
}
