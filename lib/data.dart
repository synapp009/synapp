import 'dart:math';
import 'package:angles/angles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:uuid/uuid.dart';

import 'core/constants.dart';
import 'core/models/appletModel.dart';
import 'core/models/arrowModel.dart';
import 'core/models/projectModel.dart';

class Data with ChangeNotifier {
  ValueNotifier<Matrix4> notifier;
  Matrix4 matrix = Matrix4.identity();

  Map<Key, Applet> structureMap;
  Map<GlobalKey, List<Arrow>> arrowMap;

  Map<Key, bool> selectedMap;
  Size stackSize;
  Offset positionForDrop;
  Offset currentStackPosition = Offset(0, 100);
  Offset currentTargetPosition = Offset(0, 0);
  Offset actualItemToPointerOffset = Offset(0, 0);
  double stackScale = 1.0;
  double statusBarHeight;
  double maxScale;
  Offset maxOffset;

  Map<Key, List<Key>> hasArrowToKeyMap = {};

  Key actualItemKey;
  bool firstItem = true;

  Offset stackOffset = Offset(0, 0);
  Offset generalStackOffset = Offset(0, 0);

  Data() {
    structureMap = Constants.initializeStructure(structureMap);
    arrowMap = Constants.initializeArrowMap(arrowMap);
    positionForDrop = Constants.initializePositionMap(positionForDrop);
    selectedMap = Constants.initializeSelectedMap(selectedMap);
    notifier = Constants.initializeNotifier(notifier);
  }

  Map<GlobalKey, List<Arrow>> get getArrowMap => arrowMap;

  Map<Key, dynamic> get getStructureMap => structureMap;

String getIdFromKey(Key itemKey){
  String itemId =  structureMap[itemKey].id;
  return itemId;
}

  void changeItemListPosition({Key itemKey, Key newKey}) {
    String itemId = getIdFromKey(itemKey);

    structureMap.forEach((Key k, Applet v) => {
          if (
          //v.toString().contains('WindowApplet') &&
          v.childKeys != null
          //&& v.childKeys.contains(itemKey)
          )
            { 
              v.childKeys.remove(itemKey),
              //}
            }
        });

    if (structureMap[newKey].childKeys == null) {
      structureMap[newKey].childKeys = [];
    }
    structureMap[newKey].childKeys.add(itemKey);
    structureMap[newKey].childIds.add(itemId);
    notifyListeners();
  }

  void changeItemScale(key, scale) {
    structureMap[key].scale = scale;
    notifyListeners();
  }

  createNewApp(type, GlobalKey itemKey) {
    RenderBox itemBox = itemKey.currentContext.findRenderObject();
    Offset appPosition = itemBox.globalToLocal(Offset.zero);
    if (type.toString().contains('WindowApplet')) {
      createNewWindow(appPosition);
    } else if (type.toString().contains('TextApplet')) {
      createNewTextBox(appPosition);
    }
  }

  createNewWindow(appPosition) {
    Key windowKey = new GlobalKey();
    var uuid = Uuid();
    String id = uuid.v4();

    Color color = new RandomColor().randomColor(
        colorHue: ColorHue.yellow, colorBrightness: ColorBrightness.light);

    if (structureMap[null] == null) {
      structureMap[null] = WindowApplet(
        childKeys: [],
        childIds: [],
      );
    }

    structureMap[null].childKeys.add(windowKey);
    structureMap[null].childIds.add(id);
    structureMap[windowKey] = WindowApplet(
        key: windowKey,
        id: id,
        size: Size(130, 130),
        position: Offset(200, 100),
        color: color,
        title: 'Title',
        childKeys: [],
        childIds: [],
        scale: 1.0);
    selectedMap[windowKey] = false;
    //notifyListeners();
  }

  Map<Key, Applet> createStructureMap(Project project) {
    Map<Key, Applet> tempMap = {};
    project.appletMap.forEach((Key key, Applet applet) { 
      Key tempKey;
      if (applet.id == "") {
        tempMap[null] = applet;
        tempKey = null;
        if (tempMap[null].childKeys == null) {
          tempMap[null].childKeys = [];
        }
      }else {
        tempKey = new GlobalKey();
      }
      print('typeit baby ${applet.type}');
      applet.key = tempKey;
      tempMap[null].childKeys.add(tempKey);
      tempMap[tempKey] = applet;
    });
    return tempMap;
  }

  createNewTextBox(appPosition) {
    Key textboxKey = GlobalKey();

    if (structureMap[null] == null) {
      structureMap[null] = TextApplet();
    }
    structureMap[null].childKeys.add(textboxKey);
    structureMap[textboxKey] = TextApplet(
        key: textboxKey,
        size: Size(100, 40),
        position: Offset(200, 100),
        color: Colors.black,
        title: 'Title',
        content: '',
        //bool expanded;
        scale: 1.0,
        textSize: 16);

    notifyListeners();
  }

  void onlySelectThis(key) {
    selectedMap.forEach((k, v) => {
          if (k != key) {selectedMap[k] = false}
        });
    notifyListeners();
  }

  Key getActualTargetKey(key) {
    var tempKey;
    structureMap.forEach((k, dynamic v) => {
          if (v.toString().contains('WindowApplet') &&
              v.childKeys.contains(key))
            {tempKey = k}
        });
    return tempKey;
  }

  double headerHeight() {
    double appBarHeight = AppBar().preferredSize.height;
    var tempHeight = statusBarHeight + appBarHeight;
    return tempHeight;
  }

  getTargetScale(scaleKey) {
    var targetKey = getActualTargetKey(scaleKey);
    var tempScale = structureMap[targetKey].scale;
    return tempScale;
  }

  Offset getPositionOfRenderBox(targetKey) {
    //with expensive RenderedBox, --> maybe better options?
    Offset tempPosition;
    if (targetKey != null) {
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

  List getAllChildren(itemKey) {
    var tempList = [];
    var childList = [];
    var todoList = [];
    var doneList = [];

    todoList.addAll(structureMap[itemKey].childKeys);

    while (todoList.length > 0) {
      tempList = [];
      todoList.forEach((f) => {
            if (!childList.contains(f)) {childList.add(f)},
            doneList.add(f),
            if (structureMap[f].toString().contains('WindowApplet'))
              {tempList.addAll(structureMap[f].childKeys)}
          });

      doneList.forEach((f) => todoList.remove(f));
      todoList.addAll(tempList);
    }

    return childList;
  }

  List getAllTargets(key) {
    List tempList = [];

    Key tempKey = getActualTargetKey(key);
    while (tempKey != null) {
      tempList.add(tempKey);
      tempKey = getActualTargetKey(tempKey);
    }
    return tempList;
  }

  void addArrow(key) {
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
    //notifyListeners();
  }

  Offset centerOfRenderBox(originKey) {
    //calculate the Center of a originKey RenderBox

    var centerOfOrigin;
    var tempStackOffset;
    RenderBox originBox = originKey.currentContext.findRenderObject();
    Offset originBoxPosition = originBox.globalToLocal(Offset.zero);
    originBoxPosition = -Offset(originBoxPosition.dx * stackScale,
        originBoxPosition.dy * stackScale + headerHeight());
    Size originBoxSize = originBox.size * stackScale;
    tempStackOffset = stackOffset * stackScale;
    //var originBoxScale = structureMap[originKey].scale;
    //double originBoxScale = structureMap[originKey].scale;
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
    arrowMap[startKey].forEach((k) => k.target == null ? arrow = k : null);
    var itemScale = structureMap[startKey].scale;
    var itemOffset = centerOfRenderBox(startKey);

    var length = diagonalLength(
      actualPointer,
      itemOffset,
    );

    arrow.position = (itemOffset - stackOffset) / stackScale;
    arrow.size = length / stackScale;
    arrow.angle = getAngle(itemOffset, actualPointer);

    notifyListeners();
  }

  Offset itemDropPosition(key, pointerDownOffset, pointerUpOffset) {
    var itemScale = structureMap[key].scale;
    var targetKey = getActualTargetKey(key);
    var targetOffset = getPositionOfRenderBox(targetKey);
    var itemHeaderOffset = 0;

    //checks if there is some relevance of additional offset caused by trag helper offset
    if (targetKey != null &&
        structureMap[key].toString().contains('WindowApplet')) {
      itemHeaderOffset = 20;
    }

    return Offset(
        ((pointerUpOffset.dx - targetOffset.dx) / itemScale / stackScale -
            pointerDownOffset.dx),
        ((pointerUpOffset.dy - targetOffset.dy - headerHeight()) /
                itemScale /
                stackScale -
            pointerDownOffset.dy));
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
      final Offset targetPosition,
      final Size targetSize}) {
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
    arrowMap[originKey].forEach((v) => {
          if (v.target == targetKey)
            {
              arrow = v,
            }
        });

//check if one (feedback, target or origin) is inside another
//hasArrowToKeyMap.forEach()
//boxHitTest()

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
    //connects two widgets with ArrowWidget, unselect all afterwards and delete  arrow if no target
    Offset positionOfTarget;
    GlobalKey tempKey;
    selectedMap.forEach((Key k, bool isSelected) => {
          if (k != itemKey && isSelected == true)
            {
              tempKey = k,
              positionOfTarget = centerOfRenderBox(k),
              positionOfTarget = Offset(
                  positionOfTarget.dx, positionOfTarget.dy + headerHeight()),
              setArrowToPointer(itemKey, positionOfTarget),
              selectedMap[k] = false,
              selectedMap[itemKey] = false,
              arrowMap[itemKey].forEach((Arrow l) => {
                    if (l.target == null) {l.target = k}
                  })
            }
        });
    for (int i = 0; i < arrowMap[itemKey].length; i++) {
      if (arrowMap[itemKey][i].target == null) {
        arrowMap[itemKey].removeAt(i);
      }
    }

    if (tempKey != null) {
      updateArrow(originKey: itemKey, targetKey: tempKey);
    }

    notifyListeners();
  }

  void stackSizeChange(key, GlobalKey feedbackKey, position) {
    Offset offsetChange;

    RenderBox itemBox = feedbackKey.currentContext.findRenderObject();
    var itemSize = itemBox.size;
    var stackChange = Offset(0, 0);

    if (position.dx > stackOffset.dx &&
        position.dx < stackOffset.dx + (stackSize.width * stackScale) &&
        (position.dy) > (stackOffset.dy + headerHeight()) &&
        position.dy <
            stackOffset.dy +
                ((stackSize.height + headerHeight()) * stackScale)) {
    } else {
      if (position.dx > stackOffset.dx + stackSize.width * stackScale) {
        //sector 1
        offsetChange = Offset(
            position.dx -
                stackOffset.dx -
                (stackSize.width * stackScale) +
                itemSize.width * stackScale,
            0);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        stackSize = Size(
            stackSize.width + offsetChange.dx / stackScale, stackSize.height);
      }
      if ((position.dy >
          stackOffset.dy + (headerHeight() + stackSize.height) * stackScale)) {
        //sector 2
        offsetChange = Offset(
            0,
            position.dy -
                stackOffset.dy -
                (stackSize.height * stackScale) +
                itemSize.height * stackScale);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        stackSize = Size(
            stackSize.width,
            stackSize.height +
                offsetChange.dy / stackScale -
                headerHeight() / stackScale);
      }
      if (position.dx < stackOffset.dx) {
        //sector 3

        offsetChange = Offset(
            position.dx - stackOffset.dx - itemSize.width * stackScale, 0);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        structureMap["null"].childKeys.forEach((k) => {
              structureMap[k].position = Offset(
                  structureMap[k].position.dx - offsetChange.dx / stackScale,
                  structureMap[k].position.dy)
            });
        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            stackSize.width - offsetChange.dx / stackScale, stackSize.height);
      }
      if (position.dy - headerHeight() < stackOffset.dy) {
        //sector 4
        offsetChange = Offset(
            0,
            position.dy -
                stackOffset.dy -
                headerHeight() -
                itemSize.height * stackScale);
        stackChange = Offset(
            stackChange.dx + offsetChange.dx, stackChange.dy + offsetChange.dy);
        structureMap["null"].childKeys.forEach((k) => {
              structureMap[k].position = Offset(structureMap[k].position.dx,
                  structureMap[k].position.dy - offsetChange.dy / stackScale)
            });
        notifier.value
            .setEntry(0, 3, notifier.value.row0.a + (offsetChange.dx));
        notifier.value
            .setEntry(1, 3, notifier.value.row1.a + (offsetChange.dy));
        stackSize = Size(
            stackSize.width, stackSize.height - offsetChange.dy / stackScale);
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

    notifier.notifyListeners();
  }

  Key hitTestRaw(position, context) {
    //checks if position of a context layes in a box and gives out the key of the box
    Map<Key, bool> selectedMap = {};
    var selectedKey;

    Size displaySize = MediaQuery.of(context).size;

    Map<Key, Offset> renderBoxesOffset = {};
    List targetList = [];

    //store all widgets in view into the list
    List widgetsInView = [];
    Offset itemKeyPosition;
    Size itemKeySize;
    structureMap.forEach((Key itemKey, dynamic widget) => {
          itemKeyPosition = Offset(
                  structureMap[itemKey].position.dx * stackScale,
                  structureMap[itemKey].position.dy * stackScale +
                      headerHeight()) +
              stackOffset,
          itemKeySize = structureMap[itemKey].size / stackScale,
          if (itemKey != null)
            {
              if (boxHitTest(
                  itemPosition: itemKeyPosition,
                  itemSize: itemKeySize,
                  targetPosition: stackOffset,
                  targetSize: displaySize))
                {widgetsInView.add(itemKey)}
            },
        });

    //hit Test for items laying in the widgetsInView
    widgetsInView.forEach((k) => {
          renderBoxesOffset[k] = getPositionOfRenderBox(k),

          /* boxHitTestWithScaleAndOffset(
                    itemPosition: details.globalPosition,
                    itemSize: Size(0,0),
                    targetPosition: renderBoxesOffset[k],
                    targetSize: displaySize)*/

          if (position.dx > renderBoxesOffset[k].dx &&
              position.dx <
                  renderBoxesOffset[k].dx +
                      structureMap[k].size.width *
                          structureMap[k].scale *
                          stackScale &&
              (position.dy - headerHeight()) > renderBoxesOffset[k].dy &&
              position.dy - headerHeight() <
                  renderBoxesOffset[k].dy +
                      structureMap[k].size.height *
                          stackScale *
                          structureMap[k].scale)
            {
              selectedMap[k] = true,
              targetList = getAllTargets(k),
              targetList.forEach((k) => selectedMap[k] = false)
            }
        });
    selectedMap.forEach((k, v) => {
          if (v == true)
            {
              selectedKey = k,
            }
        });
    return selectedKey;
  }

  getAllArrows(key) {
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
        ((Key originKey, List<Arrow> listOfArrows) => {
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
    List childList = getAllChildren(key);
    childList.add(key);

    childList.forEach((childKey) => {
          arrowMap.forEach((Key originKey, List<Arrow> listOfArrows) => {
                if (originKey != null)
                  {
                    listOfArrows.forEach((Arrow a) => {
                          if (a.target == childKey &&
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
                                  hasArrowToKeyMap[originKey].add(a.target),
                                },
                            },
                        }),
                  }
              })
        });
  }

  updateArrowToKeyMap(key, dragStarted, feedbackKey) {
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
  }

  zoomToBox(selectedKey, context) {
    //zoom display to select doubletap box and offset to left start

    Matrix4 matrix = Matrix4.identity();
    Size displaySize = MediaQuery.of(context).size;
    var itemSize = sizeOfRenderBox(selectedKey);
    var otherPos = itemDropPosition(selectedKey, Offset(0, 0), Offset(0, 0));
    var mapPosition = structureMap[selectedKey].position;

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

  hitTest(key, position, context) {
    //checks if position of a context layes in a box and gives out the key of the box

    Size displaySize = MediaQuery.of(context).size;

    Map<Key, Offset> renderBoxesOffset = {};
    List targetList = [];

    //store all widgets in view into the list
    List widgetsInView = [];
    Offset itemKeyPosition;
    Offset tempPosition = position;
    Size itemKeySize;
    structureMap.forEach((Key itemKey, dynamic widget) => {
          itemKeyPosition = Offset(structureMap[itemKey].position.dx,
                  structureMap[itemKey].position.dy + headerHeight()) +
              stackOffset,
          itemKeySize = structureMap[itemKey].size,
          if (itemKey != null)
            {
              if (boxHitTest(
                  itemPosition: itemKeyPosition,
                  itemSize: itemKeySize,
                  targetPosition: stackOffset,
                  targetSize: displaySize))
                {widgetsInView.add(itemKey)}
            },
        });

    //hit Test for items laying in the widgetsInView
    widgetsInView.forEach((k) => {
          //hitTest(item: details.globalPosition.dx, target: k),

          renderBoxesOffset[k] = getPositionOfRenderBox(k),

          /* boxHitTestWithScaleAndOffset(
                    itemPosition: details.globalPosition,
                    itemSize: Size(0,0),
                    targetPosition: renderBoxesOffset[k],
                    targetSize: displaySize)*/

          if (tempPosition.dx > renderBoxesOffset[k].dx &&
              tempPosition.dx <
                  renderBoxesOffset[k].dx +
                      structureMap[k].size.width *
                          structureMap[k].scale *
                          stackScale &&
              (tempPosition.dy - headerHeight()) > renderBoxesOffset[k].dy &&
              tempPosition.dy - headerHeight() <
                  renderBoxesOffset[k].dy +
                      structureMap[k].size.height *
                          stackScale *
                          structureMap[k].scale)
            {
              selectedMap[k] = true,
              targetList = getAllTargets(k),
              targetList.forEach((k) => selectedMap[k] = false)
            }
          else
            {k != key ? selectedMap[k] = false : selectedMap[k] = true}
        });
  }
}
