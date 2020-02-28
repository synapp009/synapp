import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'core/models/projectModel.dart';
import 'itemStackBuilder.dart';

class StackAnimator extends StatelessWidget {
  final id;
  StackAnimator(this.id);
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    Size displaySize = MediaQuery.of(context).size;
    ValueNotifier<Matrix4> notifier = projectProvider.notifier;
    setMaxScaleAndOffset(context) {
      //sets the boundaries of the visable part of the screen
      // and the maximum scale to zoom out

      var maxScale;
      var maxScaleWidth;
      var maxScaleHeight;
      var maxLeftOffset;
      var maxRightOffset;
      var maxTopOffset;
      var mostLeftKey;
      var mostRightKey;
      var mostTopKey;
      var mostBottomKey;
      List keyAtBottomList = projectProvider.appletMap[null].childKeys;
      mostBottomKey = keyAtBottomList[0];
      mostLeftKey = keyAtBottomList[0];
      mostRightKey = keyAtBottomList[0];
      mostTopKey = keyAtBottomList[0];
      for (int i = 0; i < keyAtBottomList.length; i++) {
        if ((projectProvider.appletMap[projectProvider.getIdFromKey( keyAtBottomList[i])].position.dx +
                projectProvider.appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])].size.width) >
            (projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx +
                projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].size.width)) {
          mostRightKey = keyAtBottomList[i];
        }
        if (projectProvider.appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])].position.dx <
            projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)].position.dx) {
          mostLeftKey = keyAtBottomList[i];
        }

        if ((projectProvider.appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])].position.dy) <
            projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)].position.dy) {
          mostTopKey = keyAtBottomList[i];
        }
        if ((projectProvider.appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])].position.dy +
                projectProvider.appletMap[projectProvider.getIdFromKey(keyAtBottomList[i])].size.height) >
            projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)].position.dy +
                projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)].size.height) {
          mostBottomKey = keyAtBottomList[i];
        }
      }

      maxLeftOffset = projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)].position.dx *
          projectProvider.stackScale;

      maxRightOffset = projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx;

      maxTopOffset = projectProvider.appletMap[projectProvider.getIdFromKey(mostTopKey)].position.dy *
          projectProvider.stackScale;

//set max scale
      maxScaleWidth = (displaySize.width /
          (projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)].position.dx +
              projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx +
              projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].size.width));

      maxScaleHeight = (displaySize.height /
          (projectProvider.appletMap[projectProvider.getIdFromKey(mostLeftKey)].position.dy +
              projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dy +
              projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].size.height +
              projectProvider.headerHeight()));

      maxScale =
          maxScaleHeight < maxScaleWidth ? maxScaleHeight : maxScaleWidth;

      if (projectProvider.appletMap[null].childKeys.length > 1) {
        if (projectProvider.stackScale < maxScale) {
          notifier.value.setEntry(0, 0, maxScale);
          notifier.value.setEntry(1, 1, maxScale);
        }

        if (projectProvider.stackOffset.dx >
            -maxLeftOffset + displaySize.width / 2) {
          //left offset barrier

          notifier.value.setEntry(0, 3, -maxLeftOffset + displaySize.width / 2);
        }
        if ((projectProvider.stackOffset.dx +
                projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx *
                    projectProvider.stackScale +
                projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].size.width *
                    projectProvider.stackScale) <
            displaySize.width / 2) {
          var tempOffsetRightDx =
              -(projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].position.dx *
                      projectProvider.stackScale +
                  projectProvider.appletMap[projectProvider.getIdFromKey(mostRightKey)].size.width *
                      projectProvider.stackScale -
                  displaySize.width / (1.99));
          notifier.value.setEntry(0, 3, tempOffsetRightDx);
        }

        if (projectProvider.stackOffset.dy >
            -maxTopOffset + displaySize.height / 2) {
          //top offset barrier
          notifier.value.setEntry(1, 3, -maxTopOffset + displaySize.height / 2);
        }
      }
    }

    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        //notifier.value = m;

        projectProvider.stackScale = notifier.value.row0[0];
        projectProvider.stackOffset =
            Offset(notifier.value.row0.a, notifier.value.row1.a);

        notifier.value = m;
        setMaxScaleAndOffset(context);
      },
      shouldRotate: false,
      child: Stack(children: [
        Container(color: Colors.transparent),
        Positioned(
          top: projectProvider.generalStackOffset.dy,
          left: projectProvider.generalStackOffset.dx,
          child: AnimatedBuilder(
              animation: Provider.of<Project>(context).notifier,
              builder: (context, child) {
                return Transform(
                  transform: Provider.of<Project>(context).notifier.value,
                  child: ItemStackBuilder(id),
                );
              }),
        ),
      ]),
    );
  }
}
