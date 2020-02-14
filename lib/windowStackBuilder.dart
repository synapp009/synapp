import 'package:flutter/material.dart';
import 'arrowWidget.dart';
import 'textboxWidget.dart';

import 'data.dart';

import 'package:provider/provider.dart';
import 'windowWidget.dart';

class WindowStackBuilder extends StatelessWidget {
  final Key itemKey;

  WindowStackBuilder(this.itemKey);

  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    return Stack(overflow: Overflow.visible, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          height: dataProvider.structureMap[itemKey].size.height,
          width: dataProvider.structureMap[itemKey].size.width,
          child: Text(
              '${itemKey.toString()},${dataProvider.structureMap[itemKey].scale.toString()}'),
        ),
      ),
      //TextField(maxLines:40),
      ...stackItems(context)
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    List<Widget> stackItemsList = [];
    var dataProvider = Provider.of<Data>(context);

    var stackItemDraggable;
    
    List childKeyList = dataProvider.structureMap[itemKey].childKeys;
    for (int i = 0; i < childKeyList.length; i++) {
      if (dataProvider.structureMap[childKeyList[i]].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(key: childKeyList[i]);

      } else if (dataProvider.structureMap[childKeyList[i]].type ==
          "TextApplet") {
        stackItemDraggable = TextboxWidget(key: childKeyList[i]);
       
      } else {
        stackItemDraggable = Container(height:0,width:0);
      }
       stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}
