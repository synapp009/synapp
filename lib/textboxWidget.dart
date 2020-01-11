import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feedbackTextboxWidget.dart';
import 'fitTextField.dart';

import 'data.dart';

class TextboxWidget extends StatefulWidget {
  TextboxWidget({GlobalKey key}) : super(key: key);

  @override
  _TextboxWidgetState createState() => _TextboxWidgetState(key);
}

class _TextboxWidgetState extends State<TextboxWidget> {
  final GlobalKey key;
  _TextboxWidgetState(this.key);

  var pointerDownOffset = Offset(0, 0);
  var pointerUpOffset = Offset(0, 0);
  var onDragEndOffset;
  var pointerMoving = false;
  var absorbing = true;

  Timer _timer;
  GlobalKey feedbackKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);

    var initialValue = dataProvider.structureMap[key].content;

    double itemScale = dataProvider.structureMap[key].scale;
    Offset boxPosition = dataProvider.structureMap[widget.key].position;
    return Positioned(
      top: boxPosition.dy * itemScale,
      left: boxPosition.dx * itemScale,
      child: Listener(
        onPointerCancel: (detail) {
          absorbing = true;
          pointerMoving = false;
        },
        onPointerDown: (PointerDownEvent event) {
          if (dataProvider.firstItem) {
            dataProvider.actualItemKey = key;
            dataProvider.firstItem = false;
          }
          absorbing = true;
          pointerMoving = false;
          setState(() {
            pointerDownOffset = event.localPosition / itemScale;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          dataProvider.firstItem = true;
          if (!pointerMoving) {
            setState(() {
              absorbing = false;
            });
          }
          pointerMoving = false;
          pointerUpOffset = event.position;
        },
        onPointerMove: (PointerMoveEvent event) {
          absorbing = true;
          pointerMoving = true;
        },
        child: LongPressDraggable(
            dragAnchor: DragAnchor.pointer,
            onDragCompleted: () {

              //position if textbox gets conected to a window
              if (dataProvider.structureMap[key].fixed == true &&
                  dataProvider.getActualTargetKey(key) != null) {
                boxPosition = dataProvider
                    .structureMap[dataProvider.getActualTargetKey(key)]
                    .position ;

              } else {
                setState(() {
                  dataProvider.structureMap[widget.key].position =
                      dataProvider.itemDropPosition(
                          key, pointerDownOffset, pointerUpOffset);
                });
              }
            },
            onDraggableCanceled: (vel, off) {
              setState(() {
                dataProvider.structureMap[widget.key].position = dataProvider
                    .itemDropPosition(key, pointerDownOffset, pointerUpOffset);
              });
              dataProvider.stackSizeChange(key, feedbackKey, off);
            },
            childWhenDragging: Container(),
            feedback: ListenableProvider<Data>.value(
              value: Provider.of<Data>(context),
              child: Material(
                color: Colors.transparent,
                child:
                    FeedbackTextboxWidget(key, feedbackKey, pointerDownOffset),
              ),
            ),
            child: AbsorbPointer(
              absorbing: absorbing,
              child: FitTextField(
                initialValue: initialValue,
                itemKey: key,
                itemScale: itemScale,
              ),
            ),
            data: dataProvider.structureMap[key]),
      ),
    );
  }
}
