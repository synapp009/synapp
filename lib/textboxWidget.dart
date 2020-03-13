import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'core/models/appletModel.dart';
import 'feedbackTextboxWidget.dart';

class TextboxWidget extends StatefulWidget {
  TextboxWidget({GlobalKey key}) : super(key: key);

  @override
  _TextboxWidgetState createState() => _TextboxWidgetState();
}

class _TextboxWidgetState extends State<TextboxWidget> {
  var pointerDownOffset = Offset(0, 0);
  var pointerUpOffset = Offset(0, 0);
  var onDragEndOffset;

  var absorbing = true;
  var projectProvider;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      Provider.of<Project>(context, listen: false).textFieldFocus =
          _focusNode.hasFocus ? true : true;
    });
  }

  Timer _timer;
  GlobalKey feedbackKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    print('focus ${_focusNode.hasFocus}');
    projectProvider = Provider.of<Project>(context);
    var key = widget.key;
    Key actualTargetKey = projectProvider.getActualTargetKey(key);
    String actualTargetId = projectProvider.getIdFromKey(actualTargetKey);
    String id = projectProvider.getIdFromKey(key);
    var initialValue = projectProvider.appletMap[id].content;
    double itemScale = projectProvider.appletMap[id].scale;
    Offset boxPosition = projectProvider.appletMap[id].position;
    return Positioned(
      top: boxPosition.dy * itemScale,
      left: boxPosition.dx * itemScale,
      child: Listener(
        onPointerCancel: (detail) {
          absorbing = true;
        },
        onPointerDown: (PointerDownEvent event) {
         // FocusScope.of(context).requestFocus(new FocusNode());

          if (projectProvider.firstItem) {
            projectProvider.actualItemKey = key;
            projectProvider.firstItem = false;
          }
          absorbing = true;
          setState(() {
            pointerDownOffset = event.localPosition / itemScale;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          projectProvider.firstItem = true;
          if (!projectProvider.pointerMoving) {
            setState(() {
              absorbing = false;
            });
          }
          projectProvider.pointerMoving = false;
          pointerUpOffset = event.position;
        },
        onPointerMove: (PointerMoveEvent event) {
          absorbing = true;
          projectProvider.pointerMoving = true;
         /* _timer = new Timer(Duration(milliseconds: 100), () {
            projectProvider.pointerMoving = false;

            _timer = new Timer(Duration(milliseconds: 1000), () {
              if (!projectProvider.pointerMoving) {
                projectProvider.appletMap[actualTargetId].selected = true;
                setState(() {
                  _timer = new Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      projectProvider.appletMap[id].selected = false;
                    });
                  });
                });
              }
            });
          });*/
        },
        child: LongPressDraggable(
            onDragStarted: () {
              print('drag');
            },
            dragAnchor: DragAnchor.pointer,
            onDragCompleted: () {
              //position if textbox gets conected to a window
              if (projectProvider.appletMap[id].fixed == true &&
                  projectProvider.getActualTargetKey(key) != null) {
                boxPosition = projectProvider
                    .appletMap[projectProvider
                        .getIdFromKey(projectProvider.getActualTargetKey(key))]
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
                    FeedbackTextboxWidget(id, feedbackKey, pointerDownOffset),
              ),
            ),
            child: AbsorbPointer(
              absorbing: false,
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scale: projectProvider.appletMap[id].scale,
                child: FitTextField(
                  myFocusNode: _focusNode,
                  initialValue: initialValue,
                  itemKey: key,
                  itemScale: itemScale,
                  actualTargetKey: actualTargetKey,
                ),
              ),
            ),
            data: projectProvider.appletMap[id] as dynamic),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class FitTextField extends StatefulWidget {
  final String initialValue;
  final double minWidth;
  final FocusNode myFocusNode;
  final enabled;
  final tapped;
  final itemScale;
  final itemKey;
  final feedbackKey;
  final actualTargetKey;

  const FitTextField(
      {this.itemKey,
      this.initialValue,
      this.minWidth: 30,
      this.myFocusNode,
      this.enabled,
      this.tapped,
      this.itemScale,
      this.feedbackKey,
      this.actualTargetKey});

  @override
  State<StatefulWidget> createState() => new FitTextFieldState();
}

class FitTextFieldState extends State<FitTextField> {
  TextEditingController txt = TextEditingController();

  // We will use this text style for the TextPainter used to calculate the width
  // and for the TextField so that we calculate the correct size for the text
  // we are actually displaying
  TextStyle textStyle = TextStyle(fontSize: 16);
  initState() {
    super.initState();
    // Set the text in the TextField to our initialValue
    txt.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var id = projectProvider.getIdFromKey(widget.itemKey);
    var textBox = projectProvider.appletMap[id];
    bool isFixed = textBox.fixed;
    var actualTargetId = projectProvider.getIdFromKey(widget.actualTargetKey);

    var targetScale = projectProvider.appletMap[actualTargetId].scale;
    // Use TextPainter to calculate the width of our text
    TextSpan ts = new TextSpan(style: textStyle, text: txt.text);
    // List<LineMetrics> lines = tp.computeLineMetrics();
    TextPainter tp = new TextPainter(
        text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();

    // We will use this width for the container wrapping our TextField
    var textWidth = tp.width;

    // Enforce a minimum width
    if (textWidth < widget.minWidth) {
      textWidth = widget.minWidth;
    } else {
      textWidth = textWidth;
    }

    return Container(
      key: widget.feedbackKey,
      width: widget.actualTargetKey == null
          ? textWidth * widget.itemScale
          : projectProvider
              .appletMap[id].size.width, // textWidth * widget.itemScale
      child: FittedBox(
        child: Container(
          width: widget.actualTargetKey == null
              ? textWidth
              : projectProvider.appletMap[id].size
                  .width, //projectProvider.appletMap[projectProvider.getActualTargetKey(widget.itemKey)].size.width, //TODO: autosize width still not perfect
          //decoration: new BoxDecoration(color: color),

          child: TextField(
            readOnly: true,
            cursorColor: Colors.grey[900],
            enabled: false,
            //readOnly: true,
            focusNode: widget.myFocusNode,
            keyboardType: TextInputType.multiline,
            autofocus: false,
            minLines: isFixed ? 6 : 1,
            maxLines: isFixed ? 6 : null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 1, right: -5),
              hintText: 'Text',
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1 * widget.itemScale,
                    color: Colors.grey[900],
                    style: isFixed ? BorderStyle.none : BorderStyle.solid),
                borderRadius: BorderRadius.all(
                  Radius.circular(3),
                ),
              ),
            ),
            style: textStyle,
            controller: txt,
            onChanged: (text) {
              textBox.content = txt.text;

              // Tells the framework to redraw the widget
              // The widget will redraw with a new width
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}
