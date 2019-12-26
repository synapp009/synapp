import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'itemStackBuilder.dart';

import 'data.dart';

class StackAnimator extends StatefulWidget {
  @override
  _StackAnimatorState createState() => _StackAnimatorState();
}

class _StackAnimatorState extends State<StackAnimator> {
 Matrix4 matrix = Matrix4.identity();
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    Provider.of<Data>(context).notifier = notifier;
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        //notifier.value = m;
        print(notifier.value);
        Provider.of<Data>(context).notifier.value = m;
        Provider.of<Data>(context).stackScale = notifier.value.row0[0];
        Provider.of<Data>(context).stackOffset =
            Offset(notifier.value.row0.a, notifier.value.row1.a);
      },
      shouldRotate: false,
      child: AnimatedBuilder(
        animation: Provider.of<Data>(context).notifier,
        builder: (ctx, child) {
          return Transform(
            transform: Provider.of<Data>(context).notifier.value,
            child: ItemStackBuilder(),
          );
        },
      ),
    );
  }
}
