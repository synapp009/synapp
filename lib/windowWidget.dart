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
  WindowWidget({Key key}) : super(key: key);

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
  var windowKey;
  var _projectProvider;
  var _crudProvider;

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
  var _itemId;

  var _itemScale;

  double _stackScale;
  Offset _stackOffset;
  Offset offset = Offset(0, 0);
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

    _stackScale = _projectProvider.stackScale;
    windowKey = _projectProvider.appletMap[id].key;
    _itemScale = _projectProvider.appletMap[id].scale;

    _stackOffset = _projectProvider.stackOffset;

    _itemId = _projectProvider.appletMap[id].id;

//animation
    _animation() {
      _controller.forward();
      _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
        setState(() {
          _projectProvider.appletMap[id].selected =
              _projectProvider.appletMap[id].selected ? false : true;
          //_controller.reverse();
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
              //_controller.reverse();
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
            _timer = new Timer(Duration(milliseconds: 200), () {
              //_controller.reverse();
            });

            _pointerUpOffset = event.position;
            _pointerUp = true;
            _pointerMoving = false;
            _projectProvider.firstItem = true;

            offset = Offset(0, 0);
          },
          onPointerMove: (PointerMoveEvent event) {
            //_projectProvider.stackSizeHitTest(event.position);

            //update the position of all the arrows pointing to the window
            if (_dragStarted) {
              _projectProvider.updateArrowToKeyMap(
                  _projectProvider.appletMap[id].key,
                  _dragStarted,
                  feedbackKey);
            }

            offset =
                Offset(offset.dx + event.delta.dx, offset.dy + event.delta.dy);

            //_controller.reverse();

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

                  _timer = new Timer(Duration(milliseconds: 200), () {
                    _dragStarted = true;

                    _projectProvider.updateArrowToKeyMap(
                        _projectProvider.appletMap[id].key,
                        _dragStarted,
                        feedbackKey);
                    //setState(() {});
                  });
                },
                onDragCompleted: () {
                  _projectProvider.appletMap[id].position =
                      _projectProvider.itemDropPosition(
                          widget.key, _pointerDownOffset, _pointerUpOffset);

                  //_crudProvider.updateApplet(_projectProvider.id, _projectProvider.appletMap[id], id);
                },
                onDraggableCanceled: (vel, Offset off) {
                  _projectProvider.appletMap[id].position =
                      _projectProvider.itemDropPosition(
                          widget.key, _pointerDownOffset, _pointerUpOffset);

                  _projectProvider.stackSizeChange(id, feedbackKey, off);
                },
                dragAnchor: DragAnchor.pointer,
                childWhenDragging: Container(),
                feedback: ChangeNotifierProvider<Project>.value(
                  value: Provider.of<Project>(context),
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
        if (data.type == "WindowApplet") {
          if (_projectProvider.appletMap[id].key != data.key &&
              !_projectProvider.appletMap[data.id].childIds.contains(id) &&
              //!_projectProvider.appletMap[null].childIds.contains(id) &&
              !_projectProvider.appletMap[id].childIds.contains(id)) {
            _projectProvider.changeItemListPosition(itemId: data.id, newId: id);

            Key _targetKey = _projectProvider.getActualTargetKey(data.key);
            String _targetId = _projectProvider.getIdFromKey(_targetKey);
            double _targetScale = _projectProvider.appletMap[_targetId].scale;

            _projectProvider.appletMap[data.id].scale = _targetScale * 0.3;

            return true;
          } else {
            return false;
          }
        } else {
          //if for example textboxWidget

          // _projectProvider.changeItemListPosition(itemId: data.id, newId: id);
          Key _targetKey = _projectProvider.getActualTargetKey(data.id);
          double _targetScale = _projectProvider.appletMap[data.id].scale;
          _projectProvider.appletMap[data.id].scale = _targetScale;

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

          return true;
        }
      }, onLeave: (dynamic data) {
        _projectProvider.appletMap[id].selected = false;
        // _projectProvider.leaveApplet = true;
      }, onAccept: (dynamic data) {
        if (data.type == 'TextApplet') {
          _projectProvider.appletMap[data.key].scale = _itemScale;
          if (_projectProvider.appletMap[id].selected == true) {
            _projectProvider.appletMap[data.key].fixed = true;
            _projectProvider.appletMap[data.key].position = Offset(10, 10);
          } else {
            _projectProvider.appletMap[data.key].fixed = false;
          }
          _projectProvider.appletMap[id].selected = false;
        }
      }),
    );
  }

  Widget get _animatedButtonUI => Transform.scale(
        scale: _scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            ? Colors.black
                            : Colors.transparent,
                        width: 1 * _itemScale),
                    borderRadius: BorderRadius.circular(28 * _itemScale)),
                //margin: EdgeInsets.all(0),
                color: _projectProvider.appletMap[id].selected
                    ? _tonedColor(_projectProvider.appletMap[id].color)
                    : _projectProvider.appletMap[id].color,
                child: WindowStackBuilder(id),
              ),
            ),
          ],
        ),
      );
}
