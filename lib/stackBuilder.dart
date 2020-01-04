import 'package:flutter/material.dart';
import 'itemStackBuilder.dart';

import './transformations_gesture_transformable.dart';

class StackBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext contextLayout, BoxConstraints constraints) {
      // Draw the scene as big as is available, but allow the user to
      // translate beyond that to a visibleSize that's a bit bigger.
      final Size size = Size(constraints.maxWidth, constraints.maxHeight);
      final Size visibleSize = Size(size.width *3, size.height * 2);

      return GestureTransformable(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          onScaleEnd: (ScaleEndDetails detail) {},
          boundaryRect: Rect.fromLTWH(
            -visibleSize.width / 2,
            -visibleSize.height / 2,
            visibleSize.width,
            visibleSize.height,
          ),
          // Center the board in the middle of the screen. It's drawn centered
          // at the origin, which is the top left corner of the
          // GestureTransformable.
          initialTranslation: Offset(size.width/2, size.height/2),
          size: size,

          child: ItemStackBuilder());
    });
  }
}
