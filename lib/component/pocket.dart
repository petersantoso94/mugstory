import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../constants.dart';

class Pocket extends StatelessWidget {
  const Pocket(
      {required this.title,
      required this.isLiked,
      required this.onButtonLikeClicked});
  final String title;
  final bool isLiked;
  final Function onButtonLikeClicked;
  @override
  Widget build(BuildContext context) {
    const double pocketHeight = cCardHeight / 3.5;
    return Container(
        height: pocketHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(0),
            bottom: Radius.circular(cCardRadius),
          ),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                child: IconButton(
                  color: Colors.white,
                  icon: isLiked
                      ? Icon(
                          MdiIcons.heart,
                        )
                      : Icon(
                          MdiIcons.heartOutline,
                        ),
                  onPressed: () {},
                ),
              ),
              flex: 2,
            )
          ],
        ));
  }
}
