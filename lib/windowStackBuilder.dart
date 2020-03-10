import 'package:flutter/material.dart';
import 'arrowWidget.dart';
import 'core/models/projectModel.dart';
import 'textboxWidget.dart';

import 'data.dart';

import 'package:provider/provider.dart';
import 'windowWidget.dart';

class WindowStackBuilder extends StatelessWidget {
  final String id;

  WindowStackBuilder(this.id);

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    return Stack(overflow: Overflow.clip, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          height: projectProvider.appletMap[id].size.height,
          width: projectProvider.appletMap[id].size.width,
          /* child: Text(
              '${projectProvider.getKeyFromId(id).toString()},${projectProvider.appletMap[id].scale.toString()}'),*/
        ),
      ),
      //TextField(maxLines:40),
      ...stackItems(context)
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    List<Widget> stackItemsList = [];
    var projectProvider = Provider.of<Project>(context);

    var stackItemDraggable;

    List childIdList = projectProvider.appletMap[id].childIds;
    List childKeyList = projectProvider.appletMap[id].childIds
        .map((e) => projectProvider.getKeyFromId(e))
        .toList();
    for (int i = 0; i < childIdList.length; i++) {
      if (projectProvider.appletMap[childIdList[i]].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(key: childKeyList[i]);
      } else if (projectProvider.appletMap[childIdList[i]].type ==
          "TextApplet") {
        stackItemDraggable = TextboxWidget(key: childKeyList[i]);
      } else {
        stackItemDraggable = Container(height: 0, width: 0);
      }
      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}
