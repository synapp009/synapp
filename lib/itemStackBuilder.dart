import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'arrow.dart';
import 'textboxWidget.dart';

import 'windowWidget.dart';
import 'arrowWidget.dart';
import 'data.dart';

class ItemStackBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);

    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
              color: Color.fromARGB(100, 71, 2, 255),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height);
        },
        onWillAccept: (dynamic data) {
          dataProvider.actualTarget = null;
          if (dataProvider.structureMap[key].key !=
                  data.key /*&&
          !dataProvider.structureMap[data.key].childKeys.contains(key) &&
          !dataProvider.structureMap[key].childKeys.contains(data.key)*/
              ) {
            // dataProvider.changeItemListPosition(itemKey: data.key, newKey: key);
            var stackOffset = Offset(dataProvider.notifier.value.row0.a,
                dataProvider.notifier.value.row1.a);
            dataProvider.actualTarget = null;
            dataProvider.structureMap[data.key].scale = 1.0;
            dataProvider.currentTargetPosition = stackOffset;
            dataProvider.changeItemListPosition(itemKey: data.key, newKey: key);
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
