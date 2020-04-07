import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:synapp/core/services/api.dart';
import 'package:synapp/core/services/localization.dart';

import 'package:vector_math/vector_math_64.dart' as vector64;

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
  Applet _applet = locator<Applet>();
  Arrow _arrow = locator<Arrow>();
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
    notifier = Constants.initializeNotifier(notifier.value);
    stackSize = null;
  }

  Project.fromMap(Map snapshot, String id)
      : projectId = snapshot['id'] ?? '',
        //key = Key(snapshot['key']) ?? null,
        name = snapshot['name'] ?? '',
        img = snapshot['img'] ?? '',
        description = snapshot['description'] ?? '',
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

  Size stackSize;
  Offset positionForDrop;
  Offset currentTargetPosition = Offset(0, 0);
  double stackScale = 1.0;
  double statusBarHeight;
  double maxScale;

  double scaleChange = 1.0;
  bool textFieldFocus = false;
  bool pointerMoving = false;
  Offset originTextBoxPosition;
  Size originTextBoxSize;
  Size displaySize;
  bool initial = true;

  String originId;
  String targetId;

  Map<Key, List<Key>> hasArrowToKeyMap = {};

  Key actualItemKey;
  GlobalKey backgroundStackKey;
  bool firstItem = true;
  var chosenId;

  Offset stackOffset = Offset(0, 0);

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

//avoid to select applets under the most upper
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
    _applet.scaleTextBox(this, i, textBoxId, details);
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

  void addArrow(String key) {
    //adds an Arrow to the list of arrows from origin widget to null

    _arrow.addArrow(key, this);

    notifyListeners();
  }

  void setArrowToPointer(Key startKey, Offset actualPointer) {
    //set the size and ancle of the Arrow between widget and pointer
    //from center of a RenderBox (startKey)
    _arrow.setArrowToPointer(startKey, actualPointer, this);

    notifyListeners();
  }

  updateArrow(
      {final GlobalKey originKey,
      final GlobalKey feedbackKey,
      final GlobalKey targetKey,
      final GlobalKey draggedKey,
      final Map<Key, List<Key>> hasArrowToKeyMap}) {
    _arrow.updateArrow(
        project: this,
        originKey: originKey,
        feedbackKey: feedbackKey,
        targetKey: targetKey,
        draggedKey: draggedKey,
        hasArrowToKeyMap: hasArrowToKeyMap);

    notifyListeners();
  }

  connectAndUnselect(Key itemKey) {
    _arrow.connectAndUnselect(this, itemKey);

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

  void stackSizeChange(GlobalKey appletKey, GlobalKey feedbackKey,
      Offset pointerUpOffset, Offset pointerDownOffset) {
    var targetOffset = Offset(0, 0);
    var objectItemId = getIdFromKey(appletKey);

    var itemScale = appletMap[objectItemId].scale;

    var positionOfItem = Offset(
      ((pointerUpOffset.dx - targetOffset.dx) / itemScale / stackScale -
          pointerDownOffset.dx),
      ((pointerUpOffset.dy - targetOffset.dy - headerHeight()) /
              itemScale /
              stackScale -
          pointerDownOffset.dy),
    );

    var itemSize;
    RenderBox itemBox;
    RenderBox _backgroundStackRenderBox;
    Offset _backgroundStackPosition;
    Size _backgroundStackSize;
    print('backgroundStackKey $backgroundStackKey');
    _backgroundStackRenderBox =
        backgroundStackKey.currentContext.findRenderObject();
    _backgroundStackPosition =
        (_backgroundStackRenderBox.localToGlobal(Offset.zero) -
                Offset(0, headerHeight())) /
            stackScale;
    _backgroundStackSize = _backgroundStackRenderBox.size;

    itemBox = feedbackKey.currentContext.findRenderObject();
    itemSize = itemBox.size;
    var stackChange = Offset(0, 0);
    var offsetChange = Offset(0, 0);
    if (positionOfItem.dx > _backgroundStackPosition.dx &&
        positionOfItem.dx <
            _backgroundStackPosition.dx +
                (_backgroundStackSize.width) -
                itemSize.width &&
        positionOfItem.dy > (_backgroundStackPosition.dy) &&
        positionOfItem.dy <
            _backgroundStackPosition.dy +
                (_backgroundStackSize.height) -
                itemSize.height) {
    } else {
      var tempOffsetChangeOne;
      var tempOffsetChangeTwo;

      if (positionOfItem.dx >
          _backgroundStackPosition.dx +
              _backgroundStackSize.width -
              itemSize.width) {
        //sector1
        offsetChange = Offset(
            positionOfItem.dx -
                _backgroundStackPosition.dx -
                (_backgroundStackSize.width) +
                itemSize.width,
            0);
        stackChange = Offset(stackChange.dx + offsetChange.dx, stackChange.dy);
        stackSize = Size(_backgroundStackSize.width + offsetChange.dx,
            _backgroundStackSize.height);
      }

      if (positionOfItem.dy >
          _backgroundStackPosition.dy +
              _backgroundStackSize.height -
              itemSize.height) {
        //sector 2');

        offsetChange = Offset(
            offsetChange.dx,
            positionOfItem.dy -
                _backgroundStackPosition.dy -
                (_backgroundStackSize.height - headerHeight()) +
                itemSize.height);
        tempOffsetChangeOne = offsetChange;
        stackChange = Offset(
            stackChange.dx, stackChange.dy + offsetChange.dy / stackScale);
        stackSize = Size(_backgroundStackSize.width + offsetChange.dx,
            (_backgroundStackSize.height + offsetChange.dy) - (headerHeight()));
      }
      if (positionOfItem.dx < _backgroundStackPosition.dx) {
        //sector 3

        offsetChange = Offset(
                positionOfItem.dx - _backgroundStackPosition.dx,
                positionOfItem.dy >
                        _backgroundStackPosition.dy +
                            _backgroundStackSize.height -
                            itemSize.height
                    ? offsetChange.dy -
                        (positionOfItem.dy -
                            _backgroundStackPosition.dy -
                            (_backgroundStackSize.height - headerHeight()) +
                            itemSize.height)
                    : offsetChange.dy) *
            stackScale;
        tempOffsetChangeTwo = offsetChange;
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);

        appletMap["parentApplet"].childIds.forEach((k) => {
              appletMap[k].position = Offset(
                  appletMap[k].position.dx - offsetChange.dx / stackScale,
                  appletMap[k].position.dy - offsetChange.dy / stackScale)
            });
        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            _backgroundStackSize.width - offsetChange.dx / stackScale,
            _backgroundStackSize.height +
                offsetChange.dy -
                headerHeight() +
                (positionOfItem.dy >
                        _backgroundStackPosition.dy +
                            _backgroundStackSize.height -
                            itemSize.height
                    ? tempOffsetChangeOne.dy
                    : 0));
      }

      if (positionOfItem.dy < _backgroundStackPosition.dy) {
        //sector 4

        offsetChange = Offset(offsetChange.dx,
                positionOfItem.dy - _backgroundStackPosition.dy) *
            stackScale;
        stackChange = Offset(
            stackChange.dx, stackChange.dy + offsetChange.dy / stackScale);

        appletMap["parentApplet"].childIds.forEach((k) => {
              appletMap[k].position = Offset(appletMap[k].position.dx,
                  appletMap[k].position.dy - offsetChange.dy / stackScale)
            });
        notifier.value.setEntry(0, 3, notifier.value.row0.a);
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            _backgroundStackSize.width +
                (positionOfItem.dx < _backgroundStackPosition.dx
                        ? (-1) * offsetChange.dx + tempOffsetChangeTwo.dx * (-1)
                        : offsetChange.dx / stackScale) /
                    stackScale,
            _backgroundStackSize.height - offsetChange.dy / stackScale);
      }
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
    _arrow.getAllArrows(this, key);
  }

  updateArrowToKeyMap(Key key, bool dragStarted, Key feedbackKey) {
    _arrow.updateArrowToKeyMap(this, key, dragStarted, feedbackKey);
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
  }

  Future addApplet(String projectId, Applet data) async {
    await _api.addApplet(projectId, data.toJson());
    return;
  }

  Stream<QuerySnapshot> fetchAppletsAsQueryStream(String projectId) {
    return _api.streamAppletCollection(projectId);
  }

  Stream<Map<String, Applet>> fetchAppletsAsStream() {
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
      newApplet = _applet.createNewWindow();
    } else if (type == 'TextApplet') {
      newApplet = _applet.createNewTextBox();
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
    */
    return id;
  }

  //get the outer keys
  List<GlobalKey> getOuterKeysAsList(List<GlobalKey> keyAtBottomList) {
    GlobalKey mostLeftKey;
    GlobalKey mostRightKey;
    GlobalKey mostTopKey;
    GlobalKey mostBottomKey;

    mostBottomKey =
        mostLeftKey = mostRightKey = mostTopKey = keyAtBottomList[0];

    for (int i = 0; i < keyAtBottomList.length; i++) {
      //getting most right key
      if ((appletMap[getIdFromKey(keyAtBottomList[i])].position.dx +
              appletMap[getIdFromKey(keyAtBottomList[i])].size.width) >
          (appletMap[getIdFromKey(mostRightKey)].position.dx +
              appletMap[getIdFromKey(mostRightKey)].size.width)) {
        mostRightKey = keyAtBottomList[i];
      }

//getting most left key
      if (appletMap[getIdFromKey(keyAtBottomList[i])].position.dx <
          appletMap[getIdFromKey(mostLeftKey)].position.dx) {
        mostLeftKey = keyAtBottomList[i];
      }

//getting most top key
      if ((appletMap[getIdFromKey(keyAtBottomList[i])].position.dy) <
          appletMap[getIdFromKey(mostTopKey)].position.dy) {
        mostTopKey = keyAtBottomList[i];
      }

//getting most bottom key
      if ((appletMap[getIdFromKey(keyAtBottomList[i])].position.dy +
              appletMap[getIdFromKey(keyAtBottomList[i])].size.height) >
          appletMap[getIdFromKey(mostTopKey)].position.dy +
              appletMap[getIdFromKey(mostTopKey)].size.height) {
        mostBottomKey = keyAtBottomList[i];
      }
    }
    return [mostRightKey, mostBottomKey, mostLeftKey, mostTopKey];
  }

  List<double> getMaxOffset(List<Key> getOuterKeysAsList) {
    var mostRightKey = getOuterKeysAsList[0];
    var mostBottomKey = getOuterKeysAsList[1];
    var mostLeftKey = getOuterKeysAsList[2];
    var mostTopKey = getOuterKeysAsList[3];

    var maxLeftOffset;
    var maxRightOffset;
    var maxTopOffset;
    var maxBottomOffset;

    maxLeftOffset =
        appletMap[getIdFromKey(mostLeftKey)].position.dx * stackScale;

    maxRightOffset = appletMap[getIdFromKey(mostRightKey)].position.dx;

    maxTopOffset = appletMap[getIdFromKey(mostTopKey)].position.dy * stackScale;

    maxBottomOffset =
        appletMap[getIdFromKey(mostBottomKey)].position.dy * stackScale;

    return [maxRightOffset, maxBottomOffset, maxLeftOffset, maxTopOffset];
  }

  //set scroll barrier
  void setMaxOffset(List<Key> getOuterKeysAsList) {
    List<double> maxOffset = getMaxOffset(getOuterKeysAsList);

    var maxRightOffset = maxOffset[0];
    var maxBottomOffset = maxOffset[1];
    var maxLeftOffset = maxOffset[2];
    var maxTopOffset = maxOffset[3];

    var mostRightKey = getOuterKeysAsList[0];
    var mostBottomKey = getOuterKeysAsList[1];
    var mostLeftKey = getOuterKeysAsList[2];
    var mostTopKey = getOuterKeysAsList[3];

//left offset barrier
    if (stackOffset.dx > -maxLeftOffset + displaySize.width / 2) {
      notifier.value.setEntry(0, 3, -maxLeftOffset + displaySize.width / 2);
    }

    if ((stackOffset.dx +
            appletMap[getIdFromKey(mostRightKey)].position.dx * stackScale +
            appletMap[getIdFromKey(mostRightKey)].size.width * stackScale) <
        displaySize.width / 2) {
      var tempOffsetRightDx =
          -(appletMap[getIdFromKey(mostRightKey)].position.dx * stackScale +
              appletMap[getIdFromKey(mostRightKey)].size.width * stackScale -
              displaySize.width / (1.99));
      notifier.value.setEntry(0, 3, tempOffsetRightDx);
    }

//top offset barrier
    if (stackOffset.dy > -maxTopOffset + displaySize.height / 2) {
      notifier.value.setEntry(1, 3, -maxTopOffset + displaySize.height / 2);
    }

//top bottom barrier
    if (stackOffset.dy < -maxBottomOffset) {
      notifier.value.setEntry(1, 3, -maxBottomOffset);
    }
  }

  //set max scale
  double getMaxScale(List<Key> getOuterKeysAsList) {
    //set here the scale rate property you want
    var scaleRate = 0.9;
    var maxScale;
    var maxScaleWidth;
    var maxScaleHeight;
    //List<double> maxOffset = getMaxOffset(getOuterKeysAsList);

    var mostRightKey = getOuterKeysAsList[0];
    // var mostBottomKey = getOuterKeysAsList[1];
    var mostLeftKey = getOuterKeysAsList[2];
    //var mostTopKey = getOuterKeysAsList[3];

    maxScaleWidth = (displaySize.width /
        (appletMap[getIdFromKey(mostLeftKey)].position.dx +
            appletMap[getIdFromKey(mostRightKey)].position.dx +
            appletMap[getIdFromKey(mostRightKey)].size.width));

    maxScaleHeight = (displaySize.height /
        (appletMap[getIdFromKey(mostLeftKey)].position.dy +
            appletMap[getIdFromKey(mostRightKey)].position.dy +
            appletMap[getIdFromKey(mostRightKey)].size.height +
            headerHeight()));

    return maxScale =
        (maxScaleHeight < maxScaleWidth ? maxScaleHeight : maxScaleWidth) *
            scaleRate;
  }

  setMaxScaleAndOffset(context) {
    List<GlobalKey> keyAtBottomList = appletMap["parentApplet"]
        .childIds
        .map((e) => getGlobalKeyFromId(e))
        .toList();

    //sets the boundaries of the visable part of the screen
    // and the maximum scale to zoom out
    setMaxOffset(getOuterKeysAsList(keyAtBottomList));
    var maxScale = getMaxScale(getOuterKeysAsList(keyAtBottomList));
    if (appletMap["parentApplet"].childIds.length > 1) {
      if (stackScale < maxScale) {
        notifier.value.setEntry(0, 0, maxScale);
        notifier.value.setEntry(1, 1, maxScale);
      }
    }
  }

  Matrix4 updateStackWithMatrix(Matrix4 matrix) {
    if (appletMap["parentApplet"] == null) {
      appletMap = {};
    }

    if (notifier == null) {
      notifier = Constants.initializeNotifier(Matrix4.identity());
    }

    if (appletMap["parentApplet"] != null &&
        appletMap["parentApplet"].childIds.length > 1) {
      List<GlobalKey> keyAtBottomList = appletMap["parentApplet"]
          .childIds
          .map(
            (String e) => getGlobalKeyFromId(e),
          )
          .toList();
      double maxScale = getMaxScale(getOuterKeysAsList(keyAtBottomList));
      print('matrix $matrix');
      matrix.translate(initialViewOffset());
      print('translated $matrix');
      matrix.scale(maxScale);
    }
    notifier.value = matrix;
    return matrix;
  }

  vector64.Vector3 initialViewOffset() {
    vector64.Vector3 initialVector;
    if (notifier == null) {
      notifier = Constants.initializeNotifier(Matrix4.identity());
    }

    if (appletMap["parentApplet"] != null &&
        appletMap["parentApplet"].childIds.length > 1) {
      List<GlobalKey> keyAtBottomList = appletMap["parentApplet"]
          .childIds
          .map(
            (String e) => getGlobalKeyFromId(e),
          )
          .toList();

      List<Key> outerKeysAsList = getOuterKeysAsList(keyAtBottomList);
      List<double> maxOffsetList = getMaxOffset(outerKeysAsList);

      var stackWidth = (maxOffsetList[0] -
          maxOffsetList[2] +
          appletMap[getIdFromKey(outerKeysAsList[0])].size.width);
      var stackHeight = (maxOffsetList[1] -
          maxOffsetList[3] +
          appletMap[getIdFromKey(outerKeysAsList[1])].size.height);

      double maxScale = getMaxScale(getOuterKeysAsList(keyAtBottomList));

      var widthOffset = displaySize.width / maxScale - stackWidth;
      var heightOffset = displaySize.height / maxScale - stackHeight;
      initialVector = vector64.Vector3(widthOffset / 2 * maxScale,
          heightOffset / 2 * maxScale - headerHeight(), 0);

      /*notifier.value
          .translate(transformOffset); // setTranslation(transformOffset);
      notifier.value.scale(maxScale);*/

      //.notifier.value.setEntry(1, 3, middleOffset.dy);
    }
    return initialVector;
  }

  setInitialStackSizeAndOffset() {
    List<GlobalKey> keyAtBottomList = appletMap["parentApplet"]
        .childIds
        .map(
          (String e) => getGlobalKeyFromId(e),
        )
        .toList();
    List<GlobalKey> outerKeysAsList = getOuterKeysAsList(keyAtBottomList);
    List<double> maxOffsetList =
        getMaxOffset(getOuterKeysAsList(keyAtBottomList));

    print(maxOffsetList);
    var maxScale = getMaxScale(outerKeysAsList);
    print(maxScale);
    print(maxOffsetList[1] - maxOffsetList[3]);
    stackSize = Size(
        maxOffsetList[0] -
            maxOffsetList[2] +
            appletMap[getIdFromKey(outerKeysAsList[0])].size.width,
        (maxOffsetList[1] - maxOffsetList[3]) +
            appletMap[getIdFromKey(outerKeysAsList[1])].size.height);

    appletMap["parentApplet"].childIds.forEach((k) => {
          appletMap[k].position = Offset(
              appletMap[k].position.dx - maxOffsetList[2] / stackScale,
              appletMap[k].position.dy - maxOffsetList[3] / stackScale)
        });
  }

  void createNewArrow(String originId, Arrow arrow) {
    //RenderBox itemBox = itemKey.currentContext.findRenderObject();
    //Offset appPosition = itemBox.globalToLocal(Offset.zero);

    _api.addArrow(projectId, originId, arrow.toJson());
  }
}
