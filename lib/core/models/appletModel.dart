import 'package:flutter/material.dart';

class Applet {
  String id;
  Key key;
  Size size;
  Offset position;
  double scale;
  List<Key> childKeys;
  List<String> childIds;
 Color color;
 String type;


  Applet(
      {this.childIds,
      this.key,
      this.size,
      this.position,
      this.scale,
      this.childKeys,
      this.id,
      this.color,
      this.type});

  static List<String> childIdsSnapshotDynamicToList(List<dynamic> snapshot) {
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

  List<Key> childKeysFromSnapshotChildIdsToKeys(
      Map<dynamic, dynamic> snapshot) {}

  Applet.fromMap(Map snapshot)
      : //key = Key(snapshot['key']) ?? '',
        id = snapshot['id'],
        size = Size((snapshot['sizeWidth'] as num).toDouble(), (snapshot['sizeHeight'] as num).toDouble()) ?? null,
        position = Offset((snapshot['positionDx'] as num).toDouble(),( snapshot['positionDy'] as num).toDouble()) ??
            Offset(null, null),
        color= snapshot['color'] ?? null,
        scale = (snapshot['scale'] as num).toDouble() ?? null,
        childIds = childIdsSnapshotDynamicToList(snapshot['childIds']) ?? null,
        type = snapshot['appletType'] ?? null;

  //childKeys = childKeysFromSnapshotChildIdsToKeys( snapshot) ?? null;

  toJson() {
    return {
      //"key": key.toString(),
      "id": id,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "scale": scale,
      "childIds": childIds,
      "appletType": type,
      "color":color,
    };
  }
}

class WindowApplet extends Applet {
  String id;
  Color color;
  String title;
  Key key;
  List<Key> childKeys;
  List<String> childIds;
  //String id;

  static final IconData iconData = Icons.crop_din;
  static final String label = 'Box';
  String type = 'WindowApplet';

  WindowApplet({
    this.color,
    this.title,
    this.key,
    this.id,
    this.childKeys,
    this.childIds,
    size,
    position,
    scale,
    type

  }) : super(
            size: size,
            position: position,
            scale: scale,
            type : type
           );

  WindowApplet.fromMap(Map snapshot, String id)
      : // key = Key(snapshot['key']) ?? '',
        id = snapshot['id'],
        color = snapshot['color'] as Color ?? '',
        title = snapshot['title'] ?? '',
        childIds = snapshot['childIds'] ?? [];

        

  //childKeys = snapshot['childKeys'] ?? [];

  toJson() {
    return {
      //"key": key,
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
    type,
    id,
    key,
    size,
    position,
    scale,
  }) : super(
            key: key,
            size: size,
            position: position,
            scale: scale,
            id: id,
            type : type);

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
