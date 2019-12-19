import 'package:flutter/material.dart';

import 'arrow.dart';
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

static Map<Key,bool> initializeSelectedMap(Map<Key,bool> selectedMap){
  return selectedMap = {null:false};
}

  static Map<Key,List<Arrow>> initializeArrowMap(Map<Key,List<Arrow>> arrowMap) {
    return arrowMap = { null: 
      []
    };
  }
}


