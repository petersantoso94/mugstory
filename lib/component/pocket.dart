import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Pocket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: cCardHeight / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.circular(cCardRadius),
        ),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
