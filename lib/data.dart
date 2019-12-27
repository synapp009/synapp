import 'dart:math';

import 'package:angles/angles.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

import 'arrow.dart';
import 'constants.dart';
import 'fitTextField.dart';
import 'window.dart';
import 'textBox.dart';

class Data with ChangeNotifier {
  ValueNotifier<Matrix4> notifier ;
  Matrix4 matrix = Matrix4.identity();

  Map<Key, dynamic> structureMap;
  Map<GlobalKey, List<Arrow>> arrowMap;
  Map<Key, bool> selectedMap;

  Key actualTarget;
  Offset positionForDrop;
  Offset currentStackPosition = Offset(0, 100);
  Offset currentTargetPosition = Offset(0, 0);
  Offset actualItemToPointerOffset = Offset(0, 0);
  double stackScale = 1.0;
  double statusBarHeight;

  Key actualItemKey;
  bool firstItem = true;

  Offset stackOffset = Offset(0, 0);

  Data() {
    structureMap = Constants.initializeStructure(structureMap);
    arrowMap = Constants.initializeArrowMap(arrowMap);
    positionForDrop = Constants.initializePositionMap(positionForDrop);
    selectedMap = Constants.initializeSelectedMap(selectedMap);
   notifier = Constants.initializeNotifier(notifier);
  }

  Map<GlobalKey, List<Arrow>> get getArrowMap => arrowMap;

  Map<Key, dynamic> get getStructureMap => structureMap;

  void changeItemListPosition({Key itemKey, Key newKey}) {
    structureMap.forEach((Key k, dynamic v) => {
          if (v.toString().contains('Window') &&
              v.childKeys != null &&
              v.childKeys.contains(itemKey))
            {v.childKeys.remove(itemKey)}
        });

    if (structureMap[newKey].childKeys == null) {
      structureMap[newKey].childKeys = [];
    }
    structureMap[newKey].childKeys.add(itemKey);

    notifyListeners();
  }

  void changeItemScale(key, scale) {
    structureMap[key].scale = scale;
    notifyListeners();
  }

  void createNewWindow() {
    Key windowKey = GlobalKey();
    Color color = RandomColor().randomColor(
        colorHue: ColorHue.yellow, colorBrightness: ColorBrightness.light);

    if (structureMap[null] == null) {
      structureMap[null] = Window(
        childKeys: [],
      );
    }
    structureMap[null].childKeys.add(windowKey);
    structureMap[windowKey] = Window(
        key: windowKey,
        size: Size(100, 100),
        position: Offset(200, 100),
        color: color,
        title: windowKey.toString(),
        childKeys: [],
        scale: 1.0);
    selectedMap[windowKey] = false;
    notifyListeners();
  }

  void createNewTextfield() {
    Key textboxKey = GlobalKey();

    if (structureMap[null] == null) {
      structureMap[null] = TextBox();
    }
    structureMap[null].childKeys.add(textboxKey);
    structureMap[textboxKey] = TextBox(
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
          if (v.toString().contains('Window') && v.childKeys.contains(key))
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
            if (structureMap[f].toString().contains('Window'))
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
    arrowMap[key].add(
      Arrow(
        arrowed: false,
        target: null,
        size: 0.0,
        position: centerOfRenderBox(key),
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

  setArrowToPointer(Key startKey, Offset actualPointer) {
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
    if ((feedbackKey == originKey || feedbackKey == targetKey)) {}
    Arrow arrow;
//get size and arrow of origin and target
    RenderBox originRenderBox = originKey.currentContext.findRenderObject();
    var originPosition = getPositionOfRenderBox(originKey);
    var originSize = originRenderBox.size;
    originPosition = Offset(
      originPosition.dx + (originSize.width / 2) * stackScale,
      originPosition.dy + (originSize.height / 2) * stackScale,
    );

    RenderBox targetRenderBox = targetKey.currentContext.findRenderObject();
    var targetPosition = getPositionOfRenderBox(targetKey);
    var targetSize = targetRenderBox.size;
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
          ((feedbackPosition + feedbackEdgeOffset - stackOffset)) / stackScale;
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

  hitTestRaw(position, context) {
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
          //hitTest(item: details.globalPosition.dx, target: k),

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

  zoomToBox(selectedKey, context) {
    //zoom display to select doubletap box and offset to left start

    Matrix4 matrix = Matrix4.identity();
    Size displaySize = MediaQuery.of(context).size;
    var itemSize = sizeOfRenderBox(selectedKey);
    var otherPos = itemDropPosition(selectedKey, Offset(0, 0), Offset(0, 0));
    var mapPosition = structureMap[selectedKey].position;
    
    var newScale = displaySize.width / itemSize.width;
    var itemPosition = getPositionOfRenderBox(selectedKey);

    print('structure mapPosition $mapPosition');
    print('otherpos $otherPos');
    print('newScale $newScale');
    print('displaySize $displaySize');
    print('stackScale $stackScale');
    print('stackOffset $stackOffset');

    //update Offset
    notifier.value.setEntry(0, 0, newScale);
    notifier.value.setEntry(1, 1, newScale);
    //notifier.value.scale(newScale);
    //update scale

    print('renderbox itemPosition $itemPosition');

    itemPosition = (((itemPosition - stackOffset)*newScale)/stackScale);
   
    notifier.value.setEntry(
        0, 3, -itemPosition.dx);
    notifier.value.setEntry(
        1, 3, -itemPosition.dy);
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
          //hitTest(item: details.globalPosition.dx, target: k),

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
          else
            {k != key ? selectedMap[k] = false : selectedMap[k] = true}
        });
  }
}
