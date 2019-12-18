import 'package:flutter/material.dart';

import 'window.dart';

class Constants {
  static String HOME_SCREEN = 'HOME_SCREEN';

  static Map<Key, dynamic> initializeStructure(Map<Key, dynamic> structureMap) {
    return structureMap = {
      null: Window(
          key: null,
          size: Size(0, 0),
          position: Offset(0, 0),
          color: null,
          scale: 1,
          childKeys: [])
    };
  }

  static Offset initializePositionMap(Offset positionForDrop) {
    return positionForDrop = Offset(null, null);
  }

  static Map<Key, dynamic> initializeArrowMap(Map<Key, dynamic> arrowMap) {
    return arrowMap = {
      null: Arrow(
        target: null,
        arrowed: true,
        size: Size(0, 0),
      )
    };
  }
}

class Arrow {
  Key target;
  bool arrowed;
  Size size;
  Arrow({this.target, this.arrowed, this.size});
}
