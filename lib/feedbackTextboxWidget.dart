import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'fitTextField.dart';

class FeedbackTextboxWidget extends StatelessWidget {
  final Key itemKey;
  final Offset pointerDownOffset;
  FeedbackTextboxWidget(this.itemKey, this.pointerDownOffset);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<Data>(context);

    var stackScale = dataProvider.notifier.value.row0[0];

    var itemScale = dataProvider.structureMap[itemKey].scale;
    var initialValue = dataProvider.structureMap[itemKey].content;

    return Transform.translate(
      offset: Offset((-pointerDownOffset.dx * stackScale * itemScale),
          -pointerDownOffset.dy * stackScale * itemScale),
      child: FitTextField(
        itemKey: itemKey,
        initialValue: initialValue,
        itemScale: itemScale * stackScale + 0.1,
      ),
    );
  }
}
