import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

import './models/appletModel.dart';
import './models/arrowModel.dart';

class Constants {
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String taskRoute = '/task';
  static const String registerRoute = '/register';

    static Map<String, Applet> initializeAppletMap(Map<String, Applet> appletMap) {
    return appletMap = {
      null: Applet(
          color: null,
          type: '',
          id: '',
          key: null,
          position: Offset(0, 0),
          scale: 1.0,
          childKeys: [],
          childIds: [],
          selected: false)
    };
  }

  static Offset initializePositionMap(Offset positionForDrop) {
    return positionForDrop = Offset(0, 0);
  }

  static Map<String, bool> initializeSelectedMap(Map<String, Applet> structureMap) {
    Map<String, bool> tempMap = {};
    structureMap.forEach((String id, Applet applet) => tempMap[id] = false);
    return tempMap;
  }

  static Map<String, List<Arrow>> initializeArrowMap(
      Map<String, List<Arrow>> arrowMap) {
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
