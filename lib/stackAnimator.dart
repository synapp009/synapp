import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'itemStackBuilder.dart';

import 'data.dart';

class StackAnimator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var maxScale;
    var maxLeftOffset;
    var maxRightOffset;
    var maxTopOffset;
    var mostLeftKey;
    var mostRightKey;
    var mostTopKey;
    Size displaySize = MediaQuery.of(context).size;
    setMaxScaleAndOffset(context) {
      var mostBottomKey;

      List keyAtBottomList = dataProvider.structureMap[null].childKeys;

      for (int i = 0; i < keyAtBottomList.length - 1; i++) {
        if ((dataProvider.structureMap[keyAtBottomList[i]].position.dx +
                dataProvider.structureMap[keyAtBottomList[i + 1]].size.width) >
            (dataProvider.structureMap[keyAtBottomList[i + 1]].position.dx +
                dataProvider.structureMap[keyAtBottomList[i + 1]].size.width)) {
          mostLeftKey = keyAtBottomList[i + 1];
          mostRightKey = keyAtBottomList[i];
        } else {
          mostLeftKey = keyAtBottomList[i];
          mostRightKey = keyAtBottomList[i + 1];
        }
        if ((dataProvider.structureMap[keyAtBottomList[i]].position.dy -
                dataProvider.structureMap[keyAtBottomList[i]].size.height) >
            (dataProvider.structureMap[keyAtBottomList[i + 1]].position.dy -
                dataProvider
                    .structureMap[keyAtBottomList[i + 1]].size.height)) {
          mostTopKey = keyAtBottomList[i + 1];
          mostBottomKey = keyAtBottomList[i];
        } else {
          mostBottomKey = keyAtBottomList[i + 1];
          mostTopKey = keyAtBottomList[i];
        }
      }
      /*     print('mostTopKey $mostTopKey');
      print('mostBottomKey $mostBottomKey');
      print('mostLeftKey $mostLeftKey');
      print('mostRightKey $mostRightKey');*/

      maxLeftOffset = ((dataProvider.getPositionOfRenderBox(mostLeftKey)) +
              Offset(0, 100) +
              dataProvider.stackOffset) *
          dataProvider.stackScale;

      maxRightOffset = (Offset(
                  dataProvider.getPositionOfRenderBox(mostRightKey).dx +
                      dataProvider.sizeOfRenderBox(mostRightKey).width,
                  dataProvider.getPositionOfRenderBox(mostRightKey).dy) +
              dataProvider.stackOffset) /
          dataProvider.stackScale *
          1.25;

      maxTopOffset = (dataProvider.getPositionOfRenderBox(mostTopKey) +
              dataProvider.stackOffset) *
          dataProvider.stackScale *
          1.25;

      maxScale = 1 /
          (displaySize.width /
              (dataProvider.structureMap[mostLeftKey].position.dx +
                  dataProvider.structureMap[mostRightKey].position.dx +
                  dataProvider.structureMap[mostRightKey].size.width) *
              1.25);
    }

    ValueNotifier<Matrix4> notifier = dataProvider.notifier;
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        //notifier.value = m;
        setMaxScaleAndOffset(context);

        dataProvider.stackScale = notifier.value.row0[0];

        dataProvider.stackOffset =
            Offset(notifier.value.row0.a, notifier.value.row1.a);

        // print('maxscale ${m.row0.a}');

        notifier.value = m;

        if (dataProvider.stackScale < maxScale) {
          notifier.value.setEntry(0, 0, maxScale);
          notifier.value.setEntry(1, 1, maxScale);
        }

        if (dataProvider.stackOffset.dx + displaySize.width * 0.1 <
            maxLeftOffset.dx) {
              print('left max');
          var tempOffsetLeftDx =
              (0 - dataProvider.structureMap[mostLeftKey].position.dx);
          print(tempOffsetLeftDx);
          tempOffsetLeftDx = tempOffsetLeftDx + displaySize.width * 0.1;
          notifier.value.setEntry(
            0,
            3,
            tempOffsetLeftDx,
          );
        }
        if (dataProvider.stackOffset.dx +
                (dataProvider.stackSize.width / dataProvider.stackScale) >
            maxRightOffset.dx - displaySize.width * 0.1) {
              print('rght max');
          /*var tempOffsetRightDx =
              (dataProvider.structureMap[mostRightKey].position.dx);
          notifier.value.setEntry(
            0,
            3,
            tempOffsetRightDx,
          );*/
        }

        if (dataProvider.stackOffset.dy < maxTopOffset.dy) {
          print('top max');
        }
      },
      shouldRotate: false,
      child: Stack(children: [
        Container(color: Colors.transparent),
        Positioned(
          top: dataProvider.generalStackOffset.dy,
          left: dataProvider.generalStackOffset.dx,
          child: AnimatedBuilder(
              animation: notifier,
              builder: (ctx, child) {
                return Transform(
                  transform: notifier.value,
                  child: ItemStackBuilder(),
                );
              }),
        ),
      ]),
    );
  }
}
