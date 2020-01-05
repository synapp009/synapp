import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'arrow.dart';
import 'textboxWidget.dart';

import 'windowWidget.dart';
import 'arrowWidget.dart';
import 'data.dart';

class ItemStackBuilder extends StatefulWidget {
  @override
  _ItemStackBuilderState createState() => _ItemStackBuilderState();
}

class _ItemStackBuilderState extends State<ItemStackBuilder> {
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var stackScale = dataProvider.stackScale;
    var stackSize = dataProvider.stackSize;
    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
            //color:Colors.white,
            width: stackSize.width,
            height: stackSize.height,
          );
        },
        onWillAccept: (dynamic data) {
          dataProvider.actualTarget = null;
          if (dataProvider.structureMap[null].key != data.key) {
            var stackOffset = Offset(dataProvider.notifier.value.row0.a,
                dataProvider.notifier.value.row1.a);
            dataProvider.actualTarget = null;
            dataProvider.structureMap[data.key].scale = 1.0;
            dataProvider.currentTargetPosition = stackOffset;
            dataProvider.changeItemListPosition(
                itemKey: data.key, newKey: null);
            return true;
          } else {
            return false;
          }
        },
        onLeave: (dynamic data) {},
        onAccept: (dynamic data) {},
      ),
      ...stackItems(context),
      ...arrowItems(context),
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    List<Widget> stackItemsList = [];
    var stackItemDraggable;
    List childKeyList = dataProvider.structureMap[null].childKeys;
    for (int i = 0; i < childKeyList.length; i++) {
      if (dataProvider.structureMap[childKeyList[i]]
          .toString()
          .contains('Window')) {
        stackItemDraggable = WindowWidget(key: childKeyList[i]);
      } else {
        stackItemDraggable = TextboxWidget(key: childKeyList[i]);
      }

      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}

List<Widget> arrowItems(BuildContext context) {
  var dataProvider = Provider.of<Data>(context);
  List<Widget> arrowItemsList = [];
  Map<Key, List<Arrow>> arrowMap = dataProvider.arrowMap;

  arrowMap.forEach((Key originKey, List<Arrow> arrowList) => {
        if (originKey != null)
          {
            arrowList.forEach((Arrow tempArrow) =>
                arrowItemsList.add(ArrowWidget(originKey, tempArrow.target)))
          }
      });

  return arrowItemsList;
}
