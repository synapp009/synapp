import 'package:flutter/material.dart';

Color _getColorFromString(String snapshot) {
  Color tempColor;

  if (snapshot != null && !snapshot.contains("null")) {
    String valueString = snapshot.split('Color(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    return tempColor = new Color(value);
  } else {
    return tempColor = null;
  }
}

List<String> _childIdsSnapshotDynamicToList(List<dynamic> snapshot) {
  List<String> tempList = [];

  if (snapshot != null) {
    snapshot.forEach(
      (v) => tempList.add(
        v.toString(),
      ),
    );
  } else {
    tempList = [];
  }

  return tempList;
}

class Applet {
   String id;
  Key key;
  Offset position;
  double scale;
  List<String> childIds;
  Color color;
  String type;
  Size size;
  bool fixed;
  bool selected;

  Applet(
      {this.childIds,
      this.key,
      this.position,
      this.scale,
      this.id,
      this.color,
      this.type,
      this.size,
      this.fixed,
      this.selected}){selected = false;key= Key(id);}

  List<Key> _childKeysFromSnapshotChildIdsToKeys(
      Map<dynamic, dynamic> snapshot) {}

  static List<Key> _getChildKeys(List snapshot) {
    List<Key> tempList = [];

    /*  snapshot.forEach((v) {
        Key newKey = new GlobalKey();
        tempList.add(newKey);
      });*/
    return tempList;
  }


  Applet.fromMap(Map snapshot)
      : key = Key(snapshot['id']) ?? null,
        id = snapshot['id'],
        position = Offset((snapshot['positionDx'] as num).toDouble(),
                (snapshot['positionDy'] as num).toDouble()) ??
            Offset(null, null),
        color = _getColorFromString(snapshot['color']) ?? null,
        scale = (snapshot['scale'] as num).toDouble() ?? null,
        childIds = _childIdsSnapshotDynamicToList(snapshot['childIds']) ?? null,
        type = snapshot['type'] ?? null;
        //childKeys = _getChildKeys(snapshot['childIds']);

  //childKeys = childKeysFromSnapshotChildIdsToKeys( snapshot) ?? null;

  toJson() {
    return {
      //"key": key.toString(),
      "id": id,

      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      "childIds": childIds,
      "type": type,
      "color": color.toString(),
    };
  }
}

class WindowApplet extends Applet {
  String id;
  Color color;
  String title;
  Key key;
  List<String> childIds;
  Size size;
  Offset position;
  double scale;
  bool fixed;
  bool selected;

  //String id;

  static final IconData iconData = Icons.crop_din;
  static final String label = 'Box';
  String type = 'WindowApplet';

  WindowApplet(
      {this.color,
      this.title,
      this.key,
      this.id,
      this.childIds,
      this.size,
      this.position,
      this.scale,
      this.fixed,
      this.selected,
      type})
      : super(scale: scale, type: type,selected:selected);

  WindowApplet.fromMap(Map snapshot)
      : key = Key(snapshot['id']) ?? null,

        id = snapshot['id'],
        color = _getColorFromString(snapshot['color']) ?? '',
        title = snapshot['title'] ?? '',
        childIds = _childIdsSnapshotDynamicToList(snapshot['childIds']) ?? [],
        type = snapshot['type'] ?? [],
        scale = (snapshot['scale'] as num).toDouble() ?? null,
        size = Size((snapshot['sizeWidth'] as num).toDouble(),
                (snapshot['sizeHeight'] as num).toDouble()) ??
            null,
        position = Offset((snapshot['positionDx'] as num).toDouble(),
                (snapshot['positionDy'] as num).toDouble()) ??
            Offset(null, null);

  //childKeys = snapshot['childKeys'] ?? [];

  toJson() {
    return {
      //"key": key,
      "type": type,
      "id": id,
      "color": color.toString(),
      "title": title,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      "childIds": childIds,
      //"childKeys": childKeys.toList(),
    };
  }
}

class TextApplet extends Applet {
  Color color;
  String title;
  String content;
  bool fixed;
  double textSize;
  Size size;
  double scale;
  bool selected;

  // String id;

  static final IconData iconData = Icons.text_fields;
  static final String label = 'Text';
  String type = 'TextApplet';

  TextApplet({
    this.color,
    this.title,
    this.textSize,
    this.content,
    this.fixed,
    this.selected,
    type,
    id,
    key,
    this.size,
    position,
    scale,
  }) : super(
            size: size,
            key: key,
            position: position,
            scale: scale,
            id: id,
            type: type,
            selected:selected);

  TextApplet.fromMap(Map snapshot)
      : color = _getColorFromString(snapshot['color']) ?? '',
        title = snapshot['title'] ?? '',
        textSize = snapshot['textSize'] ?? '',
        content = snapshot['content'] ?? '',
        fixed = snapshot['fixed'] ?? '',
        scale = (snapshot['scale'] as num).toDouble() ?? null,
        size = Size((snapshot['sizeWidth'] as num).toDouble(),
                (snapshot['sizeHeight'] as num).toDouble()) ??
            null;

  toJson() {
    return {
      "color": color.toString(),
      "title": title,
      "textSize": textSize,
      "content": content,
      "fixed": fixed,
      "type": type,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "scale" : scale
    };
  }

  
}
