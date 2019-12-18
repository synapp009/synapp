import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

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
  double _scale;
  AnimationController _controller;
  Timer _timer;
  bool _isSelected = false;
  int maxSimultaneousDrags = 1;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
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

  final GlobalKey key;
  _WindowWidgetState(this.key);

  var pointerDownOffset = Offset(0, 0);
  var pointerUpOffset = Offset(0, 0);
  var onDragEndOffset;
  var pointerMoving = false;
  var pointerUp = false;
  var pointerMoveOffset = Offset(0, 0);
  var itemScale;
  final Key draggableKey = GlobalKey();
  var dataProvider;
  double stackScale;
  Offset offset = Offset(0, 0);

  _isPointerMoving() {
    _timer = new Timer(const Duration(milliseconds: 200), () {
      setState(() {
        if (!pointerMoving && !_isSelected) {
          _controller.forward();
          if (pointerUp) {
            _controller.reverse();
            pointerUp = false;
          }
        }
      });
    });
  }

  _animation() {
    _controller.forward();
    _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
      setState(() {
        _isSelected = _isSelected ? false : true;

        _controller.reverse();
      });
    });
  }

  tonedColor(Color color) {
    Color tempColor;
    var newR = color.red * (1 / 1.2);
    var newG = color.green * (1 / 1.2);
    var newB = color.blue * (1 / 1.2);
    tempColor = Color.fromRGBO(newR.toInt(), newG.toInt(), newB.toInt(), 1);
    return tempColor;
  }

  @override
  Widget build(BuildContext context) {
    dataProvider = Provider.of<Data>(context);
    stackScale = dataProvider.stackScale;
    itemScale = dataProvider.structureMap[key].scale;
    if (key == dataProvider.actualItemKey && !pointerMoving && !_isTapped) {
      _scale = 1 + _controller.value;
    } else if (key == dataProvider.actualItemKey &&
        !pointerMoving &&
        _isTapped) {
      _scale = 1 - _controller.value;
    } else {
      _scale = 1;
    }

    return Positioned(
      top: dataProvider.structureMap[key].position.dy * itemScale,
      left: dataProvider.structureMap[key].position.dx * itemScale,
      child: DragTarget(
          builder: (buildContext, List<dynamic> candidateData, rejectData) {
            return Listener(
              onPointerDown: (PointerDownEvent event) {
                if (dataProvider.firstItem) {
                  dataProvider.actualItemKey = key;
                  dataProvider.firstItem = false;
                }
                _isPointerMoving();

                setState(() {
                  pointerDownOffset = event.localPosition / itemScale;
                });

                pointerUp = false;
              },
              onPointerCancel: (details) {
                pointerMoving = false;
              },
              onPointerUp: (PointerUpEvent event) {
                _controller.reverse();
                pointerUpOffset = event.position;
                pointerUp = true;
                pointerMoving = false;
                dataProvider.firstItem = true;
                offset = Offset(0, 0);
              },
              onPointerMove: (PointerMoveEvent event) {
                offset = Offset(
                    offset.dx + event.delta.dx, offset.dy + event.delta.dy);

                _controller.reverse();
                if ((event.localPosition.dx - pointerDownOffset.dx).abs() >
                        30 / itemScale ||
                    (event.localPosition.dy - pointerDownOffset.dy).abs() >
                        30 / itemScale) {
                  pointerMoving = true;
                }
              },
              child: GestureDetector(
                onLongPressStart: (details) {
                  HapticFeedback.lightImpact();
                  dataProvider.addArrow(key);
                },
                onLongPressMoveUpdate: (details) {
                  dataProvider.sizeSetter(key, details.globalPosition);
                },
                onTap: () {
                  FocusScope.of(context).requestFocus(
                    new FocusNode(),
                  );
                  _isTapped = true;
                  //_isSelected = !_isSelected;
                  _animation();
                  maxSimultaneousDrags = _isSelected ? 0 : 1;
                  _isTapped = false;
                },
                child: LongPressDraggable(
                    key: draggableKey,
                    hapticFeedbackOnStart: true,
                    maxSimultaneousDrags: _isSelected ? 0 : 1,
                    onDragEnd: (DraggableDetails details) {
                      onDragEndOffset = details.offset;
                    },
                    onDragStarted: () {},
                    onDragCompleted: () {
                      setState(() {
                        dataProvider.structureMap[key].position =
                            dataProvider.itemDropPosition(
                                key, pointerDownOffset, pointerUpOffset);
                      });
                    },
                    onDraggableCanceled: (vel, Offset off) {
                      setState(() {
                        dataProvider.structureMap[key].position =
                            dataProvider.itemDropPosition(
                                key, pointerDownOffset, pointerUpOffset);
                      });
                    },
                    dragAnchor: DragAnchor.pointer,
                    childWhenDragging: Container(),
                    feedback: ListenableProvider<Data>.value(
                      value: Provider.of<Data>(context),
                      child: FeedbackWindowWidget(key, pointerDownOffset),
                    ),
                    child: _animatedButtonUI,
                    data: dataProvider.structureMap[key]),
              ),
            );
          },
          onWillAccept: (dynamic data) {
            if (data.toString().contains('Window')) {
              if (dataProvider.structureMap[key].key != data.key &&
                  !dataProvider.structureMap[data.key].childKeys
                      .contains(key)) {
                dataProvider.changeItemListPosition(
                    itemKey: data.key, newKey: key);
                var targetKey = dataProvider.getActualTargetKey(data.key);
                var targetScale = dataProvider.structureMap[targetKey].scale;

                dataProvider.structureMap[data.key].scale = targetScale * 0.3;

                return true;
              } else {
                return false;
              }
            } else {
              dataProvider.changeItemListPosition(
                  itemKey: data.key, newKey: key);
              var targetKey = dataProvider.getActualTargetKey(data.key);
              var targetScale = dataProvider.structureMap[targetKey].scale;
              dataProvider.structureMap[data.key].scale = targetScale * 0.3;

              return true;
            }
          },
          onLeave: (dynamic data) {},
          onAccept: (dynamic data) {}),
    );
  }

  Widget get _animatedButtonUI => Transform.scale(
        scale: _scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*  SizedBox(
                    width: dataProvider.structureMap[key].size.width *
                        itemScale,
                    height: 20 * itemScale,
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
              height: dataProvider.structureMap[key].size.height * itemScale,
              width: dataProvider.structureMap[key].size.width * itemScale,
              child: Material(
                shape: SuperellipseShape(
                    side: BorderSide(
                        color: _isSelected ? Colors.black : Colors.transparent,
                        width: 1 * itemScale),
                    borderRadius: BorderRadius.circular(28 * itemScale)),
                //margin: EdgeInsets.all(0),
                color: _isSelected
                    ? tonedColor(dataProvider.structureMap[key].color)
                    : dataProvider.structureMap[key].color,
                child: WindowStackBuilder(key),
              ),
            ),
          ],
        ),
      );
}
