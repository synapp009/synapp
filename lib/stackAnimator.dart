import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'itemStackBuilder.dart';

import 'data.dart';

class StackAnimator extends StatelessWidget {
final id;
  StackAnimator(this.id);
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);

    Size displaySize = MediaQuery.of(context).size;
    ValueNotifier<Matrix4> notifier = dataProvider.notifier;

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
      List keyAtBottomList = dataProvider.structureMap[null].childKeys;

      mostBottomKey = keyAtBottomList[0];
      mostLeftKey = keyAtBottomList[0];
      mostRightKey = keyAtBottomList[0];
      mostTopKey = keyAtBottomList[0];
      for (int i = 0; i < keyAtBottomList.length; i++) {
        if ((dataProvider.structureMap[keyAtBottomList[i]].position.dx +
                dataProvider.structureMap[keyAtBottomList[i]].size.width) >
            (dataProvider.structureMap[mostRightKey].position.dx +
                dataProvider.structureMap[mostRightKey].size.width)) {
          mostRightKey = keyAtBottomList[i];
        }
        if (dataProvider.structureMap[keyAtBottomList[i]].position.dx <
            dataProvider.structureMap[mostLeftKey].position.dx) {
          mostLeftKey = keyAtBottomList[i];
        }

        if ((dataProvider.structureMap[keyAtBottomList[i]].position.dy) <
            dataProvider.structureMap[mostTopKey].position.dy) {
          mostTopKey = keyAtBottomList[i];
        }
        if ((dataProvider.structureMap[keyAtBottomList[i]].position.dy +
                dataProvider.structureMap[keyAtBottomList[i]].size.height) >
            dataProvider.structureMap[mostTopKey].position.dy +
                dataProvider.structureMap[mostTopKey].size.height) {
          mostBottomKey = keyAtBottomList[i];
        }
      }

      maxLeftOffset = dataProvider.structureMap[mostLeftKey].position.dx *
          dataProvider.stackScale;

      maxRightOffset = dataProvider.structureMap[mostRightKey].position.dx;

      maxTopOffset = dataProvider.structureMap[mostTopKey].position.dy *
          dataProvider.stackScale;

//set max scale
      maxScaleWidth = (displaySize.width / 
          (dataProvider.structureMap[mostLeftKey].position.dx +
              dataProvider.structureMap[mostRightKey].position.dx +
              dataProvider.structureMap[mostRightKey].size.width));

      maxScaleHeight = (displaySize.height /
          (dataProvider.structureMap[mostLeftKey].position.dy +
              dataProvider.structureMap[mostRightKey].position.dy +
              dataProvider.structureMap[mostRightKey].size.height +
              dataProvider.headerHeight()));

      maxScale =
          maxScaleHeight < maxScaleWidth ? maxScaleHeight : maxScaleWidth;

      if (dataProvider.structureMap[null].childKeys.length > 1) {
        if (dataProvider.stackScale < maxScale) {
          notifier.value.setEntry(0, 0, maxScale);
          notifier.value.setEntry(1, 1, maxScale);
        }

        if (dataProvider.stackOffset.dx >
            -maxLeftOffset + displaySize.width / 2) {
          //left offset barrier

          notifier.value.setEntry(0, 3, -maxLeftOffset + displaySize.width / 2);
        }
        if ((dataProvider.stackOffset.dx +
                dataProvider.structureMap[mostRightKey].position.dx *
                    dataProvider.stackScale +
                dataProvider.structureMap[mostRightKey].size.width *
                    dataProvider.stackScale) <
            displaySize.width / 2) {
          var tempOffsetRightDx =
              -(dataProvider.structureMap[mostRightKey].position.dx *
                      dataProvider.stackScale +
                  dataProvider.structureMap[mostRightKey].size.width *
                      dataProvider.stackScale -
                  displaySize.width / (1.99));
          notifier.value.setEntry(0, 3, tempOffsetRightDx);
        }

        if (dataProvider.stackOffset.dy >
            -maxTopOffset + displaySize.height / 2) {
          //top offset barrier
          notifier.value.setEntry(1, 3, -maxTopOffset + displaySize.height / 2);
        }
      }
    }

    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        //notifier.value = m;

        dataProvider.stackScale = notifier.value.row0[0];

        dataProvider.stackOffset =
            Offset(notifier.value.row0.a, notifier.value.row1.a);

        notifier.value = m;
        setMaxScaleAndOffset(context);
      },
      shouldRotate: false,
      child: Stack(children: [
        Container(color: Colors.transparent),
        Positioned(
          top: dataProvider.generalStackOffset.dy,
          left: dataProvider.generalStackOffset.dx,
          child: AnimatedBuilder(
              animation: Provider.of<Data>(context).notifier,
              builder: (ctx, child) {
                return Transform(
                  transform: Provider.of<Data>(context).notifier.value,
                  child: ItemStackBuilder(id),
                );
              }),
        ),
      ]),
    );
  }
}
