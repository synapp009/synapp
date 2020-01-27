import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

class Arrow {

  Key target;
  bool arrowed;
  Offset position;
  double size;
  Angle angle;
  Arrow({this.target, this.arrowed, this.position, this.size,this.angle});
}