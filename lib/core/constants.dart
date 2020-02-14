import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

import './models/appletModel.dart';
import './models/arrowModel.dart';

class Constants {
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String taskRoute = '/task';
  static const String registerRoute = '/register';

  static Map<Key, Applet> initializeStructure(Map<Key, Applet> structureMap) {
    return structureMap = {
      null: Applet(
          color: null,
          type: '',
          id: '',
          key: null,
          position: Offset(0, 0),
          scale: 1.0,
          childKeys: [],
          childIds: [])
    };
  }

  static Offset initializePositionMap(Offset positionForDrop) {
    return positionForDrop = Offset(0, 0);
  }

  static Map<Key, bool> initializeSelectedMap(Map<Key, Applet> structureMap) {
    Map<Key, bool> tempMap = {};
    structureMap.forEach((Key key, Applet applet) => tempMap[key] = false);
    return tempMap;
  }

  static Map<GlobalKey, List<Arrow>> initializeArrowMap(
      Map<GlobalKey, List<Arrow>> arrowMap) {
    return arrowMap = {
      null: [
        Arrow(
            angle: Angle.fromDegrees(0),
            arrowed: false,
            position: Offset(0, 0),
            size: 0,
            target: null)
      ]
    };
  }

  static ValueNotifier<Matrix4> initializeNotifier(
      ValueNotifier<Matrix4> notifier) {
    return notifier = ValueNotifier(Matrix4.identity());
  }
}
