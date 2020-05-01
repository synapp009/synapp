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
  //Map<String, List<Arrow>> arrowMap;

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
      this.description}) {
    projectIdStatic = this.projectId;
    appletMap = Constants.initializeAppletMap();
    positionForDrop = Constants.initializePositionMap(positionForDrop);
    stackSize = null;
    notifier = Constants.initializeNotifier(Matrix4.identity());
  }

  Project.fromMap(Map snapshot, String id)
      : projectId = snapshot['id'] ?? '',
        //key = Key(snapshot['key']) ?? null,
        name = snapshot['name'] ?? '',
        img = snapshot['img'] ?? '',
        description = snapshot['description'] ?? '';

  toJson() {
    return {
      "id": projectId,
      "name": name,
      "img": img,
      "description": description
    };
  }

  Project update(Map<String, Applet> updatedAppletMap) {
    print('projectupdate ');
    if (appletMap == null) {
      appletMap = {};
    }

    if (updatedAppletMap != null) {
      updatedAppletMap.forEach((k, updatedApplet) {
        appletMap.update(k, (a) {
          a.key = (a.key == null ? new GlobalKey() : a.key);
          a.position = (a.position == updatedApplet.position
                  ? a.position
                  : updatedApplet.position) ??
              Offset(0, 0);
          a.scale =
              (a.scale == updatedApplet.scale ? a.scale : updatedApplet.scale);
          a.childIds = (a.childIds == updatedApplet.childIds
              ? a.childIds
              : updatedApplet.childIds);
          a.color =
              (a.color == updatedApplet.color ? a.color : updatedApplet.color);
          a.size = (a.size == updatedApplet.size ? a.size : updatedApplet.size);
          a.fixed =
              (a.fixed == updatedApplet.fixed ? a.fixed : updatedApplet.fixed);
          a.content = (a.content == updatedApplet.content
              ? a.content
              : updatedApplet.content);
          a.type = (a.type == updatedApplet.type ? a.type : updatedApplet.type);
          a.onChange = (a.onChange == updatedApplet.onChange
              ? a.onChange
              : updatedApplet.onChange);
          a.textSize = (a.textSize == updatedApplet.textSize
              ? a.textSize
              : updatedApplet.textSize);
          a.title =
              (a.title == updatedApplet.title ? a.title : updatedApplet.title);
          a.arrowMap = (a.arrowMap == updatedApplet.arrowMap
              ? a.arrowMap
              : updatedApplet.arrowMap);
          return a;
        }, ifAbsent: () {
          var tempApplet = updatedApplet;
          tempApplet.key = new GlobalKey();
          tempApplet.id = updatedApplet.id;
          return tempApplet;
        });

        /*if (updatedApplet.arrowList != null &&
            updatedApplet.arrowList.length > 0) {
          arrowMap.update(k, (a) {
            return a =
                (a == updatedApplet.arrowList ? a : updatedApplet.arrowList);
          }, ifAbsent: () {
            return updatedApplet.arrowList;
          });
        }*/
      });
    }
    //check if appletMap is onChange
    int containsOnChange = 0;
    appletMap.forEach((s, a) {
      containsOnChange = a.onChange ? containsOnChange + 1 : containsOnChange;
    });
    if (containsOnChange == 0) {
      notifyListeners();
    }

    //update all arrows
    appletMap.forEach((String appletId, Applet applet) {
      applet.arrowMap.forEach((String targetId, Arrow arrow) {
        arrow.updateArrow(
          project: this,
          originKey: getKeyFromId(appletId),
          targetKey: getKeyFromId(targetId),
        );
      });
    });

    globalStackPositionChange = Offset(0, 0);
    return this;
  }

  Size stackSize;
  Offset positionForDrop;
  Offset currentTargetPosition = Offset(0, 0);
  double stackScale = 1.0;
  Offset globalStackPositionChange = Offset(0, 0);
  double statusBarHeight;
  double maxScale;

  double scaleChange = 1.0;
  bool textFieldFocus = false;
  bool pointerMoving = false;
  Offset originTextBoxPosition;
  Size originTextBoxSize;
  Size displaySize;
  bool initial = true;
  String dragTargetId;

  String originId;
  String targetId;

  double projectMaxScale;

  Key actualItemKey;
  GlobalKey backgroundStackKey;
  bool firstItem = true;
  var chosenId;

  Offset stackOffset = Offset(0, 0);

  String getIdFromKey(Key itemKey) {
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
    appletMap.forEach((String id, Applet v) => {
          if (v.childIds != null && v.childIds.contains(itemId))
            {v.childIds.remove(itemId)}
        });

    if (appletMap[newId].childIds == null) {
      appletMap[newId].childIds = [];
    }

    appletMap[newId].childIds.add(itemId);

    //notifyListeners();
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

  Key getActualTargetKey({Key key, String id}) {
    var tempId;
    if (id != null) {
      tempId = id;
    } else {
      tempId = getIdFromKey(key);
    }

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
    var targetKey = getActualTargetKey(key: scaleKey);

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
    print('target ${targetKey.currentContext}');
    if (targetKey != null && targetKey.currentContext != null) {
      RenderBox targetRenderObject =
          targetKey.currentContext.findRenderObject();
      tempPosition = targetRenderObject.localToGlobal(Offset.zero);
      print('targetRenderObject.size ${targetRenderObject.size}');
      currentTargetPosition =
          Offset(tempPosition.dx, tempPosition.dy - headerHeight());
      return tempPosition = currentTargetPosition;
    } else {
      print('$targetKey targetkey is null');
      return tempPosition =
          Offset(notifier.value.row0.a, notifier.value.row1.a);
    }
  }

  List<String> getAllChildren({Applet applet}) {
    String itemId;

    itemId = applet.id;

    List<String> tempList = [];
    List<String> childList = [];
    List<String> todoList = [];
    List<String> doneList = [];
    String todoId;

    applet.childIds.forEach((element) {
      todoList.add(element);
    });
    while (todoList.length > 0) {
      tempList.clear();
      todoList.forEach((todoId) => {
            if (!childList.contains(todoId))
              {
                childList.add(todoId),
              },
            if (!doneList.contains(todoId))
              {
                doneList.add(todoId),
                if (appletMap[todoId].type == "WindowApplet")
                  {
                    appletMap[todoId].childIds.forEach((element) {
                      tempList.add(element);
                    })
                  }
              }
          });
      todoList.addAll(tempList);
      doneList.forEach((doneKey) => todoList.remove(doneKey));
    }
    todoList.clear();

    return childList;
  }

  List<Key> getAllTargets(Key key) {
    List<Key> tempList = [];

    Key tempKey = getActualTargetKey(key: key);

    while (tempKey != null) {
      tempList.add(tempKey);
      tempKey = getActualTargetKey(key: tempKey);
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

  Offset getDropPosition(
      {Applet applet, Offset pointerDownOffset, Offset pointerUpOffset}) {
    var itemScale = applet.scale;
    var targetKey = getKeyFromId(targetId);
    var targetOffset = getPositionOfRenderBox(targetKey);

    return Offset(
      ((pointerUpOffset.dx - targetOffset.dx) / itemScale / stackScale -
          pointerDownOffset.dx),
      ((pointerUpOffset.dy - targetOffset.dy - headerHeight()) /
              itemScale /
              stackScale -
          pointerDownOffset.dy),
    );
  }

  void changeItemDropPosition(
      {Applet applet,
      GlobalKey feedbackKey,
      Offset pointerDownOffset,
      Offset pointerUpOffset,
      bool initialize}) {
    var itemScale = applet.scale;
    var isInitializing = initialize == true ? true : false;
    var id = applet.id;
    var targetKey = getKeyFromId(targetId);
    var targetOffset = getPositionOfRenderBox(targetKey);
    var itemHeaderOffset = 0;
    print('pointerdownoffset $pointerDownOffset');
    print('pointerupoffset $pointerUpOffset');
    print('targetId $targetId');
    print('targetkey $targetKey');

    //checks if there is some relevance of additional offset caused by trag helper offset
    if (targetKey != null &&
        appletMap[id].toString().contains('WindowApplet')) {
      itemHeaderOffset = 20;
    }
    print('targetoffset $targetOffset');
    print('stackscale $stackScale');
    print('itemscale $itemScale');
    print('pointerupoffset $pointerUpOffset');

    RenderBox _backgroundStackRenderBox =
        backgroundStackKey.currentContext.findRenderObject();
    Offset _backgroundStackPosition =
        (_backgroundStackRenderBox.localToGlobal(Offset.zero) -
                Offset(0, headerHeight())) /
            stackScale;

    applet.position = Offset(
      ((pointerUpOffset.dx - targetOffset.dx) / itemScale / stackScale -
          pointerDownOffset.dx),
      ((pointerUpOffset.dy - targetOffset.dy - headerHeight()) /
              itemScale /
              stackScale -
          pointerDownOffset.dy),
    );

    changeItemListPosition(
        itemId: applet.id, newId: targetId ??= "parentApplet", applet: applet);

    if (targetId == "parentApplet" || targetId == null) {
      stackSizeChange(
          applet: applet,
          feedbackKey: feedbackKey,
          pointerUpOffset: pointerUpOffset,
          pointerDownOffset: pointerDownOffset,
          initialize: isInitializing);
    }

    print(' originId $originId');
    updateApplet(applet: applet, targetId: targetId, originId: originId);
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

  void addArrow(String id) {
    //adds an Arrow to the list of arrows from origin widget to null

    _arrow.addArrow(id, this);

    notifyListeners();
  }

  void setArrowToPointer(String startId, Offset actualPointer) {
    //set the size and ancle of the Arrow between widget and pointer
    //from center of a RenderBox (startKey)
    appletMap[startId]
        .arrowMap['parentApplet']
        .setArrowToPointer(startId, actualPointer, this);

    notifyListeners();
  }

  updateArrow(
      {final GlobalKey originKey,
      final GlobalKey feedbackKey,
      final GlobalKey targetKey,
      final GlobalKey draggedKey}) {
    var originId = getIdFromKey(originKey);
    var targetId = getIdFromKey(targetKey);
    appletMap[originId].arrowMap[targetId].updateArrow(
        project: this,
        originKey: originKey,
        feedbackKey: feedbackKey,
        targetKey: targetKey,
        draggedKey: draggedKey);

    notifyListeners();
  }

  getAllArrowApplets(Key key) {
    //get all arrows pointing to or coming from the item and also it's children items
    _arrow.getAllArrowApplets(this, key);
  }

  updateArrowToKeyMap(Key key, bool dragStarted, Key feedbackKey) {
    _arrow.updateArrowToKeyMap(this, key, dragStarted, feedbackKey);

    // notifyListeners();
  }

  connectAndUnselect(Key originKey) {
    var originId = getIdFromKey(originKey);
    appletMap[originId]
        .arrowMap['parentApplet']
        .connectAndUnselect(this, originKey);

    //notifyListeners();
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

  void stackSizeChange(
      {Applet applet,
      GlobalKey feedbackKey,
      Offset pointerUpOffset,
      Offset pointerDownOffset,
      bool initialize}) {
    var targetOffset = Offset(0, 0);

    var itemScale = applet.scale;

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
        print('//sector1');
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
        print('//sector 2');

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
        print('//sector 3');
        print(
            'positionOfItem.dx - _backgroundStackPosition.dx ${positionOfItem.dx - _backgroundStackPosition.dx}');
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
                  appletMap[k].position.dy - offsetChange.dy / stackScale),
              updateApplet(applet: appletMap[k])
            });

        if (!appletMap["parentApplet"].childIds.contains(applet.id) ||
            initialize) {
          applet.position = Offset(
              applet.position.dx - offsetChange.dx / stackScale,
              applet.position.dy - offsetChange.dy / stackScale);
        }

        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
          _backgroundStackSize.width - offsetChange.dx / stackScale,
          !(positionOfItem.dy < _backgroundStackPosition.dy)
              ? _backgroundStackSize.height +
                  (positionOfItem.dy >
                          _backgroundStackPosition.dy +
                              _backgroundStackSize.height -
                              itemSize.height
                      ? -headerHeight() + tempOffsetChangeOne.dy
                      : 0)
              : _backgroundStackSize.height +
                  offsetChange.dy -
                  headerHeight() +
                  (positionOfItem.dy >
                          _backgroundStackPosition.dy +
                              _backgroundStackSize.height -
                              itemSize.height
                      ? tempOffsetChangeOne.dy
                      : 0),
        );
      }

      if (positionOfItem.dy < _backgroundStackPosition.dy) {
        print(' //sector 4');

        offsetChange = Offset(offsetChange.dx,
                positionOfItem.dy - _backgroundStackPosition.dy) *
            stackScale;
        stackChange = Offset(
            stackChange.dx, stackChange.dy + offsetChange.dy / stackScale);

        appletMap["parentApplet"].childIds.forEach((k) => {
              appletMap[k].position = Offset(appletMap[k].position.dx,
                  appletMap[k].position.dy - offsetChange.dy / stackScale),
              updateApplet(applet: appletMap[k])
            });
        if (!appletMap["parentApplet"].childIds.contains(applet.id) ||
            initialize) {
          applet.position = Offset(applet.position.dx,
              applet.position.dy - offsetChange.dy / stackScale);
        }

        notifier.value.setEntry(0, 3, notifier.value.row0.a);
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            (positionOfItem.dx < _backgroundStackPosition.dx &&
                    positionOfItem.dy < _backgroundStackPosition.dy)
                ? _backgroundStackSize.width -
                    tempOffsetChangeTwo.dx / stackScale
                : _backgroundStackSize.width +
                    (positionOfItem.dx < _backgroundStackPosition.dx
                            ? (-1) * offsetChange.dx +
                                tempOffsetChangeTwo.dx * (-1)
                            : offsetChange.dx / stackScale) /
                        stackScale,
            _backgroundStackSize.height - offsetChange.dy / stackScale);
      }
    }
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

  childrenAreSelected(Applet _applet) {
    var childrenList = getAllChildren(applet: _applet);
    var isSelected = false;

    childrenList.forEach((element) {
      if (appletMap[element].selected == true) {
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
              !childrenAreSelected(appletMap[getIdFromKey(k)]))
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

  void updateApplet({Applet applet, String targetId, String originId}) {
    print('updateapplet originId $originId, targetId $targetId');

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
    List<String> childrenIds = getAllChildren(applet: applet);

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
    return doc.map((QuerySnapshot value) => {
          for (var v in value.documents)
            v.documentID: Applet.fromMap(snapshot: v.data)
        });
  }

  Stream<Map<String, Applet>> fetchAppletsChangesAsStream() {
    Stream<QuerySnapshot> doc = _api.streamAppletCollection(projectId);

    return doc.map((QuerySnapshot value) {
      return {
        for (var v in value.documentChanges)
          v.document.documentID: Applet.fromMap(snapshot: v.document.data)
      };
    }).handleError((err) => print(err));
  }

  Future<Applet> getAppletById(String appletId) async {
    var doc = await _api.getAppletById(projectId, appletId);
    return Applet.fromMap(snapshot: doc.data);
  }

  Stream<DocumentSnapshot> fetchAppletByIdAsStream(String appletId) {
    return _api.getAppletByIdAsStream(projectId, appletId);
  }

  Future<List<Applet>> getAppletsById(String id) async {
    List<Applet> list = new List();
    var doc = await _api.getAppletsById(id);
    doc.forEach((DocumentSnapshot docSnapshot) {
      list.add(Applet.fromMap(snapshot: docSnapshot.data));
    });
    /*map((DocumentSnapshot docSnapshot) {
     
       Applet.fromMap(docSnapshot);
    }).toList();*/
    return list;
  }

  Future<Applet> createNewApp(String type) async {
    //RenderBox itemBox = itemKey.currentContext.findRenderObject();
    //Offset appPosition = itemBox.globalToLocal(Offset.zero);

    var doc = Firestore.instance
        .collection("projects")
        .document(projectId)
        .collection("applets")
        .document();

    String newDocId = doc.documentID;

    Applet newApplet = new Applet(id: newDocId);

    if (type == "WindowApplet") {
      newApplet.setNewWindow();
    } else if (type == "TextApplet") {
      newApplet.setNewTextBox();
    }

    Firestore.instance
        .collection("projects")
        .document(projectId)
        .collection("applets")
        .document(newDocId)
        .setData(
          newApplet.toJson(),
        )
        .timeout(Duration(seconds: 10))
        .catchError((error) {
      print(error);
    });
    return newApplet;
  }

  /*
    var id = doc.documentID;
    var tempData = newApplet.toJson();
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
  }*/

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
          appletMap[getIdFromKey(mostBottomKey)].position.dy +
              appletMap[getIdFromKey(mostBottomKey)].size.height) {
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
    var scaleRate = 0.5;
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

    maxScale =
        (maxScaleHeight < maxScaleWidth ? maxScaleHeight : maxScaleWidth) *
            scaleRate;
    if (projectMaxScale == null) {
      projectMaxScale = maxScale;
    }
    return maxScale;
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
    maxScale = projectMaxScale < maxScale ? projectMaxScale : maxScale;

    if (appletMap["parentApplet"].childIds.length > 1) {
      if (stackScale < maxScale) {
        notifier.value.setEntry(0, 0, maxScale);
        notifier.value.setEntry(1, 1, maxScale);
      }
    }
  }

  Matrix4 getInitialStackViewAsMatrix(Matrix4 matrix) {
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
      projectMaxScale = getMaxScale(getOuterKeysAsList(keyAtBottomList));
      stackScale = projectMaxScale;
      matrix.translate(initialViewOffset());
      matrix.scale(projectMaxScale);
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
      maxScale = projectMaxScale < maxScale ? projectMaxScale : maxScale;

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

    stackSize = Size(
      maxOffsetList[0] -
          maxOffsetList[2] +
          appletMap[getIdFromKey(outerKeysAsList[0])].size.width,
      (maxOffsetList[1] - maxOffsetList[3]) +
          (appletMap[getIdFromKey(outerKeysAsList[1])].size.height),
    );

    appletMap["parentApplet"].childIds.forEach((k) => {
          appletMap[k].position = Offset(
              appletMap[k].position.dx - maxOffsetList[2] / stackScale,
              appletMap[k].position.dy - maxOffsetList[3] / stackScale),
        });

    appletMap.forEach(
      (id, applet) => applet.arrowMap.forEach(
        (targetId, arrow) => arrow.updateArrow(
            project: this,
            targetKey: getKeyFromId(targetId),
            originKey: getKeyFromId(id)),
      ),
    );
  }
}
