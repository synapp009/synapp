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
  Map<Key, List<Arrow>> arrowMap;
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

  Map<Key, List<Arrow>> get getArrowMap => arrowMap;

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
    print(selectedMap);
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
    //with expensive RenderedBox, maybe better options?
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
if(arrowMap[key] == null){
  arrowMap[key] = [];
}
    arrowMap[key].add(
      Arrow(arrowed: false, target: null,size:Size(0,0),),
    );

    notifyListeners();
  }

  sizeSetter(Key startKey, actualPointer) {
    //set the size of the Arrow between to widgets and also the color

    var stackScale = notifier.value.row0[0];
    var itemSize = structureMap[startKey].size;
    var itemOffset = getPositionOfRenderBox(startKey);
    var itemScale = structureMap[startKey].scale;
    var width = (actualPointer.dx - itemOffset.dx) / stackScale -
        (itemSize.height / 2) * itemScale;
    var height =
        (actualPointer.dy - headerHeight() - itemOffset.dy) / stackScale -
            (itemSize.height / 2) * itemScale;

    arrowMap[startKey].forEach((k)=>{
      if (k.target == null){
        k.size = Size(width,height)
      }
    });


    notifyListeners();
  }

  Offset itemDropPosition(key, pointerDownOffset, pointerUpOffset) {
    var stackScale = notifier.value.row0[0];
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

  connectAndUnselect(Key itemKey) {
    //connect two widgets with ArrowWidget and unselect all afterwards
    selectedMap.forEach((Key k, bool v) => {
          if (k != itemKey && v == true)
            {selectedMap[k] = false, 
            arrowMap[itemKey].forEach((l)=>{
              if(l.target == null) {
                l.target = k
              }
            })
        }});

    selectedMap[itemKey] = false;

    notifyListeners();
  }
}
