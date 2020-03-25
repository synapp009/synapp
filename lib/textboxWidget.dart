import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:zefyr/zefyr.dart';
import 'core/models/appletModel.dart';
import 'feedbackTextboxWidget.dart';

// change: add these two lines to imports section at the top of the file
import 'dart:convert'; // access to jsonEncode()
import 'dart:io'; // access to File and Directory classes

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
            maxSimultaneousDrags: _focusNode.hasFocus ? 0 : 1,
            onDragStarted: () {},
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
                child: Container(height: 50, width: 50),
                /* child:
                    FeedbackTextboxWidget(id, feedbackKey, pointerDownOffset),*/
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

  /// Allows to control the editor and the document.
  ZefyrController _controller;

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode;

  // We will use this text style for the TextPainter used to calculate the width
  // and for the TextField so that we calculate the correct size for the text
  // we are actually displaying
  TextStyle textStyle = TextStyle(fontSize: 16);
  initState() {
    super.initState();
    // Set the text in the TextField to our initialValue
    txt.text = widget.initialValue;
    final document = _loadDocument();
    _controller = ZefyrController(document);

    _focusNode = widget.myFocusNode;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveDocument(context);
      }
    });
    _controller.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var id = projectProvider.getIdFromKey(widget.itemKey);
    var textBox = projectProvider.appletMap[id];
    var size = projectProvider.appletMap[id].size;
    var position = projectProvider.appletMap[id].position;
    ZefyrImageDelegate _imageDelegate;

    _saveDocument(context);
    final editor =
        //ZefyrView(document: _controller.document);

        ZefyrEditor(
      //height: projectProvider.appletMap[id].size.height, // set the editor's height
      /*decoration: new InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(width: 2.0, color: Colors.grey[900]),
        ),
      ),*/

      controller: _controller,
      focusNode: _focusNode,
      autofocus: false,
      imageDelegate: _imageDelegate,
      physics: ClampingScrollPhysics(),
    );
    final form = editor;

    bool isFixed = textBox.fixed;
    var actualTargetId = projectProvider.getIdFromKey(widget.actualTargetKey);

    var targetScale = projectProvider.appletMap[actualTargetId].scale;
    //textWidth = 400;
    return Stack(
      overflow: Overflow.clip,
      children: [
        Container(
          height: size.height + 40.0,
          width: size.width + 40.0,
        ),
        Transform.translate(
          offset: Offset(20, 20),
          child: DottedBorder(
            color: _focusNode.hasFocus ? Colors.grey[900] : Colors.transparent,
            borderType: BorderType.RRect,
            //radius: Radius.circular(5),
            padding: EdgeInsets.all(0),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Container(
                //key: widget.feedbackKey,
                width: widget.actualTargetKey == null
                    ? projectProvider.appletMap[id].size.width *
                        widget.itemScale
                    : projectProvider.appletMap[id].size
                        .width, // textWidth * widget.itemScale
                height: widget.actualTargetKey == null
                    ? projectProvider.appletMap[id].size.height *
                        widget.itemScale
                    : projectProvider.appletMap[id].size.height,
                child: Container(
                  width: widget.actualTargetKey == null
                      ? projectProvider.appletMap[id].size.width
                      : projectProvider.appletMap[id].size
                          .width, //projectProvider.appletMap[projectProvider.getActualTargetKey(widget.itemKey)].size.width, //TODO: autosize width still not perfect
                  //decoration: new BoxDecoration(color: color),
                  height: widget.actualTargetKey == null
                      ? projectProvider.appletMap[id].size.height
                      : projectProvider.appletMap[id].size.height,
                  //color: Colors.transparent,
                  child: form,
                ),
              ),
            ),
          ),
        ),
        ...scaleContainer(
            context: context,
            position: position,
            size: size,
            textBoxId: id,
            selected: _focusNode.hasFocus),
      ],
    );
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert(widget.initialValue);
    return NotusDocument.fromDelta(delta);
  }

  // change: add after _loadDocument()

  void _saveDocument(BuildContext context) {
    var projectProvider = Provider.of<Project>(context, listen: false);
    var appletId = projectProvider.getIdFromKey(widget.itemKey);
    TextApplet tempApp = projectProvider.appletMap[appletId];
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");

    // And show a snack bar on success.
    /*file.writeAsString(contents).then((_) {
      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });*/
    Provider.of<CRUDModel>(context, listen: false)
        .updateApplet(projectProvider.projectId, tempApp, appletId);
  }
}

List<Widget> scaleContainer(
    {BuildContext context,
    Offset position,
    Size size,
    String textBoxId,
    bool selected}) {
  List<Widget> scaleContainerList = [];
  for (int i = 0; i < 8; i++) {
    scaleContainerList.add(ScaleContainer(
        size: size,
        i: i,
        position: position,
        selected: selected,
        textBoxId: textBoxId));
  }
  return scaleContainerList;
}

class ScaleContainer extends StatelessWidget {
  ScaleContainer(
      {this.position, this.size, this.textBoxId, this.selected, this.i});

  final int i;

  final Offset position;
  final Size size;
  final String textBoxId;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    //List<int> indexList = Iterable<int>.generate(8).toList();
    var projectProvider = Provider.of<Project>(context);
    var itemProvider = projectProvider.appletMap[textBoxId];
    var itemScale = projectProvider.appletMap[textBoxId].scale;
    var itemSize = projectProvider.appletMap[textBoxId].size;
    var itemPosition = projectProvider.appletMap[textBoxId].position;
    var originTextBoxPosition = projectProvider.originTextBoxPosition;
    var originTextBoxSize = projectProvider.originTextBoxSize;

    List<Offset> positionList = [
      Offset(0, 0),
      Offset(0 + size.width / 2, 0),
      Offset(0 + size.width, 0),
      Offset(0 + size.width, 0 + size.height / 2),
      Offset(0 + size.width, 0 + size.height),
      Offset(0 + size.width / 2, 0 + size.height),
      Offset(0, 0 + size.height),
      Offset(0, 0 + size.height / 2)
    ];

    return Visibility(
      visible: selected ? true : false,
      child: Positioned(
        left: positionList[i].dx,
        top: positionList[i].dy,
        child: Listener(
          onPointerDown: (event) {
            projectProvider.originTextBoxPosition = itemPosition;
            projectProvider.originTextBoxSize = itemSize;
          },
          onPointerMove: (event) {
            print(itemSize - event.delta);

            /*print((originTextBoxSize.height +
                    (originTextBoxPosition.dy - event.position.dy)));*/

            projectProvider.scaleTextBox(i, textBoxId, event);
          },
          child: GestureDetector(
            onPanDown: (details) {
              print('down');
            },
            onTap: () {
              print('tapp');
            },
            onPanStart: (details) {
              // originPosition = projectProvider.appletMap[textBoxId].position;
            },
            onPanUpdate: (details) {
              //projectProvider.notifyListeners();
            },
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.grey[900],
                      width: 0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                //color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
