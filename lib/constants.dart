import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

import 'core/models/appletModel.dart';
import 'core/models/arrowModel.dart';

class Constants {
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String taskRoute = '/task';
  static const String registerRoute = '/register';

  static Map<Key, Applet> initializeStructure(Map<Key, Applet> structureMap) {
    return structureMap = {
      null: Applet(
          key: null,
          size: Size(0, 0),
          position: Offset(0, 0),
          scale: 1,
          childKeys: []
          )
    };
  }

  static Offset initializePositionMap(Offset positionForDrop) {
    return positionForDrop = Offset(null, null);
  }

  static Map<Key, bool> initializeSelectedMap(Map<Key, bool> selectedMap) {
    return selectedMap = {null: false};
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
