import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/itemStackBuilder.dart';

import 'core/models/appletModel.dart';
import 'core/models/projectModel.dart';
import 'data.dart';

import 'windowStackBuilder.dart';
import 'feeddbackWindowWidget.dart';

class WindowWidget extends StatefulWidget {
  WindowWidget({GlobalKey key}) : super(key: key);

  @override
  _WindowWidgetState createState() => _WindowWidgetState();
}

class _WindowWidgetState extends State<WindowWidget>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  Timer _timer;

  int _maxSimultaneousDrags = 1;
  bool _isTapped = false;
  bool _dragStarted = false;

  static GlobalKey feedbackKey = GlobalKey();
  static GlobalKey sizedBoxKey = GlobalKey();
  var _projectProvider;
  var _crudProvider;
  var _itemScale;

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
  var _onDragEndOffset;
  var _pointerMoving = false;
  var _pointerUp = false;

  double _stackScale;
  Offset _stackOffset;

  Map<Key, List<Key>> hasArrowToKeyMap = {};
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

  @override
  Widget build(BuildContext context) {
    _projectProvider = Provider.of<Project>(context);
    _crudProvider = Provider.of<CRUDModel>(context);

    id = _projectProvider.getIdFromKey(widget.key);

    Key _windowTargetKey = _projectProvider.getActualTargetKey(widget.key);
    String _windowTargetId = _projectProvider.getIdFromKey(_windowTargetKey);
    double _windowTargetScale =
        _projectProvider.appletMap[_windowTargetId].scale;

    _stackScale = _projectProvider.stackScale;

    _itemScale = _projectProvider.appletMap[id].scale;
    _stackOffset = _projectProvider.stackOffset;

//animation
    _animation() {
      _controller.forward();
      _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
        setState(() {
          _projectProvider.appletMap[id].selected =
              _projectProvider.appletMap[id].selected ? false : true;
          _controller.reverse();
        });
      });
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
          if (!_pointerMoving && !_projectProvider.appletMap[id].selected) {
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
      top: _projectProvider.appletMap[id].position.dy * _itemScale,
      left: _projectProvider.appletMap[id].position.dx * _itemScale,
      child: DragTarget(
          builder: (buildContext, List<dynamic> candidateData, rejectData) {
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            _pointerUp = false;
            if (_projectProvider.firstItem) {
              _projectProvider.actualItemKey =
                  _projectProvider.getKeyFromId(id);
              _projectProvider.getAllArrows(_projectProvider.appletMap[id].key);
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
            // _projectProvider.stackSizeHitTest(event.position);

            //update the position of all the arrows pointing to the window
            if (_dragStarted) {
              _projectProvider.updateArrowToKeyMap(
                  _projectProvider.appletMap[id].key,
                  _dragStarted,
                  feedbackKey);
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
              _projectProvider.hitTest(_projectProvider.appletMap[id].key,
                  details.globalPosition, context);
              _projectProvider.setArrowToPointer(
                  _projectProvider.appletMap[id].key, details.globalPosition);
            },
            onLongPressEnd: (details) {
              _projectProvider
                  .connectAndUnselect(_projectProvider.appletMap[id].key);
            },
            onLongPressUp: () {},
            onTap: () {
              FocusScope.of(context).requestFocus(
                new FocusNode(),
              );

              _isTapped = true;
              _animation();
              _maxSimultaneousDrags =
                  _projectProvider.appletMap[id].selected ? 0 : 1;
              _isTapped = false;
            },
            child: LongPressDraggable(
                //hapticFeedbackOnStart: true,

                maxSimultaneousDrags:
                    _projectProvider.appletMap[id].selected ? 0 : 1,
                onDragEnd: (DraggableDetails details) {
                  // _projectProvider.updateArrowToKeyMap(id, _dragStarted, feedbackKey);
                  _timer = new Timer(Duration(milliseconds: 200), () {
                    setState(() {
                      _dragStarted = false;
                      _projectProvider.updateArrowToKeyMap(
                          _projectProvider.appletMap[id].key,
                          _dragStarted,
                          _projectProvider.appletMap[id].key);
                      _projectProvider.hasArrowToKeyMap.clear();
                    });
                  });
                },
                onDragStarted: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _timer = new Timer(Duration(milliseconds: 200), () {
                      _dragStarted = true;

                      _projectProvider.updateArrowToKeyMap(
                          _projectProvider.appletMap[id].key,
                          _dragStarted,
                          feedbackKey);
                    });
                  });
                },
                onDragCompleted: () {
                  setState(() {
                    _projectProvider.appletMap[id].position =
                        _projectProvider.itemDropPosition(
                            widget.key, _pointerDownOffset, _pointerUpOffset);
                  });
                  //_crudProvider.updateApplet(_projectProvider.id, _projectProvider.appletMap[id], id);
                },
                onDraggableCanceled: (vel, Offset off) {
                  setState(() {
                    _projectProvider.appletMap[id].position =
                        _projectProvider.itemDropPosition(
                            widget.key, _pointerDownOffset, _pointerUpOffset);

                    _projectProvider.stackSizeChange(id, feedbackKey, off);
                  });
                },
                dragAnchor: DragAnchor.pointer,
                childWhenDragging: Container(),
                feedback: ChangeNotifierProvider<Project>.value(
                  value: _projectProvider,
                  child:
                      FeedbackWindowWidget(id, _pointerDownOffset, feedbackKey),
                ),
                child: _animatedButtonUI,
                data: _projectProvider.appletMap[id]),
          ),
        );
      }, onWillAccept: (dynamic data) {
        _projectProvider.leaveApplet = false;
        //true if window changes target

        if (_projectProvider.appletMap[id].key != data.key &&
            //!_projectProvider.appletMap[null].childIds.contains(id) &&
            !_projectProvider.appletMap[id].childIds.contains(id)) {
          _projectProvider.changeItemListPosition(itemId: data.id, newId: id);
          Key _dragItemTargetKey =
              _projectProvider.getActualTargetKey(data.key);
          String _dragItemTargetId =
              _projectProvider.getIdFromKey(_dragItemTargetKey);
          double _dragItemTargetScale =
              _projectProvider.appletMap[_dragItemTargetId].scale;

          double _scaleChange = _projectProvider.appletMap[data.id].scale;
          _projectProvider.appletMap[data.id].scale =
              _dragItemTargetScale * 0.3;
          _projectProvider.scaleChange =
              _projectProvider.appletMap[data.id].scale / _scaleChange;

          if (data.type == "WindowApplet") {
            List<Key> childrenList =
                Provider.of<Project>(context, listen: false)
                    .getAllChildren(data.key);
            if (childrenList != null) {
              childrenList.forEach((element) {
                Key _dragItemTargetKey =
                    _projectProvider.getActualTargetKey(element);
                String _dragItemTargetId =
                    _projectProvider.getIdFromKey(_dragItemTargetKey);
                double _dragItemTargetScale =
                    _projectProvider.appletMap[_dragItemTargetId].scale;
                _projectProvider
                    .appletMap[_projectProvider.getIdFromKey(element)]
                    .scale = _projectProvider
                        .appletMap[_projectProvider.getIdFromKey(element)]
                        .scale *
                    _projectProvider.scaleChange;
              });
            }
          } else if (data.type == "TextApplet") {
            _projectProvider.appletMap[data.id].scale = _itemScale;

            _timer = new Timer(Duration(milliseconds: 1000), () {
              _projectProvider.appletMap[id].selected = true;
              setState(() {
                _timer = new Timer(Duration(milliseconds: 2000), () {
                  setState(() {
                    _projectProvider.appletMap[id].selected = false;
                  });
                });
              });
            });
          }

          return true;
        } else {
          return false;
        }
        /*else {
          //if for example textboxWidget
          if (_projectProvider.appletMap[id].key != data.key  &&
              //!_projectProvider.appletMap[null].childIds.contains(id) &&
              !_projectProvider.appletMap[id].childIds.contains(id)) {
            _projectProvider.changeItemListPosition(itemId: data.id, newId: id);
            _projectProvider.changeItemListPosition(itemId: data.id, newId: id);
            Key _dragItemTargetKey =
                _projectProvider.getActualTargetKey(data.key);
            String _dragItemTargetId =
                _projectProvider.getIdFromKey(_dragItemTargetKey);
            double _dragItemTargetScale =
                _projectProvider.appletMap[_dragItemTargetId].scale;

          // _projectProvider.changeItemListPosition(itemId: data.id, newId: id);
          Key _targetKey = _projectProvider.getActualTargetKey(data.id);
          double _targetScale = _projectProvider.appletMap[data.id].scale;
          _projectProvider.appletMap[data.id].scale = _targetScale;

            return true;
          } else {
            return false;
          }
        }*/
      }, onLeave: (dynamic data) {
        _projectProvider.appletMap[id].selected = false;
        // _projectProvider.leaveApplet = true;
      }, onAccept: (dynamic data) {
        if (data.type == 'TextApplet') {
          _projectProvider.appletMap[data.id].scale = _itemScale;
          if (_projectProvider.appletMap[id].selected == true) {
            _projectProvider.appletMap[data.id].fixed = true;
            _projectProvider.appletMap[data.id].position = Offset(10, 10);
            _projectProvider.appletMap[data.id].size =
                _projectProvider.appletMap[id].size * 0.9;
          } else {
            _projectProvider.appletMap[data.id].fixed = false;
          }
          _projectProvider.appletMap[id].selected = false;
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
            Visibility(
              visible: _projectProvider.appletMap[id].selected ? true : false,
              child: Container(
                  width: _projectProvider.appletMap[id].size.width +
                      20.0 / _stackScale,
                  height: _projectProvider.appletMap[id].size.height +
                      20.0 / _stackScale,
                  color: Colors.transparent),
            ),
            /*  SizedBox(
                  width: _projectProvider.appletMap[id].size.width *
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

            SizedBox(
              //key: widget.key,
              height: _projectProvider.appletMap[id].size.height * _itemScale,
              width: _projectProvider.appletMap[id].size.width * _itemScale,
              child: Material(
                shape: SuperellipseShape(
                  side: BorderSide(
                      color: _projectProvider.appletMap[id].selected
                          ? Colors.grey[900]
                          : Colors.transparent,
                      width: 3.0 * _itemScale),
                  borderRadius: BorderRadius.circular(28 * _itemScale),
                ),
                //margin: EdgeInsets.all(0),
                color: _projectProvider.appletMap[id].selected
                    ? _tonedColor(_projectProvider.appletMap[id].color)
                    : _projectProvider.appletMap[id].color,
                child: WindowStackBuilder(id),
              ),
            ),
            Visibility(
              visible: _projectProvider.appletMap[id].selected ? true : false,
              child: Transform.translate(
                offset: Offset(
                  (_projectProvider.appletMap[id].size.width - 20.0) *
                      _itemScale,
                  (_projectProvider.appletMap[id].size.height - 20.0) *
                      _itemScale,
                ),
                child: Transform.rotate(
                  angle: _scaleActive ? 0 : 340,
                  child: Material(
                    color: _scaleActive ? Colors.black87 : Colors.black87,
                    shape: CircleBorder(),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(100.0),
                      onTap: () {},
                      onLongPress: () {},
                      child: GestureDetector(
                        onTap: () {
                          print("horst");
                          setState(() {
                            _scaleActive = !_scaleActive;
                            print(_scaleActive);
                          });
                        },
                        onTapDown: (details) {
                          setState(() {
                            // _scaleActive = true;
                          });
                        },
                        onLongPressEnd: (details) {
                          offsetChange = Offset(0, 0);
                          setState(() {
                            //_scaleActive = false;
                          });
                        },
                        onLongPress: () {
                          print('ho');
                          setState(() {
                            //_scaleActive = true;
                          });
                        },
                        onLongPressStart: (details) {},
                        onPanUpdate: (details) {},
                        onLongPressMoveUpdate:
                            (LongPressMoveUpdateDetails details) {
                          Offset offsetDelta =
                              details.offsetFromOrigin / _stackScale -
                                  offsetChange;
                          offsetChange = details.offsetFromOrigin / _stackScale;
                          print(_projectProvider.appletMap[id].size);
                          if (!_scaleActive) {
                            setState(() {
                              _projectProvider.appletMap[id].size = Size(
                                  _projectProvider.appletMap[id].size.width >
                                          40 * _itemScale
                                      ? _projectProvider
                                              .appletMap[id].size.width +
                                          offsetDelta.dx / _itemScale
                                      : _projectProvider
                                              .appletMap[id].size.width +
                                          1 * _itemScale,
                                  _projectProvider.appletMap[id].size.height >
                                          40 * _itemScale
                                      ? _projectProvider
                                              .appletMap[id].size.height +
                                          offsetDelta.dy / _itemScale
                                      : _projectProvider
                                              .appletMap[id].size.width +
                                          1 * _itemScale);
                            });
                          } else {
                            var _ratioQuotient =
                                _projectProvider.appletMap[id].size.width /
                                    _projectProvider.appletMap[id].size.height;
                                    final Size originSize = _projectProvider.appletMap[id].size;
                                    final double originScale = _itemScale;
                             _projectProvider.appletMap[id].size = Size(
                                _projectProvider.appletMap[id].size.width >
                                        40 * _itemScale
                                    ? _projectProvider
                                            .appletMap[id].size.width +
                                        offsetDelta.dx / _itemScale
                                    : _projectProvider
                                            .appletMap[id].size.width +
                                         _itemScale,
                                _projectProvider.appletMap[id].size.height >
                                        40 * _itemScale
                                    ? _projectProvider
                                            .appletMap[id].size.height +
                                        (offsetDelta.dx *_ratioQuotient) / _itemScale
                                    : _projectProvider
                                            .appletMap[id].size.width +
                                         _itemScale);
                                _itemScale =  (offsetDelta.dx / originSize.width) *_itemScale; 
                            print('offsetchange $offsetChange');
                          print('offsetdelta $offsetDelta');
                          }

                          _projectProvider.notifyListeners();
                          _projectProvider.updateArrowToKeyMap(
                              _projectProvider.appletMap[id].key,
                              _dragStarted,
                              _projectProvider.appletMap[id].key);
                        },
                        child: Transform.scale(
                          scale: 0.7,
                          child: Icon(
                            _scaleActive ? Icons.zoom_out_map : Icons.play_arrow,
                            color: Colors.white,
                            size: 40.0 * _itemScale,
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
