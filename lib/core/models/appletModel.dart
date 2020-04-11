import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:synapp/core/models/projectModel.dart';

import '../constants.dart';
import 'arrowModel.dart';

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
  Map<String, Arrow> arrowMap;
  String title;
  double textSize;

  static final Map<String, IconData> iconDataMap = {
    "TextApplet": Icons.text_fields,
    "WindowApplet": Icons.crop_din,
  };

  static final Map<String, String> iconLabelMap = {
    "TextApplet": "Text",
    "WindowApplet": "Box",
  };

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
      this.onChange,
      this.arrowMap,
      this.title,
      this.textSize}) {
    selected = false;
    arrowMap = Constants.initializeArrowMap();
  }

  Applet.fromMap({ Map snapshot})
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
        arrowMap =
            _arrowsFromMap(snapshot),
        selected = false,
        title = snapshot['title'] ?? '',
        textSize = snapshot['textSize'] ?? null;

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
      "textSize": textSize,
      "arrowMap": _arrowMapToJson(arrowMap),
      "onChange": onChange.toString(),
      "title": title.toString(),
    };
  }

  Map<String,dynamic> _arrowMapToJson(Map<String,Arrow> arrowMap) {
    Map<String,dynamic> tempList = {};
    arrowMap?.forEach((id,arrow) => tempList[id] = arrow.toJson());
    return tempList;
  }

  static Map<String,Arrow> _arrowsFromMap(
     dynamic snapshot) {
    Map<String, Arrow> tempMap = {};
    if (snapshot['arrowMap'] != null) {
      snapshot['arrowMap'].forEach(
        (k,v) {
          tempMap[k] = 
            Arrow.fromMap( v);
          
        },
      );
    }

    return tempMap;
  }

  static Color _getColorFromString(String snapshot) {
    Color tempColor;

    if (snapshot != null && !snapshot.contains("null")) {
      String valueString = snapshot.split('Color(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      return tempColor = new Color(value);
    } else {
      return tempColor = null;
    }
  }

  static List<String> _childIdsSnapshotDynamicToList(List<dynamic> snapshot) {
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

  Applet createNewWindow() {
    Key windowKey = new GlobalKey();
    var appletId;
    Color color = new RandomColor().randomColor(
        colorHue: ColorHue.yellow, colorBrightness: ColorBrightness.light);

    return Applet(
        type: 'WindowApplet',
        key: windowKey,
        size: Size(130, 130),
        position: Offset(200, 100),
        color: color,
        title: 'Title',
        childIds: [],
        scale: 0.3,
        selected: false,
        onChange: true,
        arrowMap: {});
  }

  Applet createNewTextBox() {
    return Applet(
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

  void scaleTextBox(
      Project project, int i, String textBoxId, PointerMoveEvent details) {
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
                (project.appletMap[textBoxId].size.height + details.delta.dy >
                        40
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
                (project.appletMap[textBoxId].size.height + details.delta.dy >
                        40
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
                (project.appletMap[textBoxId].size.height - details.delta.dy >
                        40
                    ? (details.delta.dy)
                    : 0));
      }
    } else if (i == 2) {
      project.appletMap[textBoxId].position = Offset(
        project.appletMap[textBoxId].position.dx,
        project.appletMap[textBoxId].position.dy +
            (project.appletMap[textBoxId].position.dy + details.position.dy > 40
                ? (project.appletMap[textBoxId].size.height - details.delta.dy >
                        40
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
    }
  }
}
