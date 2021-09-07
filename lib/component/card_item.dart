import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mugstory/component/pocket.dart';
import 'package:mugstory/constants.dart';
import 'package:mugstory/model/story.dart';

import '../color_palette.dart';

class CardItem extends StatelessWidget {
  CardItem({required this.storyData});
  Story storyData;
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
                      image: FirebaseImage(
                        storyData.image,
                        shouldCache:
                            true, // The image should be cached (default: True)
                        maxSizeBytes:
                            3000 * 1000, // 3MB max file size (default: 2.5MB)
                        cacheRefreshStrategy: CacheRefreshStrategy
                            .NEVER, // Switch off update checking
                      ),
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
            Pocket(
              title: storyData.title,
              isLiked: true,
              onButtonLikeClicked: (){

              },
            ),
          ],
        ),
      ),
    );
  }
}
