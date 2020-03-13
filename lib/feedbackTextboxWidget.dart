import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/textboxWidget.dart';

import 'core/models/appletModel.dart';

class FeedbackTextboxWidget extends StatelessWidget {
  final String id;
  final Offset pointerDownOffset;
  final GlobalKey feedbackKey;
  FeedbackTextboxWidget(this.id, this.feedbackKey, this.pointerDownOffset);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<Project>(context);
    var itemKey = projectProvider.getKeyFromId(id);
    var stackScale = projectProvider.notifier.value.row0[0];
    var textBox = projectProvider.appletMap[id] as TextApplet;
    var itemScale = projectProvider.appletMap[id].scale;
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
