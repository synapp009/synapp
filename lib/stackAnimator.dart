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
        if (notifier.value.row0[0] > dataProvider.maxScale) {
          notifier.value = m;
          dataProvider.stackScale = notifier.value.row0[0];
          dataProvider.stackOffset =
              Offset(notifier.value.row0.a, notifier.value.row1.a);
        } else {
     
          notifier.value.row0[0] = dataProvider.maxScale*1.1;
        }
      },
      shouldRotate: false,
      child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child) {
            return Transform(
              transform: notifier.value,
              child: ItemStackBuilder(),
            );
          },
          child: ItemStackBuilder()),
    );
  }
}
