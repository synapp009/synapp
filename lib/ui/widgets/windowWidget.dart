import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/ui/widgets/textboxWidget.dart';

import '../../core/models/projectModel.dart';

class WindowWidget extends StatefulWidget {
  final Applet applet;
  WindowWidget({this.applet});

  @override
  _WindowWidgetState createState() => _WindowWidgetState();
}

class _WindowWidgetState extends State<WindowWidget>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  Applet _applet;
  Timer _timer;

  int _maxSimultaneousDrags = 1;
  bool _isTapped = false;
  bool _dragStarted = false;

  static GlobalKey feedbackKey = GlobalKey();
  static GlobalKey sizedBoxKey = GlobalKey();

  var _crudProvider;
  var _itemScale;
  Project _projectProvider;
  var offsetChange = Offset(0, 0);
  var _scaleActive = false;
  @override
  void initState() {
    super.initState();
    //Animation Widget  controller gets bigger when tapp and dragged and smaller when dropped
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isTapped ? 100 : 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var _pointerDownOffset = Offset(0, 0);
  var _pointerUpOffset = Offset(0, 0);
  var _pointerMoving = false;
  var _scalePointerMoving = false;
  var _pointerUp = false;

  double _stackScale;
  Offset _stackOffset;
  double originScale;
  Offset originPosition;
  Size originSize;
  String originId;
  Map<String, Offset> childrenOriginPosition = {};
  Map<String, double> childrenOriginScale = {};

  String id;

//Calculate color when clicked on a window()
  _tonedColor(Color color) {
    Color tempColor;
    var newR = color.red * (1 / 1.2);
    var newG = color.green * (1 / 1.2);
    var newB = color.blue * (1 / 1.2);
    tempColor = Color.fromRGBO(newR.toInt(), newG.toInt(), newB.toInt(), 1);
    return tempColor;
  }

  void changeChildrenScale(_applet, scaleChange) {
    List<String> childrenList = Provider.of<Project>(context, listen: false)
        .getAllChildren(applet: _applet);
    if (childrenList != null) {
      childrenList.forEach((element) {
        Key _dragItemTargetKey =
            _projectProvider.getActualTargetKey(id: element);
        String _dragItemTargetId =
            _projectProvider.getIdFromKey(_dragItemTargetKey);
        double _dragItemTargetScale =
            _projectProvider.appletMap[_dragItemTargetId].scale;
        _projectProvider.appletMap[element].scale =
            _projectProvider.appletMap[element].scale * scaleChange;
      });
    }
  }

  void changeChildrenScaleAndPosition(key, offsetFromOriginDX, scaleChange) {
    List<String> childrenList = Provider.of<Project>(context, listen: false)
        .getAllChildren(
            applet:
                _projectProvider.appletMap[_projectProvider.getIdFromKey(key)]);
    if (childrenList != null) {
      childrenList.forEach((element) {
        Key _dragItemTargetKey =
            _projectProvider.getActualTargetKey(id: element);
        String _dragItemTargetId =
            _projectProvider.getIdFromKey(_dragItemTargetKey);

        var tempScale = (1 -
                (-offsetFromOriginDX /
                    _projectProvider.appletMap[_dragItemTargetId].size.width)) *
            childrenOriginScale[element];

        _projectProvider.appletMap[element]
            .scale = tempScale;
      });
    }
  }

  /* void changeChildrenPosition(key, scaleChange, changeMap) {
    List<Key> childrenList = Provider.of<Project>(context, listen: false)
        .getAllChildren(itemKey: key);
    if (childrenList != null) {
      childrenList.forEach((element) => _projectProvider
              .appletMap[_projectProvider.getIdFromKey(element)].position =
          changeMap[element] *
              (scaleChange *
                  _projectProvider
                      .appletMap[_projectProvider.getIdFromKey(element)]
                      .scale));
    }
  }*/

  @override
  Widget build(BuildContext context) {
    _projectProvider = Provider.of<Project>(context);
    _crudProvider = Provider.of<CRUDModel>(context);

    _applet = widget.applet;

    _stackScale = _projectProvider.stackScale;

    id = _applet.id;
    _itemScale = _applet.scale;
    _stackOffset = _projectProvider.stackOffset;

//animation
    _animation() {
      if (!_projectProvider.textFieldFocus) {
        _controller.forward();
        _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
          setState(() {
            _applet.selected = _applet.selected ? false : true;
            _controller.reverse();
          });
        });
      }
      _projectProvider.textFieldFocus =
          _projectProvider.textFieldFocus ? false : false;
    }

    if (id == _projectProvider.actualItemKey && !_pointerMoving && !_isTapped) {
      _scale = 1 + _controller.value;
    } else if (id == _projectProvider.actualItemKey &&
        !_pointerMoving &&
        _isTapped) {
      _scale = 1 - _controller.value;
    } else {
      _scale = 1;
    }

    //threshold
    _isPointerMoving() {
      _timer = new Timer(const Duration(milliseconds: 200), () {
        setState(() {
          if (!_pointerMoving && !_applet.selected) {
            _controller.forward();
            if (_pointerUp) {
              _controller.reverse();
              _pointerUp = false;
            }
          }
        });
      });
    }

    return Positioned(
      key: _applet.key,
      top: _applet.position.dy * _itemScale,
      left: _applet.position.dx * _itemScale,
      child: DragTarget(
          builder: (buildContext, List<dynamic> candidateData, rejectData) {
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            _pointerUp = false;
            if (_projectProvider.firstItem) {
              _projectProvider.actualItemKey =
                  _projectProvider.getKeyFromId(id);
              //_projectProvider.getAllArrows(_applet.key);
              _projectProvider.firstItem = false;
            }

            //threshold
            _isPointerMoving();

            setState(() {
              _pointerDownOffset = event.localPosition / _itemScale;
            });
          },
          onPointerCancel: (details) {
            _pointerMoving = false;
          },
          onPointerUp: (PointerUpEvent event) {
            _controller.reverse();

            _pointerUpOffset = event.position;
            _pointerUp = true;
            _pointerMoving = false;
            _projectProvider.firstItem = true;
          },
          onPointerMove: (PointerMoveEvent event) {
            //update the position of all the arrows pointing to the window
            if (_dragStarted) {
              _projectProvider.updateArrowToKeyMap(
                  _applet.key, _dragStarted, feedbackKey);
            }
            _controller.reverse();

            //set if Pointer is Moving with threshold

            if ((event.localPosition.dx - _pointerDownOffset.dx).abs() >
                    100 / _itemScale ||
                (event.localPosition.dy - _pointerDownOffset.dy).abs() >
                    100 / _itemScale) {
              _pointerMoving = true;
            }
          },
          child: GestureDetector(
            onDoubleTap: () {
              // _projectProvider.zoomToBox(id, context);
            },
            onLongPressStart: (details) {
              HapticFeedback.mediumImpact();
              _projectProvider.addArrow(id);

              //only select the creating window
              _projectProvider.onlySelectThis(id);
            },
            onLongPressMoveUpdate: (details) {
              _projectProvider.hitTest(
                  _applet.key, details.globalPosition, context);
              _projectProvider.setArrowToPointer(id, details.globalPosition);
            },
            onLongPressEnd: (details) {
              _projectProvider.connectAndUnselect(_applet.key);
            },
            onLongPressUp: () {},
            onTap: () {
              FocusScope.of(context).requestFocus(
                new FocusNode(),
              );

              _isTapped = true;
              _animation();
              _maxSimultaneousDrags = _applet.selected ? 0 : 1;
              _isTapped = false;
            },
            child: LongPressDraggable(
              //hapticFeedbackOnStart: true,

              maxSimultaneousDrags: _applet.selected ? 0 : 1,
              onDragEnd: (DraggableDetails details) {
                _timer = new Timer(Duration(milliseconds: 200), () {
                  //setState(() {

                  _dragStarted = false;
                  _projectProvider.updateArrowToKeyMap(
                      _applet.key, _dragStarted, _applet.key);
                  //});
                });
              },
              onDragStarted: () {
                HapticFeedback.mediumImpact();

                //_applet.onChange = true;
                _projectProvider.originId =
                    _projectProvider.getActualTargetId(id);

                _timer = new Timer(Duration(milliseconds: 200), () {
                  _dragStarted = true;

                  _projectProvider.updateArrowToKeyMap(
                      _applet.key, _dragStarted, feedbackKey);
                });
                //setState(() {});
              },
              onDragCompleted: () {
                //_applet.onChange = false;
                _projectProvider.changeItemDropPosition(
                    applet: _applet,
                    feedbackKey: feedbackKey,
                    pointerDownOffset: _pointerDownOffset,
                    pointerUpOffset: _pointerUpOffset);
              },
              onDraggableCanceled: (vel, Offset off) {
                //_applet.onChange = false;
                _projectProvider.changeItemDropPosition(
                  applet: _applet,
                  feedbackKey: feedbackKey,
                  pointerDownOffset: _pointerDownOffset,
                  pointerUpOffset: _pointerUpOffset,
                );
              },
              dragAnchor: DragAnchor.pointer,
              childWhenDragging: Container(),
              feedback: ChangeNotifierProvider<Project>.value(
                value: _projectProvider,
                child: FeedbackWindowWidget(
                    _applet, _pointerDownOffset, feedbackKey),
              ),
              child: Visibility(
                  visible: _projectProvider.chosenId == id ? false : true,
                  child: _animatedButtonUI),
              data: _applet as Applet,
            ),
          ),
        );
      }, onWillAccept: (Applet data) {
        //true if window changes target
        if (data.id != id
            // &&
            //!_projectProvider.appletMap[null].childIds.contains(id) &&
            //!_applet.childIds.contains(data.id)
            ) {
          _projectProvider.targetId = id;
          double _dragItemTargetScale = _applet.scale;
          print('willaccept true');
          double _scaleChange = data.scale;
          data.scale = _dragItemTargetScale * 0.3;
          _projectProvider.scaleChange = data.scale / _scaleChange;
          if (data.type == "WindowApplet") {
            changeChildrenScale(data, _projectProvider.scaleChange);
          } else if (data.type == "TextApplet") {
            data.scale = _itemScale;
          }

          _projectProvider.notifyListeners();
          return true;
        } else {
          return true;
        }
      }, onLeave: (Applet data) {
        _applet.selected = false;
      }, onAccept: (Applet data) {
        /*_projectProvider.updateApplet(
            applet: data, targetId: id, originId: _projectProvider.originId);*/
        if (data.type == 'TextApplet') {
          data.scale = _itemScale;
          if (data.selected == true) {
            data.fixed = true;
            data.position = Offset(10, 10);
            data.size = data.size * 0.9;
          } else {
            data.fixed = false;
          }
          data.selected = false;
        }
      }),
    );
  }

  Widget get _animatedButtonUI => Transform.scale(
        scale: _scale,
        child: Stack(
          overflow: Overflow.clip,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
//Container around the box so scale/resize icon can be pressed
            Visibility(
              visible: _applet.selected && !_scalePointerMoving ? true : false,
              child: Container(
                  width: (_applet.size.width + (20.0)) * _itemScale,
                  height: (_applet.size.height + (20.0)) * _itemScale,
                  color: Colors.transparent),
            ),
            /*  SizedBox(
                  width: _applet.size.width *
                      _itemScale,
                  height: 20 * _itemScale,
                  child: FittedBox(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF0E3311).withOpacity(0.1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(3),
                        ),
                      ),
                      child: Text('Test'),
                    ),
                  ),
                ),*/

            Opacity(
              opacity: 1,
              child: SizedBox(
                //key: widget.key,
                height: _applet.size.height * _itemScale,
                width: _applet.size.width * _itemScale,
                child: Material(
                  shape: SuperellipseShape(
                    side: BorderSide(
                        color: _applet.selected
                            ? Colors.grey[900]
                            : Colors.transparent,
                        width: 3.0 * _itemScale),
                    borderRadius: BorderRadius.circular(28 * _itemScale),
                  ),
                  //margin: EdgeInsets.all(0),
                  color: _applet.selected
                      ? _tonedColor(_applet.color)
                      : _applet.color,
                  child: WindowStackBuilder(_applet),
                ),
              ),
            ),
            //The Icon to scale and resize the box
            Visibility(
              visible: _applet.selected ? true : false,
              child: Transform.translate(
                offset: Offset(
                  (_applet.size.width * _itemScale - 20.0),
                  (_applet.size.height * _itemScale - 20.0),
                ),
                child: Transform.scale(
                  scale: 1.0 * _itemScale,
                  child: Material(
                    borderRadius: new BorderRadius.circular(30.0),

                    color: Colors.black54,
                    //shape: CircleBorder(),
                    child: InkWell(
                      //highlightColor: Colors.tran,
                      borderRadius: BorderRadius.circular(100.0),
                      onTap: () {},
                      onLongPress: () {},
                      child: Transform.translate(
                        offset: Offset(0, 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _scalePointerMoving = false;
                              _scaleActive = !_scaleActive;
                            });
                          },
                          onTapDown: (details) {
                            setState(() {
                              _pointerMoving = true;
                              // _scaleActive = true;
                            });
                          },
                          onLongPress: () {
                            originScale = _itemScale;
                            originPosition = _applet.position;
                            originSize = _applet.size;
                            List<String> childrenList =
                                Provider.of<Project>(context, listen: false)
                                    .getAllChildren(applet: _applet);

                            childrenList.forEach((element) {
                              childrenOriginPosition[element] =
                                  _projectProvider
                                      .appletMap[element]
                                      .position;
                              childrenOriginScale[element] =
                                  _projectProvider
                                      .appletMap[element]
                                      .scale;
                            });
                          },
                          onLongPressEnd: (details) {
                            setState(() {
                              _pointerMoving = false;
                              offsetChange = Offset(0, 0);
                            });
                            _projectProvider.updateApplet(applet: _applet);
                            _projectProvider.stackSizeChange(
                                applet:_applet,
                                feedbackKey:_applet.key,
                                pointerUpOffset:details.globalPosition,
                                pointerDownOffset:details.globalPosition,
                                initialize:false
                                );
                          },
                          onLongPressStart: (details) {},
                          onPanUpdate: (details) {},
                          onLongPressMoveUpdate:
                              (LongPressMoveUpdateDetails details) {
                            Offset offsetDelta =
                                details.offsetFromOrigin / _stackScale -
                                    offsetChange;
                            offsetChange =
                                details.offsetFromOrigin / _stackScale;
                            if (!_scaleActive) {
                              setState(() {
                                _applet.size = Size(
                                    _applet.size.width > 40 * _itemScale
                                        ? _projectProvider
                                                .appletMap[id].size.width +
                                            offsetDelta.dx / _itemScale
                                        : _projectProvider
                                                .appletMap[id].size.width +
                                            1 * _itemScale,
                                    _applet.size.height > 40 * _itemScale
                                        ? _projectProvider
                                                .appletMap[id].size.height +
                                            offsetDelta.dy / _itemScale
                                        : _projectProvider
                                                .appletMap[id].size.width +
                                            1 * _itemScale);
                              });
                            } else {
                              if (details.offsetFromOrigin.dx +
                                      originSize.width >
                                  40) {
                                _applet.scale = (1 -
                                        (-details.offsetFromOrigin.dx /
                                            originSize.width)) *
                                    originScale;

                                var scaleChange = originScale / _applet.scale;
                                changeChildrenScaleAndPosition(
                                    _projectProvider.getKeyFromId(id),
                                    details.offsetFromOrigin.dx,
                                    scaleChange);

                                _applet.position = originPosition * scaleChange;
                              }
                            }

                            _projectProvider.notifyListeners();
                            _projectProvider.updateArrowToKeyMap(
                                _applet.key, _dragStarted, _applet.key);
                          },
                          child: Transform.scale(
                            scale: 0.7,
                            child: Transform.rotate(
                              angle: _scaleActive ? 0 : 340,
                              child: Icon(
                                _scaleActive
                                    ? Icons.zoom_out_map
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class WindowStackBuilder extends StatelessWidget {
  final Applet _applet;

  WindowStackBuilder(this._applet);

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    return Stack(overflow: Overflow.visible, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          height: _applet.size.height,
          width: _applet.size.width,
          child: Text('${_applet.size},${_applet.key}'),
        ),
      ),
      ...stackItems(context)
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    List<Widget> stackItemsList = [];
    var projectProvider = Provider.of<Project>(context);

    var stackItemDraggable;

    List<Applet> childList =
        _applet.childIds.map((e) => projectProvider.appletMap[e]).toList();
    for (int i = 0; i < childList.length; i++) {
      if (childList[i].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(applet: childList[i]);
      } else if (childList[i].type == "TextApplet") {
        stackItemDraggable = TextboxWidget(applet: childList[i]);
      } else {
        stackItemDraggable = Container(height: 0, width: 0);
      }
      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}

class FeedbackWindowWidget extends StatelessWidget {
  final Applet applet;
  final Offset pointerDownOffset;
  final GlobalKey feedbackKey;
  FeedbackWindowWidget(this.applet, this.pointerDownOffset, this.feedbackKey);

  @override
  Widget build(BuildContext context) {
    final appletProvider = Provider.of<Project>(context);

    var stackScale = appletProvider.stackScale;
    var itemScale = applet.scale;

    Size animationOffseter =
        Size((applet.size.width / 2) * 0.1, (applet.size.width / 2) * 0.1);
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
              height: applet.size.height * itemScale,
              width: applet.size.width * itemScale,
              child: Material(
                animationDuration: Duration.zero,
                shape: SuperellipseShape(
                  borderRadius: BorderRadius.circular(28 * itemScale),
                ),
                //margin: EdgeInsets.all(0),
                color: applet.color,

                child: WindowStackBuilder(applet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
