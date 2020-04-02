import 'dart:math';

import 'package:angles/angles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:synapp/core/services/api.dart';
import 'package:synapp/core/services/localization.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';

import '../../locator.dart';
import '../constants.dart';
import 'appletModel.dart';
import 'arrowModel.dart';

class Project with ChangeNotifier {
  String projectId;
  String name;
  String description;
  String img;
  static String projectIdStatic;
  //Key key;

  //structure Map contains all the provider data of the Applets of a project
  Map<String, Applet> appletMap;

  //contains all the Arrows in a project between the Applets
  Map<String, List<Arrow>> arrowMap;

  //temp List to multi-select Applets by tabbing
  //Map<String, bool> selectedMap;

  ValueNotifier<Matrix4> notifier;

  Api _api = locator<Api>();

  Localization localization;

  Project(
      {this.projectId,
      //this.key,
      this.name,
      this.img,
      this.appletMap,
      this.arrowMap,
      this.description}) {
    projectIdStatic = this.projectId;
    appletMap = Constants.initializeAppletMap();
    arrowMap = Constants.initializeArrowMap(arrowMap);
    positionForDrop = Constants.initializePositionMap(positionForDrop);
    //selectedMap = Constants.initializeSelectedMap(appletMap);
    notifier = Constants.initializeNotifier(notifier);
    stackSize = null;
  }

  Project.fromMap(Map snapshot, String id)
      : projectId = snapshot['id'] ?? '',
        //key = Key(snapshot['key']) ?? null,
        name = snapshot['name'] ?? '',
        img = snapshot['img'] ?? '',
        description = snapshot['description'] ?? '',
        //appletMap = getAppletMap(snapshot['id'], snapshot['appletList']) ?? {},
        arrowMap = getArrowMap(snapshot['arrowMap']) ?? {};

  /*tempMap = appletMap.map((k, v) {
        String tempK = k.toString();
        dynamic tempV = v.toJson();
        Map tempMap;
        return tempMap[tempK] = tempV;
      }),*/

  toJson() {
    /*appletMap.forEach((k, Applet v) => {
            Firestore.instance
                .collection('projects')
                .document(projectId)
                .collection('appletList')
                .document(k)
                .updateData(v.toJson())
          });*/

    Map<String, dynamic> arrowJsonMap = {};
    if (arrowMap != null) {
      if (arrowMap.length > 0) {
        arrowMap.forEach((key, value) {
          var tempList = [];
          value.forEach((element) {
            var tempArrow = element.toJson();
            tempList.add(tempArrow);
          });
          if (key != null) {
            arrowJsonMap[key] = tempList;
          }
        });
      } else {
        arrowJsonMap['null'] = null;
      }
    }

    return {
      "id": projectId,
      "name": name,
      "img": img,
      //"appletList": appletList,
      "arrowMap": arrowJsonMap,
      "description": description
    };
  }

  static bool mapContainsOnChange(Map<String, Applet> map) {
    bool contains = false;
    map.forEach((s, a) => contains = a.onChange ? true : false);
    return contains;
  }

  Project update(Map<String, Applet> updatedAppletMap) {
    if (appletMap == null) {
      appletMap = {};
    }

    if (updatedAppletMap != null) {
      /*updatedAppletMap.forEach(
        (k, v) => print('updated map $k,${v.childIds}'),
      );*/
      updatedAppletMap.forEach((k, v) {
        appletMap.update(k, (a) {
          a.key = (a.key == null ? new GlobalKey() : a.key);
          a.position = (a.position == updatedAppletMap[k].position
                  ? a.position
                  : updatedAppletMap[k].position) ??
              Offset(0, 0);
          a.scale = (a.scale == updatedAppletMap[k].scale
              ? a.scale
              : updatedAppletMap[k].scale);
          a.childIds = (a.childIds == updatedAppletMap[k].childIds
              ? a.childIds
              : updatedAppletMap[k].childIds);
          a.color = (a.color == updatedAppletMap[k].color
              ? a.color
              : updatedAppletMap[k].color);
          a.size = (a.size == updatedAppletMap[k].size
              ? a.size
              : updatedAppletMap[k].size);
          a.fixed = (a.fixed == updatedAppletMap[k].fixed
              ? a.fixed
              : updatedAppletMap[k].fixed);
          a.content = (a.content == updatedAppletMap[k].content
              ? a.content
              : updatedAppletMap[k].content);
          a.onChange = (a.onChange == updatedAppletMap[k].onChange
              ? a.onChange
              : updatedAppletMap[k].onChange);
          return a;
        }, ifAbsent: () {
          var tempApplet = v;
          tempApplet.key = new GlobalKey();
          tempApplet.id = v.id;
          return tempApplet;
        });
      });
    }
    //check qif appletMap is onChange
    int containsOnChange = 0;
    appletMap.forEach((s, a) {
      containsOnChange = a.onChange ? containsOnChange + 1 : containsOnChange;
    });
    if (containsOnChange == 0) {
      notifyListeners();
    }
    return this;
  }

  static Map<String, Applet> getAppletMap(
      String projectId, List<dynamic> snapshot) {
    Map<String, Applet> tempMap = {};

    /*Firestore.instance
        .collection('projects')
        .document(projectId)
        .collection('applets')
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((doc) {
        tempMap[doc.documentID] = Applet.fromMap(doc.data);
      });
    });*/

    //return Project.fromMap(doc.data, doc.documentID);

    snapshot.forEach((dynamic appletDraft) {
      dynamic tempApplet;
      var tempId;
      if (appletDraft.toString().contains('WindowApplet')) {
        tempApplet = WindowApplet.fromMap(appletDraft);
      } else if (appletDraft.toString().contains('TextApplet')) {
        tempApplet = TextApplet.fromMap(appletDraft);
      } else {
        tempApplet = Applet.fromMap(appletDraft);
      }
      tempId = tempApplet.id == "" ? null : tempApplet.id;

      tempMap[tempId] = tempApplet;
    });

    return tempMap;
  }

  static Map<String, List<Arrow>> getArrowMap(Map<dynamic, dynamic> snapshot) {
    Map<String, List<Arrow>> tempMap = {};

    if (!snapshot.toString().contains("null")) {
      snapshot.forEach((key, value) {
        tempMap[key] = [];
        value.forEach((dat) => tempMap[key].add(Arrow.fromMap(dat)));
      });
    }

    return tempMap;
  }

  Matrix4 matrix = Matrix4.identity();

  Size stackSize;
  Offset positionForDrop;
  Offset currentStackPosition = Offset(0, 100);
  Offset currentTargetPosition = Offset(0, 0);
  Offset actualItemToPointerOffset = Offset(0, 0);
  double stackScale = 1.0;
  double statusBarHeight;
  double maxScale;
  Offset maxOffset;
  double scaleChange = 1.0;
  bool textFieldFocus = false;
  bool pointerMoving = false;
  Offset originTextBoxPosition;
  Size originTextBoxSize;

  String originId;
  String targetId;

  Map<Key, List<Key>> hasArrowToKeyMap = {};

  Key actualItemKey;
  GlobalKey backgroundStackKey;
  bool firstItem = true;
  var chosenId;

  Offset stackOffset = Offset(0, 0);
  Offset generalStackOffset = Offset(0, 0);

  String getIdFromKey(Key itemKey) {
    //print('appletmap $appletMap');
    String itemId;
    appletMap.forEach((key, value) {
      if (value.key == (itemKey)) {
        itemId = key;
      }
    });
    //String itemId = appletMap[itemKey].id;
    return itemId;
  }

  void changeItemListPosition(
      {@required String itemId,
      @required String newId,
      @required Applet applet}) {
    //String itemId = getIdFromKey(itemId);
    Key itemKey = getKeyFromId(itemId);
    Key newKey = getKeyFromId(newId);

    appletMap.forEach((String id, Applet v) => {
          if (
          //v.toString().contains('WindowApplet') &&
          v.childIds != null && v.childIds.contains(itemId)
          //&& v.childKeys.contains(itemKey)
          )
            {v.childIds.remove(itemId)}
        });

    if (appletMap[newId].childIds == null) {
      appletMap[newId].childIds = [];
    }

    appletMap[newId].childIds.add(itemId);

    notifyListeners();
  }

  void changeItemScale(key, scale) {
    appletMap[getIdFromKey(key)].scale = scale;
    notifyListeners();
  }

  /* createNewApp(
      type,  GlobalKey newAppKey, BuildContext context) {
    //RenderBox itemBox = itemKey.currentContext.findRenderObject();
    //Offset appPosition = itemBox.globalToLocal(Offset.zero);
    if (type == "WindowApplet") {
      createNewWindow(newAppKey, context);
    } else if (type == 'TextApplet') {
      createNewTextBox(newAppKey, context);
    }
  }*/

  WindowApplet createNewWindow() {
    Key windowKey = new GlobalKey();
    var appletId;
    Color color = new RandomColor().randomColor(
        colorHue: ColorHue.yellow, colorBrightness: ColorBrightness.light);

    /*if (appletMap[null] == null) {
      appletMap[null] = Applet(
        childIds: [id],
      );
    }*/
    //appletMap[null].childIds.add(id);
    // appletMap[id]
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

  List<Key> getChildKeysFromId(List<String> childIds) {
    List<Key> tempList = [];
    childIds.forEach((String id) {
      appletMap.forEach((String appletId, Applet applet) {
        if (applet.id == id) {
          tempList.add(applet.key);
        }
      });
    });
    return tempList;
  }

  Map<Key, Applet> createAppletMap(Project project) {
    Map<Key, Applet> tempMap = {};
    project.appletMap.forEach((String id, Applet applet) {});

    return tempMap;
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
    //notifyListeners();
  }

  void onlySelectThis(String key) {
    appletMap.forEach((k, v) => {
          if (k != key) {v.selected = false}
        });
    notifyListeners();
  }

  Key getActualTargetKey(Key key) {
    var tempId = getIdFromKey(key);
    var targetId;
    appletMap.forEach((k, Applet v) => {
          if (v.type == 'WindowApplet' && v.childIds.contains(tempId))
            {targetId = k}
        });

    return getKeyFromId(targetId);
  }

  String getActualTargetId(String id) {
    String targetId;
    appletMap.forEach((k, Applet v) => {
          if (v.childIds.contains(id)) {targetId = k}
        });

    return targetId;
  }

  double headerHeight() {
    double appBarHeight = AppBar().preferredSize.height;
    var tempHeight = statusBarHeight + appBarHeight;
    return tempHeight;
  }

  double getTargetScale(Key scaleKey) {
    var targetKey = getActualTargetKey(scaleKey);

    var tempScale = appletMap[getIdFromKey(targetKey)].scale;
    return tempScale;
  }

  unselectAll() {
    appletMap.forEach((key, value) {
      value.selected = false;
    });
    notifyListeners();
  }

  void scaleTextBox(int i, String textBoxId, PointerMoveEvent details) {
    if (i == 0) {
      appletMap[textBoxId].position = Offset(
        appletMap[textBoxId].size.width - details.delta.dx > 40
            ? appletMap[textBoxId].position.dx + details.delta.dx
            : appletMap[textBoxId].position.dx,
        appletMap[textBoxId].size.height - details.delta.dy > 40
            ? appletMap[textBoxId].position.dy + details.delta.dy
            : appletMap[textBoxId].position.dy,
      );
      appletMap[textBoxId].size = Size(
        appletMap[textBoxId].size.width +
            (appletMap[textBoxId].size.width - details.delta.dx > 40
                ? -details.delta.dx
                : 0),
        appletMap[textBoxId].size.height +
            (appletMap[textBoxId].size.height - details.delta.dy > 40
                ? -details.delta.dy
                : 0),
      );

      // i = 6 or 7
    } else if (i == 6 || i == 7) {
      appletMap[textBoxId].position = Offset(
          appletMap[textBoxId].position.dx +
              (appletMap[textBoxId].size.width - details.delta.dx > 40
                  ? details.delta.dx
                  : 0),
          appletMap[textBoxId].position.dy);
      if (i == 6) {
        appletMap[textBoxId].size = Size(
            appletMap[textBoxId].size.width +
                (appletMap[textBoxId].size.width - details.delta.dx > 40
                    ? -details.delta.dx
                    : 0),
            appletMap[textBoxId].size.height +
                (appletMap[textBoxId].size.height + details.delta.dy > 40
                    ? details.delta.dy
                    : 0));
        //i = 7
      } else if (i == 7) {
        appletMap[textBoxId].size = Size(
            appletMap[textBoxId].size.width -
                (appletMap[textBoxId].size.width - details.delta.dx > 40
                    ? (details.delta.dx)
                    : 0),
            appletMap[textBoxId].size.height);
      }
    } else if (i == 1 || i == 5) {
      if (i == 5) {
        appletMap[textBoxId].size = Size(
            appletMap[textBoxId].size.width,
            appletMap[textBoxId].size.height +
                (appletMap[textBoxId].size.height + details.delta.dy > 40
                    ? (details.delta.dy)
                    : 0));
      } else if (i == 1) {
        appletMap[textBoxId].position = Offset(
          appletMap[textBoxId].position.dx,
          appletMap[textBoxId].position.dy +
              (appletMap[textBoxId].size.height - details.delta.dy > 40
                  ? details.delta.dy
                  : 0),
        );

        appletMap[textBoxId].size = Size(
            appletMap[textBoxId].size.width,
            appletMap[textBoxId].size.height -
                (appletMap[textBoxId].size.height - details.delta.dy > 40
                    ? (details.delta.dy)
                    : 0));
      }
    } else if (i == 2) {
      appletMap[textBoxId].position = Offset(
        appletMap[textBoxId].position.dx,
        appletMap[textBoxId].position.dy +
            (appletMap[textBoxId].position.dy + details.position.dy > 40
                ? (appletMap[textBoxId].size.height - details.delta.dy > 40
                    ? details.delta.dy
                    : 0)
                : 0),
      );
      appletMap[textBoxId].size = Size(
        appletMap[textBoxId].size.width +
            (appletMap[textBoxId].size.width + details.delta.dx > 40
                ? details.delta.dx
                : 0),
        appletMap[textBoxId].size.height +
            (appletMap[textBoxId].size.height - details.delta.dy > 40
                ? -details.delta.dy
                : 0),
      );
    } else if (i == 3) {
      appletMap[textBoxId].size = Size(
          appletMap[textBoxId].size.width +
              (appletMap[textBoxId].size.width + details.delta.dx > 40
                  ? (details.delta.dx)
                  : 0),
          appletMap[textBoxId].size.height);
    } else if (i == 4) {
      appletMap[textBoxId].size = Size(
          appletMap[textBoxId].size.width +
              (appletMap[textBoxId].size.width + details.delta.dx > 40
                  ? details.delta.dx
                  : 0),
          appletMap[textBoxId].size.height +
              (appletMap[textBoxId].size.height + details.delta.dy > 40
                  ? details.delta.dy
                  : 0));
    }
    notifyListeners();
  }

  Offset getPositionOfRenderBox(GlobalKey targetKey) {
    //with expensive RenderedBox, --> maybe better options?
    Offset tempPosition;

    if (targetKey != null && targetKey.currentContext != null) {
      RenderBox targetRenderObject =
          targetKey.currentContext.findRenderObject();
      tempPosition = targetRenderObject.localToGlobal(Offset.zero);

      currentTargetPosition =
          Offset(tempPosition.dx, tempPosition.dy - headerHeight());
      return tempPosition = currentTargetPosition;
    } else {
      return tempPosition =
          Offset(notifier.value.row0.a, notifier.value.row1.a);
    }
  }

  List<Key> getAllChildren({Key itemKey, Applet applet}) {
    String itemId;
    if (itemKey != null) {
      itemId = getIdFromKey(itemKey);
    } else {
      itemId = applet.id;
    }

    List<Key> tempList = [];
    List<Key> childList = [];
    List<Key> todoList = [];
    List<Key> doneList = [];
    String todoId;
    appletMap[itemId].childIds.forEach((element) {
      todoList.add(getKeyFromId(element));
    });
    while (todoList.length > 0) {
      tempList.clear();
      todoList.forEach((todoKey) => {
            todoId = getIdFromKey(todoKey),
            if (!childList.contains(todoKey))
              {
                childList.add(todoKey),
              },
            doneList.add(todoKey),
            if (appletMap[todoId].type == "WindowApplet")
              {
                appletMap[todoId].childIds.forEach((element) {
                  tempList.add(getKeyFromId(element));
                })
              }
          });

      doneList.forEach((doneKey) => todoList.remove(doneKey));
      todoList.addAll(tempList);
    }
    todoList.clear();

    return childList;
  }

  List<Key> getAllTargets(Key key) {
    List<Key> tempList = [];

    Key tempKey = getActualTargetKey(key);

    while (tempKey != null) {
      tempList.add(tempKey);
      tempKey = getActualTargetKey(tempKey);
    }
    return tempList;
  }

  void addArrow(String key) {
    //adds an Arrow to the list of arrows from origin widget to null
    if (arrowMap[key] == null) {
      arrowMap[key] = [];
    }
    var getPosition = (centerOfRenderBox(key) + stackOffset) / stackScale;
    getPosition =
        Offset(getPosition.dx, getPosition.dy - headerHeight() * stackScale);

    arrowMap[key].add(
      Arrow(
        arrowed: false,
        target: null,
        size: 0.0,
        position: getPosition,
        angle: Angle.fromRadians(0),
      ),
    );
    notifyListeners();
  }

  Offset centerOfRenderBox(String originId) {
    //calculate the Center of a originKey RenderBox
    GlobalKey originKey = getGlobalKeyFromId(originId);
    var centerOfOrigin;
    var tempStackOffset;
    RenderBox originBox = originKey.currentContext.findRenderObject();
    Offset originBoxPosition = originBox.globalToLocal(Offset.zero);
    originBoxPosition = -Offset(originBoxPosition.dx * stackScale,
        originBoxPosition.dy * stackScale + headerHeight());
    Size originBoxSize = originBox.size * stackScale;
    tempStackOffset = stackOffset * stackScale;
    //var originBoxScale = appletMap[originKey].scale;
    //double originBoxScale = appletMap[originKey].scale;
    return centerOfOrigin = Offset(
        (originBoxPosition.dx + (originBoxSize.width / 2)),
        (originBoxPosition.dy + (originBoxSize.height / 2)));
  }

  Angle getAngle(Offset pointA, Offset pointB) {
    double tempAncle =
        (pointB.dy - pointA.dy - headerHeight()) / (pointB.dx - pointA.dx);
    var angle;

    var tempSize = Size(pointA.dx - pointB.dx, pointA.dy - pointB.dy);

    int cartesianCoordinateSector(tempSize) {
      var sector;

      if (tempSize.height > 0 && tempSize.width > 0) {
        //X2

        return sector = 4;
      } else if (tempSize.height < 0 && tempSize.width > 0) {
        //X1

        return sector = 3;
      } else if (tempSize.height > 0 && tempSize.width < 0) {
        //X3

        return sector = 1;
      } else {
        //X4

        return sector = 2;
      }
    }

    if (cartesianCoordinateSector(tempSize) <= 2) {
      angle = Angle.atan(tempAncle);
    } else {
      angle = Angle.atan(tempAncle) + Angle.fromDegrees(180);
    }

    return angle;
  }

  double diagonalLength(Offset pointA, Offset pointB) {
    var tempSize =
        Size((pointA.dx - pointB.dx), (pointA.dy - pointB.dy - headerHeight()));

    var length = ((tempSize.width * tempSize.width) +
        (tempSize.height * tempSize.height));
    return length = sqrt(length);
  }

  void setArrowToPointer(Key startKey, Offset actualPointer) {
    //set the size and ancle of the Arrow between widget and pointer
    //from center of a RenderBox (startKey)
    Arrow arrow;
    String startId = getIdFromKey(startKey);
    arrowMap[startId].forEach((k) => k.target == null ? arrow = k : null);
    var itemScale = appletMap[startId].scale;
    var itemOffset = centerOfRenderBox(startId);

    var length = diagonalLength(
      actualPointer,
      itemOffset,
    );
    if (arrow != null) {
      arrow.position = (itemOffset - stackOffset) / stackScale;
      arrow.size = length / stackScale;
      arrow.angle = getAngle(itemOffset, actualPointer);
    }

    notifyListeners();
  }

  void changeItemDropPosition(
      Applet applet, pointerDownOffset, pointerUpOffset) {
    var itemScale = applet.scale;
    var dropKey = applet.key;
    var id = applet.id;
    var targetKey = getActualTargetKey(dropKey);
    var targetOffset = getPositionOfRenderBox(targetKey);
    var itemHeaderOffset = 0;

    //checks if there is some relevance of additional offset caused by trag helper offset
    if (targetKey != null &&
        appletMap[id].toString().contains('WindowApplet')) {
      itemHeaderOffset = 20;
    }

    appletMap[id].position = Offset(
      ((pointerUpOffset.dx - targetOffset.dx) / itemScale / stackScale -
          pointerDownOffset.dx),
      ((pointerUpOffset.dy - targetOffset.dy - headerHeight()) /
              itemScale /
              stackScale -
          pointerDownOffset.dy),
    );
    updateApplet(applet, targetId, originId);
    notifyListeners();
  }

  Size sizeOfRenderBox(GlobalKey itemKey) {
    if (itemKey.currentContext != null) {
      RenderBox tempBox = itemKey.currentContext.findRenderObject();
      Size tempSize = tempBox.size;
      return tempSize;
    } else {
      return Size(0, 0);
    }
  }

  getEdgeOffset(itemPosition, itemSize, Angle itemAngle) {
    var adjacent;
    var opposite;
    var temp;
    Angle tempAngle;
    adjacent = (itemSize.height / 2) * stackScale;
    if (itemAngle.degrees + 45 < 90 && itemAngle.degrees + 45 > 0) {
      opposite = adjacent * itemAngle.tan;
    } else if (itemAngle.degrees + 45 < 180 && itemAngle.degrees + 45 > 90) {
      tempAngle = itemAngle - Angle.fromDegrees(90);

      opposite = adjacent * tempAngle.tan;
      temp = opposite;
      opposite = adjacent;
      adjacent = -temp;
    } else if (itemAngle.degrees + 45 < 270 && itemAngle.degrees + 45 > 180) {
      tempAngle = itemAngle - Angle.fromDegrees(180);

      opposite = adjacent * tempAngle.tan;
      opposite = -opposite;
      adjacent = -adjacent;
    } else {
      tempAngle = itemAngle + Angle.fromDegrees(270);
      opposite = adjacent * tempAngle.tan;
      temp = adjacent;
      adjacent = opposite;
      opposite = -temp;
    }
    //put some space between arrow and edge
    adjacent = adjacent * 1.1;
    opposite = opposite * 1.1;
    return Offset(adjacent, opposite);
  }

  bool boxHitTest(
      {final Offset itemPosition,
      final Size itemSize,
      Offset targetPosition,
      final Size targetSize}) {
    targetPosition = Offset(0, 0);
    if (((itemPosition.dx > targetPosition.dx &&
                itemPosition.dx < targetPosition.dx + targetSize.width) ||
            (itemPosition.dx + itemSize.width > targetPosition.dx &&
                itemPosition.dx + itemSize.width <
                    targetPosition.dx + targetSize.width)) &&
        ((itemPosition.dy > targetPosition.dy &&
                itemPosition.dy < targetPosition.dy + targetSize.height) ||
            (itemPosition.dy + itemSize.height > targetPosition.dy &&
                itemPosition.dy + itemSize.height <
                    targetPosition.dy + targetSize.height))) {
      return true;
    } else {
      return false;
    }
  }

  updateArrow(
      {final GlobalKey originKey,
      final GlobalKey feedbackKey,
      final GlobalKey targetKey,
      final GlobalKey draggedKey,
      final Map<Key, List<Key>> hasArrowToKeyMap}) {
    Arrow arrow;
    String originId = getIdFromKey(originKey);
    String targetId = getIdFromKey(targetKey);

//get size and arrow of origin and target
    RenderBox originRenderBox = originKey.currentContext.findRenderObject();
    var originPosition = getPositionOfRenderBox(originKey);
    originPosition = Offset(originPosition.dx, originPosition.dy);
    var originSize =
        Size(originRenderBox.size.width, originRenderBox.size.height);
    originPosition = Offset(
      originPosition.dx + (originSize.width / 2) * stackScale,
      originPosition.dy + (originSize.height / 2) * stackScale,
    );

    RenderBox targetRenderBox = targetKey.currentContext.findRenderObject();
    var targetPosition = getPositionOfRenderBox(targetKey);
    targetPosition = Offset(targetPosition.dx, targetPosition.dy);
    var targetSize =
        Size(targetRenderBox.size.width, targetRenderBox.size.height);
    targetPosition = Offset(
      targetPosition.dx + (targetSize.width / 2) * stackScale,
      targetPosition.dy + (targetSize.height / 2) * stackScale,
    );

    var feedbackPosition;
    var feedbackSize;

    var targetEdgeOffset;
    var feedbackEdgeOffset;
    var originEdgeOffset;

//get size and position of feedback when it gets dragged (means feedbackKey is not draggedKey)
    if (feedbackKey != null) {
      RenderBox feedbackRenderBox =
          feedbackKey.currentContext.findRenderObject();
      feedbackSize = (feedbackKey == originKey || feedbackKey == targetKey)
          ? feedbackRenderBox.size
          : feedbackRenderBox.size * 1.1;
      feedbackPosition = getPositionOfRenderBox(feedbackKey);
      feedbackPosition = (Offset(
          feedbackPosition.dx + (feedbackSize.width / 2) * stackScale,
          feedbackPosition.dy + (feedbackSize.height / 2) * stackScale));
    }

//get correct arrow
    arrowMap[originId].forEach((v) => {
          if (v.target == targetId)
            {
              arrow = v,
            }
        });

//check if one (feedback, target or origin) is inside another
//hasArrowToKeyMap.forEach()

    if (draggedKey == originKey) {
      //if origin gets tragged, use feedback as origin
      arrow.angle = getAngle(feedbackPosition,
          Offset(targetPosition.dx, targetPosition.dy + headerHeight()));
      feedbackEdgeOffset =
          getEdgeOffset(feedbackPosition, feedbackSize, arrow.angle);
      targetEdgeOffset = getEdgeOffset(targetPosition, targetSize, arrow.angle);

      arrow.size = diagonalLength(
              Offset(targetPosition.dx - targetEdgeOffset.dx,
                  targetPosition.dy - targetEdgeOffset.dy + headerHeight()),
              feedbackPosition + feedbackEdgeOffset) /
          stackScale;
      arrow.position =
          (feedbackPosition + feedbackEdgeOffset - stackOffset) / stackScale;
    } else if (draggedKey == targetKey) {
      //if target gets tragged, use feedback as target

      arrow.angle = getAngle(
          Offset(originPosition.dx, originPosition.dy - headerHeight()),
          feedbackPosition);

      originEdgeOffset = getEdgeOffset(originPosition, originSize, arrow.angle);
      feedbackEdgeOffset =
          getEdgeOffset(feedbackPosition, feedbackSize, arrow.angle);
      arrow.size = diagonalLength(
              Offset(originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy + originEdgeOffset.dy + headerHeight()),
              feedbackPosition - feedbackEdgeOffset) /
          stackScale;
      arrow.position =
          ((originPosition + originEdgeOffset) - stackOffset) / stackScale;
    } else {
      arrow.angle = getAngle(Offset(originPosition.dx, originPosition.dy),
          Offset(targetPosition.dx, targetPosition.dy + headerHeight()));

      targetEdgeOffset = getEdgeOffset(targetPosition, targetSize, arrow.angle);
      originEdgeOffset = getEdgeOffset(originPosition, originSize, arrow.angle);
      arrow.size = diagonalLength(
              Offset(originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy + originEdgeOffset.dy + headerHeight()),
              targetPosition - targetEdgeOffset) /
          stackScale;
      arrow.position =
          ((originPosition + originEdgeOffset) - stackOffset) / stackScale;
    }
    notifyListeners();
  }

  connectAndUnselect(Key itemKey) {
    String itemId = getIdFromKey(itemKey);
    //connects two widgets with ArrowWidget, unselect all afterwards and delete  arrow if no target
    Offset positionOfTarget;
    String targetId;
    Key targetKey;
    appletMap.forEach((String id, Applet applet) => {
          if (id != itemId && applet.selected == true)
            {
              targetId = id,
              targetKey = applet.key,
              positionOfTarget = centerOfRenderBox(id),
              positionOfTarget = Offset(
                  positionOfTarget.dx, positionOfTarget.dy + headerHeight()),
              setArrowToPointer(itemKey, positionOfTarget),
              applet.selected = false,
              //selectedMap[itemId] = false,
              arrowMap[itemId].forEach((Arrow l) => {
                    if (l.target == null) {l.target = targetId}
                  }),
              updateArrow(originKey: itemKey, targetKey: targetKey)
            }
        });
    for (int i = 0; i < arrowMap[itemId].length; i++) {
      if (arrowMap[itemId][i].target == null) {
        arrowMap[itemId].removeAt(i);
      }
    }

    appletMap.forEach((key, value) {
      value.selected = false;
    });

    notifyListeners();
  }

  Key getKeyFromId(String itemId) {
    Key tempKey;
    appletMap.forEach((key, value) {
      if (value.id == itemId) {
        tempKey = value.key;
      }
    });
    return tempKey;
  }

  GlobalKey getGlobalKeyFromId(String itemId) {
    GlobalKey tempKey;
    appletMap.forEach((key, value) {
      if (value.id == itemId) {
        tempKey = value.key;
      }
    });
    return tempKey;
  }

  void stackSizeChange(GlobalKey objectKey, Offset position) {
    Offset offsetChange;
    var itemSize;
    RenderBox itemBox;
    RenderBox _backgroundStackRenderBox;
    Offset _backgroundStackPosition;
    Size _backgroundStackSize;

    _backgroundStackRenderBox =
        backgroundStackKey.currentContext.findRenderObject();
    _backgroundStackPosition =
        _backgroundStackRenderBox.localToGlobal(Offset.zero) -
            Offset(0, headerHeight());
    _backgroundStackSize = _backgroundStackRenderBox.size;

    print('_backgroundStackPosition $_backgroundStackPosition');

    itemBox = objectKey.currentContext.findRenderObject();
    itemSize = itemBox.size;

    var stackChange = Offset(0, 0);
    print('stackOffset $generalStackOffset');
    print('position $position');
    if (position.dx > _backgroundStackPosition.dx &&
        position.dx <
            _backgroundStackPosition.dx +
                (_backgroundStackSize.width * stackScale) &&
        position.dy > (_backgroundStackPosition.dy) &&
        position.dy <
            _backgroundStackPosition.dy +
                headerHeight()*stackScale +
                (_backgroundStackSize.height*stackScale)) {
      print('inside');
    } else {
      /*
      if (position.dx >
          _backgroundStackPosition.dx +
              _backgroundStackSize.width * stackScale) {
        print('//sector1');
        offsetChange = Offset(
            position.dx -
                _backgroundStackPosition.dx -
                (_backgroundStackSize.width * stackScale) +
                itemSize.width * stackScale,
            0);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        stackSize = Size(
            _backgroundStackSize.width + offsetChange.dx / stackScale,
            _backgroundStackSize.height);
      }
      if (position.dy >
          _backgroundStackPosition.dy +
              headerHeight() +
              _backgroundStackSize.height * stackScale) {
        print('//sector 2');
        offsetChange = Offset(
            0,
            position.dy -
                _backgroundStackPosition.dy -
                (_backgroundStackSize.height - headerHeight() * stackScale) +
                itemSize.height * stackScale);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        stackSize = Size(
            _backgroundStackSize.width,
            (_backgroundStackSize.height + offsetChange.dy) / stackScale -
                (headerHeight() / stackScale));
      }
      if (position.dx < _backgroundStackPosition.dx) {
        print(' //sector 3');

        offsetChange = Offset(
            position.dx -
                _backgroundStackPosition.dx -
                itemSize.width * stackScale,
            0);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        appletMap["parentApplet"].childIds.forEach((k) => {
              appletMap[k].position = Offset(
                  appletMap[k].position.dx - offsetChange.dx / stackScale,
                  appletMap[k].position.dy)
            });
        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            _backgroundStackSize.width - offsetChange.dx / stackScale,
            _backgroundStackSize.height);
      }
print('stackscale $stackScale');
      if (position.dy < _backgroundStackPosition.dy + headerHeight()) {
        print('//sector 4');
        offsetChange = Offset(
            0,
            position.dy -
                _backgroundStackPosition.dy -
                headerHeight() -
                itemSize.height * stackScale);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);

        appletMap["parentApplet"].childIds.forEach((k) => {
              appletMap[k].position = Offset(appletMap[k].position.dx,
                  appletMap[k].position.dy - offsetChange.dy / stackScale)
            });
        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(_backgroundStackSize.width,
            _backgroundStackSize.height - offsetChange.dy / stackScale);
      }
    */
    }
    //update arrows position to the new stack offset
    if (stackChange.dx < 0 || stackChange.dy < 0) {
      stackOffset = stackOffset + stackChange;
    }

    stackChange = -stackChange / stackScale;

    arrowMap.forEach((k, List<Arrow> arrowList) => {
          arrowList.forEach((Arrow arrow) => arrow.position = Offset(
              arrow.position.dx + stackChange.dx,
              arrow.position.dy + stackChange.dy)),
        });
  }

  getAllArrows(Key key) {
    //get all arrows pointing to or coming from the item and also it's children items
    bool keyIsTargetOrOrigin(k) {
      bool _tempBool = false;

      if (arrowMap[k] != null) {
        arrowMap[k].forEach((Arrow a) => {
              if (a.target == k)
                {
                  _tempBool = true,
                }
            });
      }

      arrowMap.forEach(
        ((String originId, List<Arrow> listOfArrows) => {
              listOfArrows.forEach((Arrow a) => {
                    if (a.target == k)
                      {
                        _tempBool = true,
                      }
                  }),
            }),
      );
      return _tempBool;
    }

    //all childItems pointing to or getting targetted
    List childList = getAllChildren(itemKey: key);
    childList.add(key);
    var originKey;
    var childId;
    childList.forEach((childKey) => {
          childId = getIdFromKey(childKey),
          arrowMap.forEach((String originId, List<Arrow> listOfArrows) => {
                originKey = getKeyFromId(originId),
                if (originKey != null)
                  {
                    listOfArrows.forEach((Arrow a) => {
                          if (a.target == childId &&
                              keyIsTargetOrOrigin(childKey))
                            {
                              if (hasArrowToKeyMap[originKey] == null)
                                {
                                  hasArrowToKeyMap[originKey] = [],
                                },
                              hasArrowToKeyMap[originKey].add(childKey),
                            }
                          else
                            {
                              if (a.target != null &&
                                  keyIsTargetOrOrigin(a.target))
                                {
                                  if (hasArrowToKeyMap[originKey] == null)
                                    {
                                      hasArrowToKeyMap[originKey] = [],
                                    },
                                  hasArrowToKeyMap[originKey]
                                      .add(getKeyFromId(a.target)),
                                },
                            },
                        }),
                  }
              })
        });
  }

  updateArrowToKeyMap(Key key, bool dragStarted, Key feedbackKey) {
    hasArrowToKeyMap.forEach((Key originKey, List<Key> listOfTargets) => {
          listOfTargets.forEach((Key targetKey) => {
                if (dragStarted && originKey == key)
                  {
                    updateArrow(
                      originKey: originKey,
                      feedbackKey: feedbackKey,
                      targetKey: targetKey,
                      draggedKey: originKey,
                      hasArrowToKeyMap: hasArrowToKeyMap,
                    )
                  }
                else if (dragStarted && targetKey == key)
                  {
                    updateArrow(
                        originKey: originKey,
                        feedbackKey: feedbackKey,
                        targetKey: targetKey,
                        draggedKey: targetKey,
                        hasArrowToKeyMap: hasArrowToKeyMap)
                  }
                else
                  {
                    updateArrow(
                        originKey: originKey,
                        feedbackKey: feedbackKey,
                        targetKey: targetKey,
                        draggedKey: feedbackKey,
                        hasArrowToKeyMap: hasArrowToKeyMap)
                  }
              })
        });
    notifyListeners();
  }

  zoomToBox(selectedKey, context) {
    //zoom display to select doubletap box and offset to left start

    Matrix4 matrix = Matrix4.identity();
    Size displaySize = MediaQuery.of(context).size;
    var itemSize = sizeOfRenderBox(selectedKey);

    var newScale = displaySize.width / itemSize.width;
    var itemPosition = getPositionOfRenderBox(selectedKey);

    //update Scale
    notifier.value.setEntry(0, 0, newScale);
    notifier.value.setEntry(1, 1, newScale);
    //notifier.value.scale(newScale);

    itemPosition = (((itemPosition - stackOffset) * newScale) / stackScale);

    //update Offset
    notifier.value.setEntry(0, 3, -itemPosition.dx);
    notifier.value.setEntry(1, 3, -itemPosition.dy);
    notifyListeners();
  }

  childrenAreSelected(Key key) {
    var childrenList = getAllChildren(itemKey: key);
    var isSelected = false;

    childrenList.forEach((element) {
      if (appletMap[getIdFromKey(element)].selected == true) {
        isSelected = true;
      }
    });

    return isSelected;
  }

  hitTest(key, position, context) {
    //checks if position of a context layes in a box and gives out the key of the box
    //and select it

    Size displaySize = MediaQuery.of(context).size;

    Map<Key, Offset> renderBoxesOffset = {};
    List<Key> targetList = [];

    //store all widgets in view into the list
    List<Key> widgetsInView = [];
    Offset itemKeyPosition;
    Offset tempPosition = position;
    Size itemKeySize;
    String idFromKey;

    appletMap.forEach((String itemId, Applet widget) => {
          itemKeyPosition = getPositionOfRenderBox(widget.key),
          itemKeySize = widget.size,
          if (itemId != null)
            {
              if (boxHitTest(
                  itemPosition: itemKeyPosition,
                  itemSize: itemKeySize,
                  targetPosition: stackOffset,
                  targetSize: displaySize))
                {widgetsInView.add(getKeyFromId(itemId))}
            },
        });

    //hit Test for items laying in the widgetsInView
    widgetsInView.forEach((k) => {
          renderBoxesOffset[k] = getPositionOfRenderBox(k),
          idFromKey = getIdFromKey(k),
          if ((tempPosition.dx > renderBoxesOffset[k].dx &&
                  tempPosition.dx <
                      renderBoxesOffset[k].dx +
                          appletMap[idFromKey].size.width *
                              appletMap[idFromKey].scale *
                              stackScale &&
                  (tempPosition.dy - headerHeight()) >
                      renderBoxesOffset[k].dy &&
                  tempPosition.dy - headerHeight() <
                      renderBoxesOffset[k].dy +
                          appletMap[idFromKey].size.height *
                              stackScale *
                              appletMap[idFromKey].scale) &&
              !childrenAreSelected(k))
            {
              appletMap[idFromKey].selected = true,
            }
          else
            {
              k != key
                  ? appletMap[idFromKey].selected = false
                  : appletMap[idFromKey].selected = true
            }
        });
  }

  void updateApplet(Applet applet, String targetId, String originId) {
    //update origin applet
    if (originId != null) {
      _api.updateApplet(projectId, appletMap[originId].toJson(), originId);
    }

    //update target applet
    if (targetId != null) {
      _api.updateApplet(projectId, appletMap[targetId].toJson(), targetId);
    }

    //update applet
    _api.updateApplet(projectId, applet.toJson(), applet.id);

    //update all childs of applet
    List<String> childrenIds =
        getAllChildren(applet: applet).map((f) => getIdFromKey(f)).toList();

    if (childrenIds.length > 0) {
      childrenIds.forEach((f) {
        Applet tempChildApplet = appletMap[f];
        _api.updateApplet(
            projectId, tempChildApplet.toJson(), tempChildApplet.id);
      });
    }

    //notifyListeners();
  }

  Future addApplet(String projectId, Applet data) async {
    await _api.addApplet(projectId, data.toJson());
    return;
  }

  Stream<QuerySnapshot> fetchAppletsAsQueryStream(String projectId) {
    return _api.streamAppletCollection(projectId);
  }

  Stream<Map<String, Applet>> fetchAppletsAsStream() {
    print('fetchAppletsAsStream');
    var doc = _api.streamAppletCollection(projectId);
    return doc.map((QuerySnapshot value) =>
        {for (var v in value.documents) v.documentID: Applet.fromMap(v.data)});
  }

  Stream<Map<String, Applet>> fetchAppletsChangesAsStream() {
    Stream<QuerySnapshot> doc = _api.streamAppletCollection(projectId);

    return doc.map((QuerySnapshot value) {
      return {
        for (var v in value.documentChanges)
          v.document.documentID: Applet.fromMap(v.document.data)
      };
    });
  }

  Future<List<Applet>> getAppletsById(String id) async {
    List<Applet> list = new List();
    var doc = await _api.getAppletById(id);
    doc.forEach((DocumentSnapshot docSnapshot) {
      list.add(Applet.fromMap(docSnapshot.data));
    });
    /*map((DocumentSnapshot docSnapshot) {
     
       Applet.fromMap(docSnapshot);
    }).toList();*/
    return list;
  }

  Future<String> createNewAppandReturnId(
      String type, Key newAppKey, BuildContext context) async {
    //RenderBox itemBox = itemKey.currentContext.findRenderObject();
    //Offset appPosition = itemBox.globalToLocal(Offset.zero);
    String appletId;

    Applet newApplet = new Applet();
    if (type == "WindowApplet") {
      newApplet = createNewWindow();
    } else if (type == 'TextApplet') {
      newApplet = createNewTextBox();
    }

    var data = newApplet.toJson();
    DocumentReference doc = await Firestore.instance
        .collection("projects")
        .document(projectId)
        .collection("applets")
        .add(data);

    var id = doc.documentID;
    var tempData = data;
    tempData["id"] = id;

    Firestore.instance
        .collection("projects")
        .document(projectId)
        .collection("applets")
        .document(id)
        .updateData(tempData);

    /*
    if (type == "WindowApplet") {
      id = createNewWindow(newAppKey, context);
    } else if (type == 'TextApplet') {
      createNewTextBox(newAppKey, context);
    }
    print('id inside provier $id');*/
    return id;
  }
}
