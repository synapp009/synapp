import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:synapp/core/models/projectModel.dart';

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
  bool onChange;

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
      this.content,
      this.onChange}) {
    selected = false;
  }

  Applet.fromMap(Map snapshot)
      : //key = Key(snapshot['id']) ?? null,
        id = snapshot["id"] == "null" ? null : snapshot["id"],
        position = Offset((snapshot['positionDx'] as num).toDouble(),
                (snapshot['positionDy'] as num).toDouble()) ??
            Offset(null, null),
        color = _getColorFromString(snapshot['color']) ?? null,
        scale = (snapshot['scale'] as num).toDouble() ?? null,
        childIds = _childIdsSnapshotDynamicToList(snapshot['childIds']) ?? null,
        type = snapshot['type'] ?? null,
        fixed = snapshot['fixed'] == "true",
        size = Size((snapshot["sizeHeight"] as num).toDouble(),
                (snapshot["sizeWidth"] as num).toDouble()) ??
            null,
        content = snapshot['content'] ?? '',
        onChange = snapshot['onChange'] == 'true' ? true : false,
        selected = false;

  //childKeys = _getChildKeys(snapshot['childIds']);

  //childKeys = childKeysFromSnapshotChildIdsToKeys( snapshot) ?? null;

  toJson() {
    return {
      //"key": key.toString(),
      "id": id,
      "content": content,
      "positionDx": position.dx,
      "positionDy": position.dy,
      "sizeHeight": size.height,
      "sizeWidth": size.width,
      "scale": scale,
      "childIds": childIds,
      "type": type,
      "fixed": fixed.toString(),
      "color": color.toString(),
      "onChange": onChange.toString()
    };
  }
   WindowApplet createNewWindow() {
    Key windowKey = new GlobalKey();
    var appletId;
    Color color = new RandomColor().randomColor(
        colorHue: ColorHue.yellow, colorBrightness: ColorBrightness.light);

    return WindowApplet(
        type: 'WindowApplet',
        key: windowKey,
        size: Size(130, 130),
        position: Offset(200, 100),
        color: color,
        title: 'Title',
        childIds: [],
        scale: 0.3,
        selected: false,
        onChange: true);
  }


  TextApplet createNewTextBox() {
    return TextApplet(
        type: "TextApplet",
        //id: id,
        //key: newAppKey,
        size: Size(100, 60),
        position: Offset(200, 100),
        color: Colors.black,
        title: 'Title',
        content: 'Enter Text\n',
        fixed: false,
        //bool expanded;
        scale: 1.0,
        textSize: 16,
        onChange: true);
  }

   void scaleTextBox(Project project, int i, String textBoxId, PointerMoveEvent details) {
    if (i == 0) {
      project.appletMap[textBoxId].position = Offset(
        project.appletMap[textBoxId].size.width - details.delta.dx > 40
            ? project.appletMap[textBoxId].position.dx + details.delta.dx
            : project.appletMap[textBoxId].position.dx,
        project.appletMap[textBoxId].size.height - details.delta.dy > 40
            ? project.appletMap[textBoxId].position.dy + details.delta.dy
            : project.appletMap[textBoxId].position.dy,
      );
      project.appletMap[textBoxId].size = Size(
        project.appletMap[textBoxId].size.width +
            (project.appletMap[textBoxId].size.width - details.delta.dx > 40
                ? -details.delta.dx
                : 0),
        project.appletMap[textBoxId].size.height +
            (project.appletMap[textBoxId].size.height - details.delta.dy > 40
                ? -details.delta.dy
                : 0),
      );

      // i = 6 or 7
    } else if (i == 6 || i == 7) {
      project.appletMap[textBoxId].position = Offset(
          project.appletMap[textBoxId].position.dx +
              (project.appletMap[textBoxId].size.width - details.delta.dx > 40
                  ? details.delta.dx
                  : 0),
          project.appletMap[textBoxId].position.dy);
      if (i == 6) {
        project.appletMap[textBoxId].size = Size(
            project.appletMap[textBoxId].size.width +
                (project.appletMap[textBoxId].size.width - details.delta.dx > 40
                    ? -details.delta.dx
                    : 0),
            project.appletMap[textBoxId].size.height +
                (project.appletMap[textBoxId].size.height + details.delta.dy > 40
                    ? details.delta.dy
                    : 0));
        //i = 7
      } else if (i == 7) {
        project.appletMap[textBoxId].size = Size(
            project.appletMap[textBoxId].size.width -
                (project.appletMap[textBoxId].size.width - details.delta.dx > 40
                    ? (details.delta.dx)
                    : 0),
            project.appletMap[textBoxId].size.height);
      }
    } else if (i == 1 || i == 5) {
      if (i == 5) {
        project.appletMap[textBoxId].size = Size(
            project.appletMap[textBoxId].size.width,
            project.appletMap[textBoxId].size.height +
                (project.appletMap[textBoxId].size.height + details.delta.dy > 40
                    ? (details.delta.dy)
                    : 0));
      } else if (i == 1) {
        project.appletMap[textBoxId].position = Offset(
          project.appletMap[textBoxId].position.dx,
          project.appletMap[textBoxId].position.dy +
              (project.appletMap[textBoxId].size.height - details.delta.dy > 40
                  ? details.delta.dy
                  : 0),
        );

        project.appletMap[textBoxId].size = Size(
            project.appletMap[textBoxId].size.width,
            project.appletMap[textBoxId].size.height -
                (project.appletMap[textBoxId].size.height - details.delta.dy > 40
                    ? (details.delta.dy)
                    : 0));
      }
    } else if (i == 2) {
      project.appletMap[textBoxId].position = Offset(
        project.appletMap[textBoxId].position.dx,
        project.appletMap[textBoxId].position.dy +
            (project.appletMap[textBoxId].position.dy + details.position.dy > 40
                ? (project.appletMap[textBoxId].size.height - details.delta.dy > 40
                    ? details.delta.dy
                    : 0)
                : 0),
      );
      project.appletMap[textBoxId].size = Size(
        project.appletMap[textBoxId].size.width +
            (project.appletMap[textBoxId].size.width + details.delta.dx > 40
                ? details.delta.dx
                : 0),
        project.appletMap[textBoxId].size.height +
            (project.appletMap[textBoxId].size.height - details.delta.dy > 40
                ? -details.delta.dy
                : 0),
      );
    } else if (i == 3) {
      project.appletMap[textBoxId].size = Size(
          project.appletMap[textBoxId].size.width +
              (project.appletMap[textBoxId].size.width + details.delta.dx > 40
                  ? (details.delta.dx)
                  : 0),
          project.appletMap[textBoxId].size.height);
    } else if (i == 4) {
      project.appletMap[textBoxId].size = Size(
          project.appletMap[textBoxId].size.width +
              (project.appletMap[textBoxId].size.width + details.delta.dx > 40
                  ? details.delta.dx
                  : 0),
          project.appletMap[textBoxId].size.height +
              (project.appletMap[textBoxId].size.height + details.delta.dy > 40
                  ? details.delta.dy
                  : 0));
    }}

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
  bool onChange;

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
      this.onChange,
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
            Offset(null, null),
        onChange = snapshot['onChange'] == 'true' ? true : false;

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
      "onChange": onChange,
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
  bool onChange;

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
    this.onChange,
    type,
    this.id,
    key,
    this.size,
    this.position,
    this.scale,
  }) : super(
            onChange: onChange,
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
            Offset(null, null),
        onChange = snapshot['onChange'] == 'true' ? true : false;

  toJson() {
    return {
      "id": id,
      "onChange": onChange,
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
