import 'dart:math';

import 'package:angles/angles.dart';
import 'package:flutter/material.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/services/api.dart';

import '../../locator.dart';

class Arrow {
  String originId;
  String target;
  bool arrowed;
  Offset position;
  double size;
  Angle angle;
  Arrow(
      {this.originId,
      this.target,
      this.arrowed,
      this.position,
      this.size,
      this.angle});

  Arrow.fromMap(Map snapshot)
      : target = snapshot["target"],
        arrowed = snapshot["arrowed"] == "true",
        position = Offset((snapshot["positionDx"] as num).toDouble(),
            (snapshot["positionDy"] as num).toDouble()),
        size = (snapshot["size"] as num).toDouble(),
        angle = Angle.fromDegrees((snapshot["angle"] as num).toDouble());

  toJson() {
    return {
      "target": target,
      "arrowed": arrowed.toString(),
      "positionDx": position.dx,
      "positionDy": position.dy,
      "size": size,
      "angle": angle.degrees,
    };
  }

  void addArrow(String key, Project project) {
    //adds an Arrow to the list of arrows from origin widget to null
    if (project.arrowMap[key] == null) {
      project.arrowMap[key] = [];
    }
    var getPosition = (project.centerOfRenderBox(key) + project.stackOffset) /
        project.stackScale;
    getPosition = Offset(getPosition.dx,
        getPosition.dy - project.headerHeight() * project.stackScale);

    project.arrowMap[key].add(
      Arrow(
        arrowed: false,
        target: null,
        size: 0.0,
        position: getPosition,
        angle: Angle.fromRadians(0),
      ),
    );
  }

  Angle getAngle(Offset pointA, Offset pointB, headerHeight) {
    double tempAncle =
        (pointB.dy - pointA.dy - headerHeight) / (pointB.dx - pointA.dx);
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

  double diagonalLength(Offset pointA, Offset pointB, headerHeight) {
    var tempSize =
        Size((pointA.dx - pointB.dx), (pointA.dy - pointB.dy - headerHeight));

    var length = ((tempSize.width * tempSize.width) +
        (tempSize.height * tempSize.height));
    return length = sqrt(length);
  }

  void setArrowToPointer(Key startKey, Offset actualPointer, Project project) {
    //set the size and ancle of the Arrow between widget and pointer
    //from center of a RenderBox (startKey)
    Arrow arrow;
    String startId = project.getIdFromKey(startKey);
    project.arrowMap[startId]
        .forEach((k) => k.target == null ? arrow = k : null);
    var itemScale = project.appletMap[startId].scale;
    var itemOffset = project.centerOfRenderBox(startId);

    var length =
        diagonalLength(actualPointer, itemOffset, project.headerHeight());
    if (arrow != null) {
      arrow.position = (itemOffset - project.stackOffset) / project.stackScale;
      arrow.size = length / project.stackScale;
      arrow.angle = getAngle(itemOffset, actualPointer, project.headerHeight());
    }
  }

  updateArrow(
      {final Project project,
      final GlobalKey originKey,
      final GlobalKey feedbackKey,
      final GlobalKey targetKey,
      final GlobalKey draggedKey,
      final Map<Key, List<Key>> hasArrowToKeyMap}) {
    Arrow arrow;
    String originId = project.getIdFromKey(originKey);
    String targetId = project.getIdFromKey(targetKey);

//get size and arrow of origin and target
    RenderBox originRenderBox = originKey.currentContext.findRenderObject();
    var originPosition = project.getPositionOfRenderBox(originKey);
    originPosition = Offset(originPosition.dx, originPosition.dy);
    var originSize =
        Size(originRenderBox.size.width, originRenderBox.size.height);
    originPosition = Offset(
      originPosition.dx + (originSize.width / 2) * project.stackScale,
      originPosition.dy + (originSize.height / 2) * project.stackScale,
    );

    RenderBox targetRenderBox = targetKey.currentContext.findRenderObject();
    var targetPosition = project.getPositionOfRenderBox(targetKey);
    targetPosition = Offset(targetPosition.dx, targetPosition.dy);
    var targetSize =
        Size(targetRenderBox.size.width, targetRenderBox.size.height);
    targetPosition = Offset(
      targetPosition.dx + (targetSize.width / 2) * project.stackScale,
      targetPosition.dy + (targetSize.height / 2) * project.stackScale,
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
      feedbackPosition = project.getPositionOfRenderBox(feedbackKey);
      feedbackPosition = (Offset(
          feedbackPosition.dx + (feedbackSize.width / 2) * project.stackScale,
          feedbackPosition.dy +
              (feedbackSize.height / 2) * project.stackScale));
    }

//get correct arrow
    project.arrowMap[originId].forEach((v) => {
          if (v.target == targetId)
            {
              arrow = v,
            }
        });

//check if one (feedback, target or origin) is inside another
//hasArrowToKeyMap.forEach()

    if (draggedKey == originKey) {
      //if origin gets tragged, use feedback as origin
      arrow.angle = getAngle(
          feedbackPosition,
          Offset(targetPosition.dx, targetPosition.dy + project.headerHeight()),
          project.headerHeight());
      feedbackEdgeOffset = getEdgeOffset(
          project.stackScale, feedbackPosition, feedbackSize, arrow.angle);
      targetEdgeOffset = getEdgeOffset(
          project.stackScale, targetPosition, targetSize, arrow.angle);

      arrow.size = diagonalLength(
              Offset(
                  targetPosition.dx - targetEdgeOffset.dx,
                  targetPosition.dy -
                      targetEdgeOffset.dy +
                      project.headerHeight()),
              feedbackPosition + feedbackEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      arrow.position =
          (feedbackPosition + feedbackEdgeOffset - project.stackOffset) /
              project.stackScale;
    } else if (draggedKey == targetKey) {
      //if target gets tragged, use feedback as target

      arrow.angle = getAngle(
          Offset(originPosition.dx, originPosition.dy - project.headerHeight()),
          feedbackPosition,
          project.headerHeight());

      originEdgeOffset = getEdgeOffset(
          project.stackScale, originPosition, originSize, arrow.angle);
      feedbackEdgeOffset = getEdgeOffset(
          project.stackScale, feedbackPosition, feedbackSize, arrow.angle);
      arrow.size = diagonalLength(
              Offset(
                  originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy +
                      originEdgeOffset.dy +
                      project.headerHeight()),
              feedbackPosition - feedbackEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      arrow.position =
          ((originPosition + originEdgeOffset) - project.stackOffset) /
              project.stackScale;
    } else {
      arrow.angle = getAngle(
          Offset(originPosition.dx, originPosition.dy),
          Offset(targetPosition.dx, targetPosition.dy + project.headerHeight()),
          project.headerHeight());

      targetEdgeOffset = getEdgeOffset(
          project.stackScale, targetPosition, targetSize, arrow.angle);
      originEdgeOffset = getEdgeOffset(
          project.stackScale, originPosition, originSize, arrow.angle);
      arrow.size = diagonalLength(
              Offset(
                  originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy +
                      originEdgeOffset.dy +
                      project.headerHeight()),
              targetPosition - targetEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      arrow.position =
          ((originPosition + originEdgeOffset) - project.stackOffset) /
              project.stackScale;
    }
  }

  getEdgeOffset(stackScale, itemPosition, itemSize, Angle itemAngle) {
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

  connectAndUnselect(Project project, Key itemKey) {
    String itemId = project.getIdFromKey(itemKey);
    //connects two widgets with ArrowWidget, unselect all afterwards and delete  arrow if no target
    Offset positionOfTarget;
    String targetId;
    Key targetKey;
    project.appletMap.forEach((String id, Applet applet) => {
          if (id != itemId && applet.selected == true)
            {
              targetId = id,
              targetKey = applet.key,
              positionOfTarget = project.centerOfRenderBox(id),
              positionOfTarget = Offset(positionOfTarget.dx,
                  positionOfTarget.dy + project.headerHeight()),
              setArrowToPointer(itemKey, positionOfTarget, project),
              applet.selected = false,
              //selectedMap[itemId] = false,
              project.arrowMap[itemId].forEach((Arrow l) => {
                    if (l.target == null) {l.target = targetId}
                  }),
              updateArrow(originKey: itemKey, targetKey: targetKey)
            }
        });
    for (int i = 0; i < project.arrowMap[itemId].length; i++) {
      if (project.arrowMap[itemId][i].target == null) {
        project.arrowMap[itemId].removeAt(i);
      }
    }
  }

  getAllArrows(Project project, Key key) {
    //get all arrows pointing to or coming from the item and also it's children items
    bool keyIsTargetOrOrigin(k) {
      bool _tempBool = false;

      if (project.arrowMap[k] != null) {
        project.arrowMap[k].forEach((Arrow a) => {
              if (a.target == k)
                {
                  _tempBool = true,
                }
            });
      }

      project.arrowMap.forEach(
        ((String originId, List<Arrow> listOfArrows) => {
              listOfArrows.forEach((Arrow a) => {
                    if (a.target == k)
                      {
                        _tempBool = true,
                      }
                  }),
            }),
      );
      return _tempBool;
    }

    //all childItems pointing to or getting targetted
    List childList = project.getAllChildren(itemKey: key);
    childList.add(key);
    var originKey;
    var childId;
    childList.forEach((childKey) => {
          childId = project.getIdFromKey(childKey),
          project.arrowMap.forEach((String originId,
                  List<Arrow> listOfArrows) =>
              {
                originKey = project.getKeyFromId(originId),
                if (originKey != null)
                  {
                    listOfArrows.forEach((Arrow a) => {
                          if (a.target == childId &&
                              keyIsTargetOrOrigin(childKey))
                            {
                              if (project.hasArrowToKeyMap[originKey] == null)
                                {
                                  project.hasArrowToKeyMap[originKey] = [],
                                },
                              project.hasArrowToKeyMap[originKey].add(childKey),
                            }
                          else
                            {
                              if (a.target != null &&
                                  keyIsTargetOrOrigin(a.target))
                                {
                                  if (project.hasArrowToKeyMap[originKey] ==
                                      null)
                                    {
                                      project.hasArrowToKeyMap[originKey] = [],
                                    },
                                  project.hasArrowToKeyMap[originKey]
                                      .add(project.getKeyFromId(a.target)),
                                },
                            },
                        }),
                  }
              })
        });
  }

  updateArrowToKeyMap(
      Project project, Key key, bool dragStarted, Key feedbackKey) {
    project.hasArrowToKeyMap
        .forEach((Key originKey, List<Key> listOfTargets) => {
              listOfTargets.forEach((Key targetKey) => {
                    if (dragStarted && originKey == key)
                      {
                        updateArrow(
                          originKey: originKey,
                          feedbackKey: feedbackKey,
                          targetKey: targetKey,
                          draggedKey: originKey,
                          hasArrowToKeyMap: project.hasArrowToKeyMap,
                        )
                      }
                    else if (dragStarted && targetKey == key)
                      {
                        updateArrow(
                            originKey: originKey,
                            feedbackKey: feedbackKey,
                            targetKey: targetKey,
                            draggedKey: targetKey,
                            hasArrowToKeyMap: project.hasArrowToKeyMap)
                      }
                    else
                      {
                        updateArrow(
                            originKey: originKey,
                            feedbackKey: feedbackKey,
                            targetKey: targetKey,
                            draggedKey: feedbackKey,
                            hasArrowToKeyMap: project.hasArrowToKeyMap)
                      }
                  })
            });
  }
}
