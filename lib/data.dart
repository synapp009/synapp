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
  ValueNotifier<Matrix4> notifier;

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
    //double originBoxScale = dataProvider.structureMap[originKey].scale;
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

  updateArrow(
      {final GlobalKey originKey,
      final GlobalKey feedbackKey,
      final GlobalKey targetKey,
      final GlobalKey draggedKey}) {
    Arrow arrow;


    RenderBox originRenderBox = originKey.currentContext.findRenderObject();
       var originPosition = getPositionOfRenderBox(originKey);
    var originSize = originRenderBox.size;
    originPosition = Offset(originPosition.dx + (originSize.width/2)*stackScale,originPosition.dy+ (originSize.height/2)*stackScale,  );



 

    RenderBox targetRenderBox = targetKey.currentContext.findRenderObject();
       var targetPosition = getPositionOfRenderBox(targetKey);
    var targetSize = targetRenderBox.size;
    targetPosition = Offset(targetPosition.dx + (targetSize.width/2)*stackScale,targetPosition.dy+ (targetSize.height/2)*stackScale,  );


    var feedbackPosition;
    var feedbackSize;

    if (feedbackKey != null) {
      RenderBox feedbackRenderBox =
          feedbackKey.currentContext.findRenderObject();
      feedbackSize = feedbackRenderBox.size * 1.1;
      feedbackPosition = getPositionOfRenderBox(feedbackKey);
      feedbackPosition = (Offset(feedbackPosition.dx + (feedbackSize.width / 2)*stackScale,
          feedbackPosition.dy + (feedbackSize.height / 2)*stackScale));
    } 

//get correct arrow
    arrowMap[originKey].forEach((v) => {
          if (v.target == targetKey)
            {
              arrow = v,
            }
        });

    if (draggedKey == originKey ) {
      //if origin gets tragged, use feedback as origin

      arrow.size = diagonalLength(
              Offset(targetPosition.dx, targetPosition.dy + headerHeight()),
              feedbackPosition) /
          stackScale;
      arrow.angle = getAngle(feedbackPosition,
          Offset(targetPosition.dx, targetPosition.dy + headerHeight()));
      arrow.position = (feedbackPosition - stackOffset) / stackScale;
    } else if (draggedKey == targetKey ) {
      //if target gets tragged, use feedback as target

      arrow.size =
          diagonalLength(Offset(originPosition.dx,originPosition.dy+headerHeight()),feedbackPosition) / stackScale;
      arrow.angle = getAngle(Offset(originPosition.dx,originPosition.dy-headerHeight()),feedbackPosition);
      arrow.position = (originPosition - stackOffset) / stackScale;
    } else {
      arrow.size = diagonalLength(Offset(originPosition.dx,originPosition.dy+headerHeight()), targetPosition) / stackScale;
      arrow.angle = getAngle(Offset(originPosition.dx,originPosition.dy),Offset(targetPosition.dx, targetPosition.dy + headerHeight()));
      arrow.position = (originPosition - stackOffset) / stackScale;
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
              positionOfTarget =
                  Offset(positionOfTarget.dx, positionOfTarget.dy+headerHeight()),
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

    selectedMap[itemKey] = false;

    notifyListeners();
  }
}
