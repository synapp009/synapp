import 'package:angles/angles.dart';
import 'package:flutter/material.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/services/api.dart';

import '../../locator.dart';

class Arrow {
  String target;
  bool arrowed;
  Offset position;
  double size;
  Angle angle;
  Arrow({this.target, this.arrowed, this.position, this.size, this.angle});

  Arrow.fromMap(Map snapshot)
      : target = snapshot["target"],
        arrowed = snapshot["arrowed"] == "true",
        position = Offset((snapshot["positionDx"] as num).toDouble(),
            (snapshot["positionDy"] as num).toDouble()),
        size = (snapshot["size"] as num).toDouble(),
        angle = Angle.fromDegrees((snapshot["angle"] as num).toDouble());

  toJson() {
    return {
      "target": target,
      "arrowed": arrowed.toString(),
      "positionDx": position.dx,
      "positionDy": position.dy,
      "size": size,
      "angle": angle.degrees,
    };
  }



}
