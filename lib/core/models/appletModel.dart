import 'package:flutter/material.dart';

class Applet {
  Key key;
  Size size;
  Offset position;
  double scale;
  List childKeys;

  Applet({this.key, this.size, this.position, this.scale, this.childKeys});

  Applet.fromMap(Map snapshot, String id)
      : //key = Key(snapshot['key']) ?? '',
        size = Size(snapshot['sizeWidth'], snapshot['sizeHeight']) ?? null,
        position = Offset(snapshot['positionDx'], snapshot['positionDy']) ??
            Offset(null, null),
        scale = snapshot['scale'] ?? null,
        childKeys = snapshot['childKeys'] as List ?? null;

  toJson() {
    return {
      //"key": key.toString(),
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      // "childKeys": childKeys.toList(),
    };
  }
}

class WindowApplet extends Applet {
  Color color;
  String title;
  Key key;
  List childKeys;

  static final IconData iconData = Icons.crop_din;
  static final String label = 'Box';

  WindowApplet({
    this.color,
    this.title,
    childKeys,
    this.key,
    size,
    position,
    scale,
  }) : super(
            childKeys: childKeys, size: size, position: position, scale: scale);


  WindowApplet.fromMap(Map snapshot, String id)
      : // key = Key(snapshot['key']) ?? '',
        color = snapshot['color'] as Color ?? '',
        title = snapshot['title'] ?? '',
        childKeys = snapshot['childKeys'] as List ?? null;
         

 

  toJson() {
    return {
      //"key": key,
      "color": color.toString(),
      "title": title,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      "childKeys": childKeys,
    };
  }
}

class TextApplet extends Applet {
  Color color;
  String title;
  String content;
  bool fixed;
  double textSize;

  static final IconData iconData = Icons.text_fields;
  static final String label = 'Text';

  TextApplet({
    this.color,
    this.title,
    this.textSize,
    this.content,
    this.fixed,
    key,
    size,
    position,
    scale,
  }) : super(key: key, size: size, position: position, scale: scale);

  TextApplet.fromMap(Map snapshot, String id)
      : color = snapshot['color'] as Color ?? '',
        title = snapshot['title'] ?? '',
        textSize = snapshot['textSize'] ?? '',
        content = snapshot['content'] ?? '',
        fixed = snapshot['fixed'] ?? '';

  toJson() {
    return {
      "color": color,
      "title": title,
      "textSize": textSize,
      "content": content,
      "fixed": fixed,
    };
  }
}
