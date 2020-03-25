import 'package:cloud_firestore/cloud_firestore.dart';
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
  GlobalKey key;
  Offset position;
  double scale;
  double targetScale;
  List<String> childIds;
  Color color;
  String type;
  Size size;
  bool fixed;
  bool selected;
  String content;

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
      this.targetScale,
      this.selected,
      this.content}) {
    selected = false;
  }

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

  getIdFromMap(Map<String, dynamic> snapshot) {}
  Applet.fromMap(DocumentSnapshot snapshot)
      : //key = Key(snapshot['id']) ?? null,
        id = snapshot.documentID == null ? null : snapshot.documentID,
        position = Offset((snapshot.data['positionDx'] as num).toDouble(),
                (snapshot.data['positionDy'] as num).toDouble()) ??
            Offset(null, null),
        color = _getColorFromString(snapshot.data['color']) ?? null,
        scale = (snapshot.data['scale'] as num).toDouble() ?? null,
        childIds =
            _childIdsSnapshotDynamicToList(snapshot.data['childIds']) ?? null,
        type = snapshot.data['type'] ?? null,
        fixed = snapshot.data['fixed'] == "true",
        content = snapshot.data['content'] ?? '';

  //childKeys = _getChildKeys(snapshot['childIds']);

  //childKeys = childKeysFromSnapshotChildIdsToKeys( snapshot) ?? null;

  toJson() {
    return {
      //"key": key.toString(),
      "id": id,
      "content": content,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      "childIds": childIds,
      "type": type,
      "fixed": fixed.toString(),
      "color": color.toString(),
    };
  }
}

class WindowApplet extends Applet {
  String id;
  Color color;
  String title;
  GlobalKey key;
  List<String> childIds;
  Size size;
  Offset position;
  double scale;
  bool fixed;
  bool selected;

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
      : super(scale: scale, type: type, selected: selected, key: key);

  WindowApplet.fromMap(Map snapshot)
      : //key = Key(snapshot['id']) ?? null,

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
  String id;
  Offset position;

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
    this.id,
    key,
    this.size,
    this.position,
    this.scale,
  }) : super(
            size: size,
            key: key,
            position: position,
            scale: scale,
            id: id,
            type: type,
            selected: selected,
            content: content);

  TextApplet.fromMap(Map snapshot)
      : color = _getColorFromString(snapshot['color']) ?? '',
        title = snapshot['title'] ?? '',
        id = snapshot['id'],
        textSize = (snapshot['textSize'] as num).toDouble(),
        content = snapshot['content'] ?? '',
        fixed = snapshot['fixed'] == "true",
        scale = (snapshot['scale'] as num).toDouble() ?? 0,
        size = Size((snapshot['sizeWidth'] as num).toDouble(),
                (snapshot['sizeHeight'] as num).toDouble()) ??
            null,
        position = Offset((snapshot['positionDx'] as num).toDouble(),
                (snapshot['positionDy'] as num).toDouble()) ??
            Offset(null, null);

  toJson() {
    return {
      "id": id,
      "color": color.toString(),
      "title": title,
      "textSize": textSize,
      "content": content,
      "fixed": fixed,
      "type": type,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "scale": scale,
      "positionDx": position.dx,
      "positionDy": position.dy,
    };
  }
}
