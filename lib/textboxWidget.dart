import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'core/models/appletModel.dart';
import 'feedbackTextboxWidget.dart';
import 'fitTextField.dart';

import 'data.dart';

class TextboxWidget extends StatefulWidget {
  TextboxWidget({GlobalKey key}) : super(key: key);

  @override
  _TextboxWidgetState createState() => _TextboxWidgetState();
}

class _TextboxWidgetState extends State<TextboxWidget> {
  var pointerDownOffset = Offset(0, 0);
  var pointerUpOffset = Offset(0, 0);
  var onDragEndOffset;
  var pointerMoving = false;
  var absorbing = true;
  var projectProvider;

  Timer _timer;
  GlobalKey feedbackKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    projectProvider = Provider.of<Project>(context);
    var id = projectProvider.getIdFromKey(widget.key);
    var key = widget.key;


    var initialValue = projectProvider.appletMap[id].content;
    double itemScale = projectProvider.appletMap[id].scale;
    Offset boxPosition = projectProvider.appletMap[id].position;
    return Positioned(
      top: boxPosition.dy * itemScale,
      left: boxPosition.dx * itemScale,
      child: Listener(
        onPointerCancel: (detail) {
          absorbing = true;
          pointerMoving = false;
        },
        onPointerDown: (PointerDownEvent event) {
          if (projectProvider.firstItem) {
            projectProvider.actualItemKey = key;
            projectProvider.firstItem = false;
          }
          absorbing = true;
          pointerMoving = false;
          setState(() {
            pointerDownOffset = event.localPosition / itemScale;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          projectProvider.firstItem = true;
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
              if (projectProvider.appletMap[id].fixed == true &&
                  projectProvider.getActualTargetKey(key) != null) {
                boxPosition = projectProvider
                    .appletMap[projectProvider.getIdFromKey(projectProvider.getActualTargetKey(key))]
                    .position;
              } else {
                setState(() {
                  projectProvider.appletMap[id].position =
                      projectProvider.itemDropPosition(
                          key, pointerDownOffset, pointerUpOffset);
                });
              }
            },
            onDraggableCanceled: (vel, off) {
              setState(() {
                projectProvider.appletMap[id].position = projectProvider
                    .itemDropPosition(key, pointerDownOffset, pointerUpOffset);
              });
              projectProvider.stackSizeChange(id, feedbackKey, off);
            },
            childWhenDragging: Container(),
            feedback: ListenableProvider<Project>.value(
              value: Provider.of<Project>(context),
              child: Material(
                color: Colors.transparent,
                child:
                    FeedbackTextboxWidget(key, feedbackKey, pointerDownOffset),
              ),
            ),
            child: AbsorbPointer(
              absorbing: absorbing,
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scale: projectProvider.appletMap[id].scale,
                child: FitTextField(
                  initialValue: initialValue,
                  itemKey: key,
                  itemScale: itemScale,
                ),
              ),
            ),
            data: projectProvider.appletMap[id] as dynamic),
      ),
    );
  }
}
