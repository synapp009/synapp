import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

import './models/appletModel.dart';
import './models/arrowModel.dart';

class Constants {
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String taskRoute = '/task';
  static const String registerRoute = '/register';

    static Map<String, Applet> initializeAppletMap() {
      var tempMap;
    return tempMap = {
      null: Applet(
          color: null,
          type: '',
          id: 'null‚',
          key: null,
          position: Offset(0, 0),
          scale: 1.0,
          childIds: [],
          arrowMap: {},
          selected: false)
    };
  }

static Map<String,Arrow> initializeArrowMap(){
  Map<String,Arrow> tempMap = {};
  return tempMap;
}


  static Applet initializeApplet(){
   return Applet(
          color: null,
          type: '',
          id: 'parentApplet',
          key: null,
          position: Offset(0, 0),
          scale: 1.0,
          size: Size(10,10),
          childIds: [],
          selected: false,
          arrowMap: {});
  }

  static Offset initializePositionMap(Offset positionForDrop) {
    return positionForDrop = Offset(0, 0);
  }

  static Map<String, bool> initializeSelectedMap(Map<String, Applet> structureMap) {
    Map<String, bool> tempMap = {};
    structureMap.forEach((String id, Applet applet) => tempMap[id] = false);
    return tempMap;
  }
  static ValueNotifier<Matrix4> initializeNotifier(
      Matrix4 initialMatrix) {
    return ValueNotifier(initialMatrix);
  }
}
