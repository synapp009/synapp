import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'package:zefyr/zefyr.dart';
import 'core/models/projectModel.dart';

import 'package:flutter/rendering.dart';

import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';

import 'core/models/arrowModel.dart';
import 'textboxWidget.dart';

import 'windowWidget.dart';
import 'arrowWidget.dart';

class StackAnimator extends StatelessWidget {
  final id;
  StackAnimator(this.id);
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    Size displaySize = MediaQuery.of(context).size;
    ValueNotifier<Matrix4> notifier;

    if (projectProvider.notifier == null) {
      projectProvider.notifier = Constants.initializeNotifier(notifier);
    }
    notifier = projectProvider.notifier;

    //get the outer keys
    List<Key> getOuterKeysAsList(keyAtBottomList) {
      Key mostLeftKey;
      Key mostRightKey;
      Key mostTopKey;
      Key mostBottomKey;

      mostBottomKey =
          mostLeftKey = mostRightKey = mostTopKey = keyAtBottomList[0];

      for (int i = 0; i < keyAtBottomList.length; i++) {
        //getting most right key
        if ((projectProvider
                    .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                    .position
                    .dx +
                projectProvider
                    .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                    .size
                    .width) >
            (projectProvider
                    .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                    .position
                    .dx +
                projectProvider
                    .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                    .size
                    .width)) {
          mostRightKey = keyAtBottomList[i];
        }

//getting most left key
        if (projectProvider
                .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                .position
                .dx <
            projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)]
                .position.dx) {
          mostLeftKey = keyAtBottomList[i];
        }

//getting most top key
        if ((projectProvider
                .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                .position
                .dy) <
            projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)]
                .position.dy) {
          mostTopKey = keyAtBottomList[i];
        }

//getting most bottom key
        if ((projectProvider
                    .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                    .position
                    .dy +
                projectProvider
                    .appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])]
                    .size
                    .height) >
            projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)]
                    .position.dy +
                projectProvider
                    .appletMap[projectProvider.getIdFromKey(mostTopKey)]
                    .size
                    .height) {
          mostBottomKey = keyAtBottomList[i];
        }
      }
      return [mostRightKey, mostBottomKey, mostLeftKey, mostTopKey];
    }

    List<double> getMaxOffset(List<Key> getOuterKeysAsList) {
      var mostRightKey = getOuterKeysAsList[0];
      var mostBottomKey = getOuterKeysAsList[1];
      var mostLeftKey = getOuterKeysAsList[2];
      var mostTopKey = getOuterKeysAsList[3];

      var maxLeftOffset;
      var maxRightOffset;
      var maxTopOffset;
      var maxBottomOffset;

      maxLeftOffset = projectProvider
              .appletMap[projectProvider.getIdFromKey(mostLeftKey)]
              .position
              .dx *
          projectProvider.stackScale;

      maxRightOffset = projectProvider
          .appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx;

      maxTopOffset = projectProvider
              .appletMap[projectProvider.getIdFromKey(mostTopKey)].position.dy *
          projectProvider.stackScale;

      maxBottomOffset = projectProvider
              .appletMap[projectProvider.getIdFromKey(mostBottomKey)]
              .position
              .dy *
          projectProvider.stackScale;

      return [maxRightOffset, maxBottomOffset, maxLeftOffset, maxTopOffset];
    }

    //set scroll barrier
    void setMaxOffset(List<Key> getOuterKeysAsList) {
      List<double> maxOffset = getMaxOffset(getOuterKeysAsList);

      var maxRightOffset = maxOffset[0];
      var maxBottomOffset = maxOffset[1];
      var maxLeftOffset = maxOffset[2];
      var maxTopOffset = maxOffset[3];

      var mostRightKey = getOuterKeysAsList[0];
      var mostBottomKey = getOuterKeysAsList[1];
      var mostLeftKey = getOuterKeysAsList[2];
      var mostTopKey = getOuterKeysAsList[3];

//left offset barrier
      if (projectProvider.stackOffset.dx >
          -maxLeftOffset + displaySize.width / 2) {
        notifier.value.setEntry(0, 3, -maxLeftOffset + displaySize.width / 2);
      }

      if ((projectProvider.stackOffset.dx +
              projectProvider
                      .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                      .position
                      .dx *
                  projectProvider.stackScale +
              projectProvider
                      .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                      .size
                      .width *
                  projectProvider.stackScale) <
          displaySize.width / 2) {
        var tempOffsetRightDx = -(projectProvider
                    .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                    .position
                    .dx *
                projectProvider.stackScale +
            projectProvider
                    .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                    .size
                    .width *
                projectProvider.stackScale -
            displaySize.width / (1.99));
        notifier.value.setEntry(0, 3, tempOffsetRightDx);
      }

//top offset barrier
      if (projectProvider.stackOffset.dy >
          -maxTopOffset + displaySize.height / 2) {
        notifier.value.setEntry(1, 3, -maxTopOffset + displaySize.height / 2);
      }

//top bottom barrier
      if (projectProvider.stackOffset.dy < -maxBottomOffset) {
        notifier.value.setEntry(1, 3, -maxBottomOffset);
      }
    }

    //set max scale
    void setMaxScale(List<Key> getOuterKeysAsList) {
      //set here the scale rate property you want
      var scaleRate = 0.3;
      var maxScale;
      var maxScaleWidth;
      var maxScaleHeight;
      //List<double> maxOffset = getMaxOffset(getOuterKeysAsList);

      var mostRightKey = getOuterKeysAsList[0];
      // var mostBottomKey = getOuterKeysAsList[1];
      var mostLeftKey = getOuterKeysAsList[2];
      //var mostTopKey = getOuterKeysAsList[3];

      maxScaleWidth = (displaySize.width /
          (projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)]
                  .position.dx +
              projectProvider
                  .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                  .position
                  .dx +
              projectProvider
                  .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                  .size
                  .width));

      maxScaleHeight = (displaySize.height /
          (projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)]
                  .position.dy +
              projectProvider
                  .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                  .position
                  .dy +
              projectProvider
                  .appletMap[projectProvider.getIdFromKey(mostRightKey)]
                  .size
                  .height +
              projectProvider.headerHeight()));

      maxScale =
          (maxScaleHeight < maxScaleWidth ? maxScaleHeight : maxScaleWidth) *
              scaleRate;

      if (projectProvider.appletMap["parentApplet"].childIds.length > 1) {
        if (projectProvider.stackScale < maxScale) {
          notifier.value.setEntry(0, 0, maxScale);
          notifier.value.setEntry(1, 1, maxScale);
        }
      }
    }

    setMaxScaleAndOffset(context) {
      List<GlobalKey> keyAtBottomList = projectProvider
          .appletMap["parentApplet"].childIds
          .map((e) => projectProvider.getGlobalKeyFromId(e))
          .toList();

      //sets the boundaries of the visable part of the screen
      // and the maximum scale to zoom out
      setMaxOffset(getOuterKeysAsList(keyAtBottomList));
      setMaxScale(getOuterKeysAsList(keyAtBottomList));
    }

    /* setStackSize() {
      //set the stack size when change stackoffset and scale to garuantee the possibility of drag and drop items

      projectProvider.stackSizeChange(null, Offset(0, 0));
      projectProvider.stackSizeChange(
        null,
        Offset(
            (displaySize.width / projectProvider.stackScale) +
                projectProvider.stackOffset.dx,
            0),
      );
      projectProvider.stackSizeChange(
        null,
        Offset(
            0,
            (displaySize.height / projectProvider.stackScale) +
                projectProvider.stackOffset.dy),
      );
    }*/

    return ZefyrScaffold(
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          //notifier.value = m;

          projectProvider.stackScale = notifier.value.row0[0];
          projectProvider.stackOffset =
              Offset(notifier.value.row0.a, notifier.value.row1.a);

          notifier.value = m;
          setMaxScaleAndOffset(context);
          //setStackSize();
        },
        shouldRotate: false,
        child: Stack(children: [
          Container(color: Colors.transparent),
          Positioned(
            top: projectProvider.generalStackOffset.dy,
            left: projectProvider.generalStackOffset.dx,
            child: AnimatedBuilder(
                animation: projectProvider.notifier,
                builder: (context, child) {
                  return Transform(
                    transform: projectProvider.notifier.value,
                    child: ItemStackBuilder(id),
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

class _ItemStackBuilderState extends State<ItemStackBuilder> {
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var crudProvider = Provider.of<CRUDModel>(context);
    var stackScale = projectProvider.stackScale;

    var _backgroundStackKey = new GlobalKey();
    projectProvider.backgroundStackKey = _backgroundStackKey;

    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
            key:_backgroundStackKey,
            color: Colors.green,
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
          print('"parentApplet" != data.id ${"parentApplet" != data.id}');
          print(
              "!projectProvider.appletMap['parentApplet'].childIds.contains(data.id) ${!projectProvider.appletMap['parentApplet'].childIds.contains(data.id)}");
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
            print('no accept');
            return false;
          }
        },
        onLeave: (dynamic data) {},
        onAccept: (dynamic data) {
          print('help ${projectProvider.originId}, data ${data.position}');

          projectProvider.updateApplet(
              projectProvider.appletMap["parentApplet"],
              "parentApplet",
              projectProvider.originId);
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
              data, "parentApplet", projectProvider.originId);
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
