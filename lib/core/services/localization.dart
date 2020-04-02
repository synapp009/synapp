import 'package:flutter/material.dart';

class Localization {
  double statusBarHeight;
  
  Localization({statusBarHeight});
  double headerHeight() {
    double appBarHeight = AppBar().preferredSize.height;
    var tempHeight = statusBarHeight + appBarHeight;
    return tempHeight;
  }
}
