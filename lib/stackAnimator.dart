import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:vector_math/vector_math.dart' as vector;

import 'package:zefyr/zefyr.dart';
import 'core/models/appletModel.dart';
import 'core/models/projectModel.dart';

import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';

import 'core/models/arrowModel.dart';
import 'textboxWidget.dart';

import 'windowWidget.dart';
import 'arrowWidget.dart';

class StackAnimator extends StatefulWidget {
  final project;
  StackAnimator(this.project);
  @override
  _StackAnimatorState createState() => _StackAnimatorState();
}

class _StackAnimatorState extends State<StackAnimator>
    with AfterLayoutMixin<StackAnimator> {
  bool isExec = true;
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    isExec = false;
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Matrix4> notifier;
    var projectProvider = Provider.of<Project>(context);

    notifier = projectProvider.notifier;

   
    return ZefyrScaffold(
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          //notifier.value = m;
          projectProvider.stackScale = notifier.value.row0[0];
          projectProvider.stackOffset =
              Offset(notifier.value.row0.a, notifier.value.row1.a);

//continue with the initial view after moving but then change to matrixgesturedetector input
          notifier.value =
              !isExec ? projectProvider.updateStackWithMatrix(m) : m;

          isExec = true;
          projectProvider.setMaxScaleAndOffset(context);
        },
        shouldRotate: false,
        child: Stack(children: [
          Container(color: Colors.transparent),
          Positioned(
            top: 0,
            left: 0,
            child: AnimatedBuilder(
                animation: projectProvider.notifier,
                builder: (context, child) {
                  return Transform(
                    transform: projectProvider.notifier.value,
                    child: ItemStackBuilder(widget.project.projectId),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}

class ItemStackBuilder extends StatefulWidget {
  final id;
  ItemStackBuilder(this.id);

  @override
  _ItemStackBuilderState createState() => _ItemStackBuilderState();
}

class _ItemStackBuilderState extends State<ItemStackBuilder>
    with AfterLayoutMixin<ItemStackBuilder> {
  bool isExec = true;
  var _backgroundStackKey = new GlobalKey();
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    var projectProvider = Provider.of<Project>(context, listen: false);
    projectProvider.setInitialStackSizeAndOffset();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var crudProvider = Provider.of<CRUDModel>(context);
    var stackScale = projectProvider.stackScale;
    projectProvider.backgroundStackKey = _backgroundStackKey;

    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
            key: _backgroundStackKey,
            decoration: new BoxDecoration(
              border: Border.all(color: Colors.grey[900]),
              borderRadius: BorderRadius.circular(3),
            ),
            width: projectProvider.stackSize.width,
            height: projectProvider.stackSize.height,
            child: GestureDetector(
              onTap: () {
                //remove focus
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                projectProvider.unselectAll();
              },
            ),
          );
        },
        onWillAccept: (dynamic data) {
          if ("parentApplet" != data.id
              //&& !projectProvider.appletMap[data.id].childIds.contains(null)  &&

              /*!projectProvider.appletMap["parentApplet"].childIds
            .contains(data.id)*/
              ) {
            projectProvider.targetId = "parentApplet";
            var stackOffset = Offset(projectProvider.notifier.value.row0.a,
                projectProvider.notifier.value.row1.a);
            double _scaleChange = projectProvider.appletMap[data.id].scale;
            projectProvider.appletMap[data.id].scale = 1.0;
            projectProvider.currentTargetPosition = stackOffset;
            projectProvider.changeItemListPosition(
                itemId: data.id, newId: "parentApplet", applet: data);

            projectProvider.scaleChange =
                projectProvider.appletMap[data.id].scale / _scaleChange;

            if (data.type == "WindowApplet") {
              List<Key> childrenList =
                  Provider.of<Project>(context, listen: false)
                      .getAllChildren(applet: data);
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
            }
            return true;
          } else {
            return false;
          }
        },
        onLeave: (dynamic data) {},
        onAccept: (dynamic data) {
          projectProvider.updateApplet(
              applet: projectProvider.appletMap["parentApplet"],
              targetId: "parentApplet",
              originId: projectProvider.originId);
          if (data.type == 'TextApplet') {
            projectProvider.appletMap[data.id].scale = 1.0;
            if (projectProvider.appletMap[data.id].selected == true) {
              projectProvider.appletMap[data.id].fixed = true;
              projectProvider.appletMap[data.id].position = Offset(10, 10);
              projectProvider.appletMap[data.id].size =
                  projectProvider.appletMap["parentApplet"].size * 0.9;
            } else {
              projectProvider.appletMap[data.id].fixed = false;
            }
            projectProvider.appletMap["parentApplet"].selected = false;
          }
          projectProvider.updateApplet(
              applet: data,
              targetId: "parentApplet",
              originId: projectProvider.originId);
        },
      ),
      ...stackItems(context),
      ...arrowItems(context),
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    List<Widget> stackItemsList = [];
    Widget stackItemDraggable;
    List childIdList = [];
    List<GlobalKey> childKeyList = [];
    if (projectProvider.appletMap["parentApplet"] != null) {
      childIdList = projectProvider.appletMap["parentApplet"].childIds;
      childKeyList = projectProvider.appletMap["parentApplet"].childIds
          .map((e) => projectProvider.getGlobalKeyFromId(e))
          .toList();
    }

    for (int i = 0; i < childIdList.length; i++) {
      if (projectProvider.appletMap[childIdList[i]].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(key: childKeyList[i]);
      } else if (projectProvider.appletMap[childIdList[i]].type ==
          "TextApplet") {
        stackItemDraggable = TextboxWidget(key: childKeyList[i]);
      } else {
        stackItemDraggable = Container(color: Colors.blue, width: 0, height: 0);
      }

      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}

List<Widget> arrowItems(BuildContext context) {
  var projectProvider = Provider.of<Project>(context);
  List<Widget> arrowItemsList = [];
  List<Applet> appletList = projectProvider.appletMap.values.toList();
  Key originKey;
  Key targetKey;
  for (int i = 0; i < appletList.length; i++) {
    if (appletList[i].arrowMap != null) {
      appletList[i].arrowMap.forEach((String id, Arrow arrow) => {
            originKey = projectProvider.getKeyFromId(appletList[i].id),
            if (originKey != null)
              {
                targetKey = projectProvider.getKeyFromId(id),
                arrowItemsList.add(ArrowWidget(originKey, targetKey)),
              }
          });
    }
  }
  return arrowItemsList;
}
