import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'core/models/appletModel.dart';
import 'core/models/arrowModel.dart';
import 'textboxWidget.dart';

import 'windowWidget.dart';
import 'arrowWidget.dart';
import 'data.dart';

class ItemStackBuilder extends StatefulWidget {
  final id;
  ItemStackBuilder(this.id);
  @override
  _ItemStackBuilderState createState() => _ItemStackBuilderState();
}

class _ItemStackBuilderState extends State<ItemStackBuilder> {
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var stackScale = projectProvider.stackScale;

    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
            //color: Colors.green,
            width: projectProvider.stackSize.width,
            height: projectProvider.stackSize.height,
          );
        },
        onWillAccept: (dynamic data) {
          if (projectProvider.appletMap[null].id != data.id &&
              !projectProvider.appletMap[data.id].childIds.contains(null) &&
              !projectProvider.leaveApplet &&
              !projectProvider.appletMap[null].childIds.contains(data.id)) {
            var stackOffset = Offset(projectProvider.notifier.value.row0.a,
                projectProvider.notifier.value.row1.a);
            double _scaleChange = projectProvider.appletMap[data.id].scale;
            projectProvider.appletMap[data.id].scale = 1.0;
            projectProvider.currentTargetPosition = stackOffset;
            projectProvider.changeItemListPosition(
                itemId: data.id, newId: null);

            projectProvider.scaleChange =
                projectProvider.appletMap[data.id].scale / _scaleChange;

            List<Key> childrenList =
                Provider.of<Project>(context, listen: false)
                    .getAllChildren(data.key);
            if (childrenList != null) {
              childrenList.forEach((element) {
                if (element != null) {
                  Key _dragItemTargetKey =
                      projectProvider.getActualTargetKey(element);
                  String _dragItemTargetId =
                      projectProvider.getIdFromKey(_dragItemTargetKey);
                  double _dragItemTargetScale =
                      projectProvider.appletMap[_dragItemTargetId].scale;

                  projectProvider
                      .appletMap[projectProvider.getIdFromKey(element)]
                      .scale = projectProvider
                          .appletMap[projectProvider.getIdFromKey(element)]
                          .scale *
                      projectProvider.scaleChange;
                }
              });
            }
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
    var projectProvider = Provider.of<Project>(context);
    List<Widget> stackItemsList = [];
    Widget stackItemDraggable;
    List childIdList = projectProvider.appletMap[null].childIds;

    List<GlobalKey> childKeyList = projectProvider.appletMap[null].childIds
        .map((e) => projectProvider.getGlobalKeyFromId(e))
        .toList();

    for (int i = 0; i < childIdList.length; i++) {
      if (projectProvider.appletMap[childIdList[i]].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(key: childKeyList[i]);
      } else if (projectProvider.appletMap[childIdList[i]].type ==
          "TextApplet") {
        stackItemDraggable = TextboxWidget(id: childIdList[i]);
      } else {
        stackItemDraggable = Container(width: 0, height: 0);
      }

      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}

List<Widget> arrowItems(BuildContext context) {
  var projectProvider = Provider.of<Project>(context);
  List<Widget> arrowItemsList = [];
  Map<String, List<Arrow>> arrowMap = projectProvider.arrowMap;
  Key originKey;
  Key targetKey;
  arrowMap.forEach((String originId, List<Arrow> arrowList) => {
        originKey = projectProvider.getKeyFromId(originId),
        if (originKey != null)
          {
            arrowList.forEach((Arrow tempArrow) {
              targetKey = projectProvider.getKeyFromId(tempArrow.target);
              arrowItemsList.add(ArrowWidget(originKey, targetKey));
            }),
          }
      });

  return arrowItemsList;
}
