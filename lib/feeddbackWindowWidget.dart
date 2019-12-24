import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'windowStackBuilder.dart';

import 'data.dart';

class FeedbackWindowWidget extends StatelessWidget {
  final Key itemKey;
  final Offset pointerDownOffset;
  final GlobalKey feedbackKey;
  FeedbackWindowWidget(this.itemKey, this.pointerDownOffset, this.feedbackKey);

  @override
  Widget build(BuildContext context) {

    final dataProvider = Provider.of<Data>(context);

    var stackScale = dataProvider.notifier.value.row0[0];

    var itemScale = dataProvider.structureMap[itemKey].scale;
    var childList = dataProvider.getAllChildren(itemKey);

    childList.forEach((f) => {
          dataProvider.structureMap[f].scale =
              (dataProvider.getTargetScale(f)) * 0.3,
          //dataProvider.structureMap[f].position = dataProvider.structureMap[f].position*0.3
        });
    Size animationOffseter = Size(
        (dataProvider.structureMap[itemKey].size.width / 2) * 0.1,
        (dataProvider.structureMap[itemKey].size.width / 2) * 0.1);

    return Transform.translate(
      offset: Offset(
          ((-pointerDownOffset.dx - animationOffseter.width) *
                  stackScale *
                  itemScale) +
              0.1,
          ((-pointerDownOffset.dy - animationOffseter.height) *
                  stackScale *
                  itemScale) +
              0.1),
      child: Transform.scale(
        alignment: Alignment.topLeft,
        scale: stackScale + (stackScale * 0.1),
        child: SizedBox(
          key: feedbackKey,
          height: dataProvider.structureMap[itemKey].size.height * (itemScale),
          width: dataProvider.structureMap[itemKey].size.width * (itemScale),
          child: Material(
            animationDuration: Duration.zero,
            shape: SuperellipseShape(
                borderRadius: BorderRadius.circular(28 * itemScale*stackScale)),
            //margin: EdgeInsets.all(0),
            color: dataProvider.structureMap[itemKey].color,

            child: WindowStackBuilder(itemKey),
          ),
        ),
      ),
    );
  }
}
