import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

class Arrow {
  String target;
  bool arrowed;
  Offset position;
  double size;
  Angle angle;
  Arrow({this.target, this.arrowed, this.position, this.size, this.angle});

Arrow.fromMap(Map snapshot) :
    target = snapshot["target"],
    arrowed = snapshot["arrowed"],
    position = Offset(snapshot["positionDx"],snapshot["positionDy"]),
    size = snapshot["size"],
    angle = Angle.fromDegrees((snapshot["angle"]));

  toJson() {
    return {
      "target": target,
      "arrowd": arrowed.toString(),
      "positionDx": position.dx.toString(),
      "positionDy": position.dy.toString(),
      "size": size.toString(),
      "angle": angle.toString(),
    };
  }
}
