import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:synapp/itemStackBuilder.dart';

import 'core/models/appletModel.dart';
import 'data.dart';

import 'windowStackBuilder.dart';
import 'feeddbackWindowWidget.dart';

class WindowWidget extends StatefulWidget {
  const WindowWidget({GlobalKey key}) : super(key: key);
  @override
  _WindowWidgetState createState() => _WindowWidgetState(key);
}

class _WindowWidgetState extends State<WindowWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey windowKey;
  _WindowWidgetState(this.windowKey);

  double _scale;
  AnimationController _controller;
  Timer _timer;

  int _maxSimultaneousDrags = 1;
  bool _isTapped = false;
  bool _dragStarted = false;
  GlobalKey feedbackKey = GlobalKey();
  GlobalKey sizedBoxKey = GlobalKey();
  var _dataProvider;

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

  var _itemScale;

  double _stackScale;
  Offset _stackOffset;
  Offset offset = Offset(0, 0);
  Map<Key, List<Key>> hasArrowToKeyMap = {};

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
    _dataProvider = Provider.of<Data>(context);

    _stackScale = _dataProvider.stackScale;
    _itemScale = _dataProvider.structureMap[windowKey].scale;
    _stackOffset = _dataProvider.stackOffset;

//animation
    _animation() {
      _controller.forward();
      _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
        setState(() {
          _dataProvider.selectedMap[windowKey] =
              _dataProvider.selectedMap[windowKey] ? false : true;
          _controller.reverse();
        });
      });
    }

    if (windowKey == _dataProvider.actualItemKey &&
        !_pointerMoving &&
        !_isTapped) {
      _scale = 1 + _controller.value;
    } else if (windowKey == _dataProvider.actualItemKey &&
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
          if (!_pointerMoving && !_dataProvider.selectedMap[windowKey]) {
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
      top: _dataProvider.structureMap[windowKey].position.dy * _itemScale,
      left: _dataProvider.structureMap[windowKey].position.dx * _itemScale,
      child: DragTarget(
          builder: (buildContext, List<dynamic>  candidateData, rejectData) {
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            _pointerUp = false;
            if (_dataProvider.firstItem) {
              _dataProvider.actualItemKey = windowKey;
              _dataProvider.getAllArrows(windowKey);
              _dataProvider.firstItem = false;
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
            _dataProvider.firstItem = true;

            offset = Offset(0, 0);
          },
          onPointerMove: (PointerMoveEvent event) {
            //_dataProvider.stackSizeHitTest(event.position);

            //update the position of all the arrows pointing to the window
            if (_dragStarted) {
              _dataProvider.updateArrowToKeyMap(
                  windowKey, _dragStarted, feedbackKey);
            }

            offset =
                Offset(offset.dx + event.delta.dx, offset.dy + event.delta.dy);

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
              // _dataProvider.zoomToBox(windowKey, context);
            },
            onLongPressStart: (details) {
              HapticFeedback.mediumImpact();

              _dataProvider.addArrow(windowKey);

              //only select the creating window
              _dataProvider.onlySelectThis(windowKey);
            },
            onLongPressMoveUpdate: (details) {
              _dataProvider.hitTest(windowKey, details.globalPosition, context);
              _dataProvider.setArrowToPointer(
                  windowKey, details.globalPosition);
            },
            onLongPressEnd: (details) {
              _dataProvider.connectAndUnselect(windowKey);
            },
            onLongPressUp: () {},
            onTap: () {
              FocusScope.of(context).requestFocus(
                new FocusNode(),
              );

              _isTapped = true;
              _animation();
              _maxSimultaneousDrags =
                  _dataProvider.selectedMap[windowKey] ? 0 : 1;
              _isTapped = false;
            },
            child: LongPressDraggable(
                //hapticFeedbackOnStart: true,

                maxSimultaneousDrags:
                    _dataProvider.selectedMap[windowKey] ? 0 : 1,
                onDragEnd: (DraggableDetails details) {
                  //_dataProvider.updateArrowToKeyMap(windowKey, _dragStarted, feedbackKey);
                  _timer = new Timer(Duration(milliseconds: 200), () {
                    setState(() {
                      _dragStarted = false;
                      _dataProvider.updateArrowToKeyMap(
                          windowKey, _dragStarted, windowKey);

                      _dataProvider.hasArrowToKeyMap.clear();
                    });
                  });
                },
                onDragStarted: () {
                  HapticFeedback.mediumImpact();

                  _timer = new Timer(Duration(milliseconds: 200), () {
                    _dragStarted = true;
                    setState(() {
                      _dataProvider.updateArrowToKeyMap(
                          windowKey, _dragStarted, feedbackKey);
                    });
                  });
                },
                onDragCompleted: () {
                  setState(() {
                    _dataProvider.structureMap[windowKey].position =
                        _dataProvider.itemDropPosition(
                            windowKey, _pointerDownOffset, _pointerUpOffset);
                  });
                },
                onDraggableCanceled: (vel, Offset off) {
                  setState(() {
                    _dataProvider.structureMap[windowKey].position =
                        _dataProvider.itemDropPosition(
                            windowKey, _pointerDownOffset, _pointerUpOffset);
                  });

                  _dataProvider.stackSizeChange(windowKey, feedbackKey, off);
                },
                dragAnchor: DragAnchor.pointer,
                childWhenDragging: Container(),
                feedback: ChangeNotifierProvider<Data>.value(
                  value: Provider.of<Data>(context),
                  child: FeedbackWindowWidget(
                      windowKey, _pointerDownOffset, feedbackKey),
                ),
                child: _animatedButtonUI,
                data: _dataProvider.structureMap[windowKey]
                ),
          ),
        );
      }, onWillAccept: (dynamic data) {

       
        //true if window changes target
        if (data.type == "WindowApplet") {
          if (_dataProvider.structureMap[windowKey].key != data.key &&
              !_dataProvider.structureMap[data.key].childKeys
                  .contains(windowKey)) {
            _dataProvider.changeItemListPosition(
                itemKey: data.key, newKey: windowKey);
            Key _targetKey = _dataProvider.getActualTargetKey(data.key);
            double _targetScale = _dataProvider.structureMap[_targetKey].scale;

            _dataProvider.structureMap[data.key].scale = _targetScale * 0.3;

            return true;
          } else {
            return false;
          }
        } else {
          //if for example textboxWidget

          _dataProvider.changeItemListPosition(
              itemKey: data.key, newKey: windowKey);
          Key _targetKey = _dataProvider.getActualTargetKey(data.key);
          double _targetScale = _dataProvider.structureMap[_targetKey].scale;
          _dataProvider.structureMap[data.key].scale = _targetScale;

          _dataProvider.structureMap[data.key].scale = _itemScale;
          _timer = new Timer(Duration(milliseconds: 1000), () {
            _dataProvider.selectedMap[windowKey] = true;
            setState(() {
              _timer = new Timer(Duration(milliseconds: 2000), () {
                setState(() {
                  _dataProvider.selectedMap[windowKey] = false;
                });
              });
            });
          });
          return true;
        }
      }, onLeave: (dynamic data) {
        _dataProvider.selectedMap[windowKey] = false;
      }, onAccept: (dynamic data) {
        if (data.type == 'TextApplet') {
          _dataProvider.structureMap[data.key].scale = _itemScale;
          if (_dataProvider.selectedMap[windowKey] == true) {
            _dataProvider.structureMap[data.key].fixed = true;
            _dataProvider.structureMap[data.key].position = Offset(10, 10);
          } else {
            _dataProvider.structureMap[data.key].fixed = false;
          }
          _dataProvider.selectedMap[windowKey] = false;
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
                  width: _dataProvider.structureMap[windowKey].size.width *
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
              key: sizedBoxKey,
              height: _dataProvider.structureMap[windowKey].size.height *
                  _itemScale,
              width:
                  _dataProvider.structureMap[windowKey].size.width * _itemScale,
              child: Material(
                shape: SuperellipseShape(
                    side: BorderSide(
                        color: _dataProvider.selectedMap[windowKey]
                            ? Colors.black
                            : Colors.transparent,
                        width: 1 * _itemScale),
                    borderRadius: BorderRadius.circular(28 * _itemScale)),
                //margin: EdgeInsets.all(0),
                color: _dataProvider.selectedMap[windowKey]
                    ? _tonedColor(_dataProvider.structureMap[windowKey].color)
                    : _dataProvider.structureMap[windowKey].color,
                child: WindowStackBuilder(windowKey),
              ),
            ),
          ],
        ),
      );
}
