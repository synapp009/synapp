import 'package:flutter/material.dart';

class Window {
  final Key key;
   Size size;
   Offset position;
   Color color;
   String title;
   bool expanded;
   List childKeys;
   double scale;


  Window(
      {this.key,
      this.size,
      this.position,
      this.color,
      this.title,
      this.expanded,
      this.childKeys,
      this.scale});
}

