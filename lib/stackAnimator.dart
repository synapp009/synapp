import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'itemStackBuilder.dart';

import 'data.dart';

class StackAnimator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);

    dataProvider.maxScaleAndOffset(context);
    ValueNotifier<Matrix4> notifier = dataProvider.notifier;
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        //notifier.value = m;

        notifier.value = m;
        dataProvider.stackScale = notifier.value.row0[0];
        dataProvider.stackOffset =
            Offset(notifier.value.row0.a, notifier.value.row1.a);
      },
      shouldRotate: false,
      child: Stack(children: [
        Container(color: Color.fromARGB(100, 71, 2, 255),),
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
