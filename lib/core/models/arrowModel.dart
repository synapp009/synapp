import 'dart:math';

import 'package:angles/angles.dart';
import 'package:flutter/material.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';

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

  Arrow.fromMap(dynamic snapshot)
      : originId = snapshot["originId"],
        target = snapshot["target"],
        arrowed = snapshot["arrowed"] == "true" ? true : false;
  //position = _positionFromMap(project, appletSnapshot, snapshot);
  //size = _sizeFromMap(project, appletId, snapshot);
  //angle = _angleFromMap(project, appletId, snapshot);
  /*position = Offset((snapshot["positionDx"] as num).toDouble(),
            (snapshot["positionDy"] as num).toDouble()),
        size = (snapshot["size"] as num).toDouble(),
        angle = Angle.fromDegrees((snapshot["angle"] as num).toDouble())*/

  toJson() {
    return {
      "target": target,
      "arrowed": arrowed.toString(),
      "originId": originId,
      //"positionDx": position.dx,
      //"positionDy": position.dy,
      //"size": size,
      //"angle": angle.degrees,
    };
  }

  void addArrow(String appletId, Project project) {
    //adds an Arrow to the list of arrows from origin widget to null

    if (project.appletMap[appletId].arrowMap == null) {
      project.appletMap[appletId].arrowMap = {};
    }

    var getPosition =
        (project.centerOfRenderBox(appletId) + project.stackOffset) /
            project.stackScale;
    getPosition = Offset(getPosition.dx,
        getPosition.dy - project.headerHeight() * project.stackScale);

    project.appletMap[appletId].arrowMap["parentApplet"] = Arrow(
      originId: appletId,
      arrowed: false,
      target: "parentApplet",
      size: 0.0,
      position: getPosition,
      angle: Angle.fromRadians(0),
    );
  }

  static Angle getAngle(Offset pointA, Offset pointB, headerHeight) {
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

  static double diagonalLength(Offset pointA, Offset pointB, headerHeight) {
    var tempSize =
        Size((pointA.dx - pointB.dx), (pointA.dy - pointB.dy - headerHeight));

    var length = ((tempSize.width * tempSize.width) +
        (tempSize.height * tempSize.height));
    return length = sqrt(length);
  }

  void setArrowToPointer(
      String startId, Offset actualPointer, Project project) {
    //set the size and ancle of the Arrow between widget and pointer
    //from center of a RenderBox (startKey)

    var itemScale = project.appletMap[startId].scale;
    var itemOffset = project.centerOfRenderBox(startId);

    var length =
        diagonalLength(actualPointer, itemOffset, project.headerHeight());

    position = (itemOffset - project.stackOffset) / project.stackScale;
    size = length / project.stackScale;
    angle = getAngle(itemOffset, actualPointer, project.headerHeight());
  }

  updateArrow({
    Project project,
    GlobalKey originKey,
    GlobalKey feedbackKey,
    GlobalKey targetKey,
    GlobalKey draggedKey,
  }) {
    String targetId;
    if (originKey != null) {
      originId = project.getIdFromKey(originKey);
    } else {
      originKey = project.getKeyFromId(originId);
    }
    if (targetKey != null) {
      targetId = project.getIdFromKey(targetKey);
    } else {
      targetId = target;
      targetKey= project.getKeyFromId(targetId);
    }

    Offset globalStackChange =
        project.globalStackPositionChange * project.stackScale;

//get size and arrow of origin and target
    var originPosition;
    var originSize;
    if (originKey.currentContext != null) {
      RenderBox originRenderBox = originKey.currentContext.findRenderObject();
      originPosition = project.getPositionOfRenderBox(originKey);
      originPosition = Offset(originPosition.dx, originPosition.dy);
      originSize =
          Size(originRenderBox.size.width, originRenderBox.size.height);
    } else if (originKey.currentContext == null) {
      originPosition = project.appletMap[originId].position;
      originSize = project.appletMap[originId].size;
    }
    originPosition = Offset(
          originPosition.dx + (originSize.width / 2) * project.stackScale,
          originPosition.dy + (originSize.height / 2) * project.stackScale,
        ) -
        globalStackChange;

    var targetPosition;
    var targetSize;
    if (targetKey.currentContext != null) {
      RenderBox targetRenderBox = targetKey.currentContext.findRenderObject();
      targetPosition = project.getPositionOfRenderBox(targetKey);
      targetSize =
          Size(targetRenderBox.size.width, targetRenderBox.size.height);
    } else if (originKey.currentContext == null) {
      targetPosition = project.appletMap[targetId].position;
      targetSize = project.appletMap[targetId].size;
    }
    targetPosition = Offset(
          targetPosition.dx + (targetSize.width / 2) * project.stackScale,
          targetPosition.dy + (targetSize.height / 2) * project.stackScale,
        ) -
        globalStackChange;

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

    if (draggedKey == originKey) {
      //if origin gets tragged, use feedback as origin
      angle = getAngle(
          feedbackPosition,
          Offset(targetPosition.dx, targetPosition.dy + project.headerHeight()),
          project.headerHeight());
      feedbackEdgeOffset = getEdgeOffset(
          project.stackScale, feedbackPosition, feedbackSize, angle);
      targetEdgeOffset =
          getEdgeOffset(project.stackScale, targetPosition, targetSize, angle);

      size = diagonalLength(
              Offset(
                  targetPosition.dx - targetEdgeOffset.dx,
                  targetPosition.dy -
                      targetEdgeOffset.dy +
                      project.headerHeight()),
              feedbackPosition + feedbackEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      position = (feedbackPosition + feedbackEdgeOffset - project.stackOffset) /
          project.stackScale;
    } else if (draggedKey == targetKey) {
      //if target gets tragged, use feedback as target

      angle = getAngle(
          Offset(originPosition.dx, originPosition.dy - project.headerHeight()),
          feedbackPosition,
          project.headerHeight());

      originEdgeOffset =
          getEdgeOffset(project.stackScale, originPosition, originSize, angle);
      feedbackEdgeOffset = getEdgeOffset(
          project.stackScale, feedbackPosition, feedbackSize, angle);
      size = diagonalLength(
              Offset(
                  originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy +
                      originEdgeOffset.dy +
                      project.headerHeight()),
              feedbackPosition - feedbackEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      position = ((originPosition + originEdgeOffset) - project.stackOffset) /
          project.stackScale;
    } else {
      angle = getAngle(
          Offset(originPosition.dx, originPosition.dy),
          Offset(targetPosition.dx, targetPosition.dy + project.headerHeight()),
          project.headerHeight());

      targetEdgeOffset =
          getEdgeOffset(project.stackScale, targetPosition, targetSize, angle);
      originEdgeOffset =
          getEdgeOffset(project.stackScale, originPosition, originSize, angle);
      size = diagonalLength(
              Offset(
                  originPosition.dx + originEdgeOffset.dx,
                  originPosition.dy +
                      originEdgeOffset.dy +
                      project.headerHeight()),
              targetPosition - targetEdgeOffset,
              project.headerHeight()) /
          project.stackScale;
      position = ((originPosition + originEdgeOffset) - project.stackOffset) /
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
    Arrow tempArrow;
    project.appletMap.forEach((String id, Applet applet) => {
          if (id != itemId && applet.selected == true)
            {
              targetId = id,
              targetKey = applet.key,
              positionOfTarget = project.centerOfRenderBox(id),
              positionOfTarget = Offset(positionOfTarget.dx,
                  positionOfTarget.dy + project.headerHeight()),
              // project.setArrowToPointer(itemId, positionOfTarget),
              applet.selected = false,
              //selectedMap[itemId] = false,
              target = targetId,
              project.appletMap[itemId].arrowMap[targetId] = this,
              project.appletMap[itemId].arrowMap.remove('parentApplet'),
              project.updateArrow(originKey: itemKey, targetKey: targetKey),

              project.updateApplet(applet: project.appletMap[itemId]),
            }
        });
    project.appletMap[itemId].arrowMap.remove('parentApplet');
    /*for (int i = 0; i < project.appletMap[itemId].arrowMap.length; i++) {
      if (project.appletMap[itemId].arrowList[i].target == "parentApplet") {
        project.appletMap[itemId].arrowList.removeAt(i);
      }
    }*/
  }

  List<Applet> getAllArrowApplets(Project project, Key key) {
    //get all arrows pointing to or coming from the item and also it's children items
    List<Applet> hasArrowToMovingApplet = [];
    var movingAppletId = project.getIdFromKey(key);

    List<String> allIds = project
        .getAllChildren(applet: project.appletMap[movingAppletId])
        .toList();
    allIds.add(movingAppletId);

    allIds.forEach((String idFromAllIds) {
      project.appletMap.forEach((String appletId, Applet applet) {
        if ((appletId == idFromAllIds && applet.arrowMap != null) ||
            applet.arrowMap.containsKey(idFromAllIds)) {
          hasArrowToMovingApplet.add(applet);
        }
      });
    });

    return hasArrowToMovingApplet;
  }

  updateArrowToKeyMap(
      Project project, Key key, bool dragStarted, Key feedbackKey) {
    var movingAppletId = project.getIdFromKey(key);
    List<Applet> hasArrowToMovingApplet = getAllArrowApplets(project, key);
    var targetKey;
    hasArrowToMovingApplet.forEach((Applet applet) => {
          applet.arrowMap.forEach((String targetId, Arrow arrow) => {
                targetKey = project.getKeyFromId(targetId),
                if (dragStarted && applet.key == key)
                  {
                    project.updateArrow(
                      originKey: applet.key,
                      feedbackKey: feedbackKey,
                      targetKey: targetKey,
                      draggedKey: applet.key,
                    )
                  }
                else if (dragStarted && targetKey == key)
                  {
                    project.updateArrow(
                        originKey: applet.key,
                        feedbackKey: feedbackKey,
                        targetKey: targetKey,
                        draggedKey: targetKey)
                  }
                else
                  {
                    project.updateArrow(
                        originKey: applet.key,
                        feedbackKey: feedbackKey,
                        targetKey: targetKey,
                        draggedKey: feedbackKey)
                  }
              }),
        });
  }
}
