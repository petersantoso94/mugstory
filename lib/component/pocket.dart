import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color_palette.dart';
import '../constants.dart';

class Pocket extends StatelessWidget {
  Widget smallButton = Container(
    height: cCardHeight / 9,
    decoration: new BoxDecoration(
      color: Color(cTangerine),
      shape: BoxShape.circle,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      height: cCardHeight / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.circular(cCardRadius),
        ),
        color: Color(cYellow),
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     Container(
      //       height: cCardHeight / 6,
      //       decoration: BoxDecoration(
      //         color: Color(cTangerine),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withAlpha(50),
      //             blurRadius: 5.0,
      //             spreadRadius: 5.0,
      //           )
      //         ],
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 10),
      //       child: smallButton,
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 10),
      //       child: smallButton,
      //     ),
      //   ],
      // ),
    );
  }
}
