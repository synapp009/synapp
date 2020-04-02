import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:synapp/windowWidget.dart';
import 'core/models/projectModel.dart';

class FeedbackWindowWidget extends StatelessWidget {
  final String id;
  final Offset pointerDownOffset;
  final GlobalKey feedbackKey;
  FeedbackWindowWidget(this.id, this.pointerDownOffset, this.feedbackKey);

  @override
  Widget build(BuildContext context) {
    final appletProvider = Provider.of<Project>(context);
    var window = appletProvider.appletMap[id];
    var stackScale = appletProvider.notifier.value.row0[0];
    var itemScale = appletProvider.appletMap[id].scale;
    Size animationOffseter = Size(
        (appletProvider.appletMap[id].size.width / 2) * 0.1,
        (appletProvider.appletMap[id].size.width / 2) * 0.1);
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
        child: Column(
          children: [
            SizedBox(
              key: feedbackKey,
              height: appletProvider.appletMap[id].size.height * itemScale,
              width: appletProvider.appletMap[id].size.width * itemScale,
              child: Material(
                animationDuration: Duration.zero,
                shape: SuperellipseShape(
                  borderRadius: BorderRadius.circular(28 * itemScale),
                ),
                //margin: EdgeInsets.all(0),
                color: window.color,

                child: WindowStackBuilder(id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
