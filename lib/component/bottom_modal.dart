import 'dart:developer';

import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mugstory/model/story.dart';

import '../constants.dart';

class BottomModal extends StatelessWidget {
  const BottomModal({
    Key? key,
    required this.storyData,
    required this.onButtonReadNowTapped,
    required this.id,
    required this.titleController,
  }) : super(key: key);
  final Story storyData;
  final Function(String id, Story storyData) onButtonReadNowTapped;
  final String id;
  final ScrollController titleController;

  @override
  Widget build(BuildContext context) {
    var pocketHeight = MediaQuery.of(context).size.height / 2;
    var unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return FractionallySizedBox(
      alignment: Alignment.topCenter,
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
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
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            height: pocketHeight,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(cCardRadius * 2),
              ),
              color: Theme.of(context).bottomAppBarColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: titleController,
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            storyData.title,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize:
                                        cTitleFontMultiplier * unitHeightValue,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        flex: 7,
                      ),
                      Expanded(
                        child: FittedBox(
                          child: IconButton(
                            color: Theme.of(context).primaryColor,
                            icon: Icon(
                              MdiIcons.heart,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        flex: 2,
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'author | ',
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                fontSize:
                                    cSubtitleFontMultiplier * unitHeightValue,
                              ),
                        ),
                        TextSpan(
                          text: 'by Mugstory-writer',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                fontSize:
                                    cSubtitleFontMultiplier * unitHeightValue,
                              ),
                        )
                      ],
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Text(
                      storyData.narration,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: cBodyFontMultiplier * unitHeightValue,
                          ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .backgroundColor
                                    .withAlpha(70),
                                child: IconButton(
                                  icon: Icon(MdiIcons.bookmark),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    log('bookmarked');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: FittedBox(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(cCardRadius),
                                    ),
                                  ),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                      Size.fromWidth(cButtonReadNowWidth)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () => onButtonReadNowTapped(
                                  id,
                                  storyData,
                                ),
                                child: Text(
                                  'Read now',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
