import 'package:flutter/material.dart';

class TextBox {
  final Key key;
  Size size;

  Offset position;
  Color color;
  String title;
  String content;
  //bool expanded;
  double scale;
  double textSize;

  static final IconData iconData = Icons.text_fields;
  static final String label = 'Text';

  TextBox(
      {this.key,
      this.size,
      this.position,
      this.color,
      this.title,
      this.scale,
      this.textSize,
      this.content});
}
