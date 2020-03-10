import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';

import 'core/models/appletModel.dart';
import 'data.dart';
import 'fitTextField.dart';

class FeedbackTextboxWidget extends StatelessWidget {
  final Key itemKey;
  final Offset pointerDownOffset;
  final GlobalKey feedbackKey;
  FeedbackTextboxWidget(this.itemKey, this.feedbackKey, this.pointerDownOffset);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<Project>(context);
    var itemId = projectProvider.getIdFromKey(itemKey);
    var stackScale = projectProvider.notifier.value.row0[0];
    var textBox = projectProvider.appletMap[itemId] as TextApplet;
    var itemScale = projectProvider.appletMap[itemId].scale;
    var initialValue = textBox.content;
    var targetScale = projectProvider.getTargetScale(itemKey);
    return Transform.translate(
      offset: Offset((-pointerDownOffset.dx * stackScale * itemScale),
          -pointerDownOffset.dy * stackScale * itemScale),
      child: Transform.scale(
        scale: itemScale,
        alignment: Alignment.topLeft,
        child: FitTextField(
          feedbackKey: feedbackKey,
          itemKey: itemKey,
          initialValue: initialValue,
          itemScale: itemScale * stackScale,
        ),
      ),
    );
  }
}
