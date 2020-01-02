import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:synapp/itemStackBuilder.dart';

import 'arrow.dart';
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
  final GlobalKey key;
  _WindowWidgetState(this.key);

  double _scale;
  AnimationController _controller;
  Timer _timer;

  int maxSimultaneousDrags = 1;
  bool _isTapped = false;
  bool _dragStarted = false;
  GlobalKey feedbackKey = GlobalKey();
  var dataProvider;



  @override
  void initState() {
    super.initState();
    //Animation Widget gets bigger when tapp and dragged and smaller when dropped
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

  var pointerDownOffset = Offset(0, 0);
  var pointerUpOffset = Offset(0, 0);
  var onDragEndOffset;
  var pointerMoving = false;
  var pointerUp = false;

  var itemScale;
  double stackScale;
  Offset stackOffset;
  Offset offset = Offset(0, 0);
  Map<Key, List<Key>> hasArrowToKeyMap = {};

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
    //bool dataProvider.selectedMap[key] = dataProvider.selectedMap[key];
    stackScale = dataProvider.stackScale;
    itemScale = dataProvider.structureMap[key].scale;
    stackOffset = dataProvider.stackOffset;

    _animation() {
      _controller.forward();
      _timer = new Timer(Duration(milliseconds: _isTapped ? 200 : 100), () {
        setState(() {
          dataProvider.selectedMap[key] =
              dataProvider.selectedMap[key] ? false : true;
          _controller.reverse();
        });
      });
    }
    bool keyIsTargetOrOrigin(k) {
      bool tempBool = false;

      if (dataProvider.arrowMap[key] != null) {
        dataProvider.arrowMap[key].forEach((Arrow a) => {
              if (a.target == k)
                {
                  tempBool = true,
                }
            });
      }

      dataProvider.arrowMap.forEach(
        ((Key originKey, List<Arrow> listOfArrows) => {
              listOfArrows.forEach((Arrow a) => {
                    if (a.target == key)
                      {
                        tempBool = true,
                      }
                  }),
            }),
      );
      return tempBool;
    }

    getAllArrows(key) {
      //get all arrows pointing to or coming from the item and also it's children items

      //all childItems pointing to or getting targetted
      List childList = dataProvider.getAllChildren(key);
      childList.add(key);

      childList.forEach((childKey) => {
            dataProvider.arrowMap
                .forEach((Key originKey, List<Arrow> listOfArrows) => {
                      if (originKey != null)
                        {
                          listOfArrows.forEach((Arrow a) => {
                                if (a.target == childKey &&
                                    keyIsTargetOrOrigin(childKey))
                                  {
                                    if (hasArrowToKeyMap[originKey] == null)
                                      {
                                        hasArrowToKeyMap[originKey] = [],
                                      },
                                    hasArrowToKeyMap[originKey].add(childKey),
                                  }
                                else
                                  {
                                    if (a.target != null &&
                                        keyIsTargetOrOrigin(a.target))
                                      {
                                        if (hasArrowToKeyMap[originKey] == null)
                                          {
                                            hasArrowToKeyMap[originKey] = [],
                                          },
                                        hasArrowToKeyMap[originKey]
                                            .add(a.target),
                                      },
                                  },
                              }),
                        }
                    })
          });
    }

    updateArrowToKeyMap(feedbackKey) {
      hasArrowToKeyMap.forEach((Key originKey, List<Key> listOfTargets) => {
            listOfTargets.forEach((Key targetKey) => {
                  if (_dragStarted && originKey == key)
                    {
                      dataProvider.updateArrow(
                        originKey: originKey,
                        feedbackKey: feedbackKey,
                        targetKey: targetKey,
                        draggedKey: originKey,
                        hasArrowToKeyMap: hasArrowToKeyMap,
                      )
                    }
                  else if (_dragStarted && targetKey == key)
                    {
                      dataProvider.updateArrow(
                          originKey: originKey,
                          feedbackKey: feedbackKey,
                          targetKey: targetKey,
                          draggedKey: targetKey,
                          hasArrowToKeyMap: hasArrowToKeyMap)
                    }
                  else
                    {
                      dataProvider.updateArrow(
                          originKey: originKey,
                          feedbackKey: feedbackKey,
                          targetKey: targetKey,
                          draggedKey: feedbackKey,
                          hasArrowToKeyMap: hasArrowToKeyMap)
                    }
                })
          });
    }

    _isPointerMoving() {
      _timer = new Timer(const Duration(milliseconds: 200), () {
        setState(() {
          if (!pointerMoving && !dataProvider.selectedMap[key]) {
            _controller.forward();
            if (pointerUp) {
              _controller.reverse();
              pointerUp = false;
            }
          }
        });
      });
    }

    //scale-animation
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
      top: dataProvider.structureMap[key].position.dy *
          itemScale, // - (stackOffset.dy/stackScale),
      left: dataProvider.structureMap[key].position.dx *
          itemScale, // - (stackOffset.dx/stackScale),
      child: DragTarget(
          builder: (buildContext, List<dynamic> candidateData, rejectData) {
            return Listener(
              onPointerDown: (PointerDownEvent event) {
                pointerUp = false;
                if (dataProvider.firstItem) {
                  dataProvider.actualItemKey = key;
                  getAllArrows(key);
                  dataProvider.firstItem = false;
                }

                //threshold
                _isPointerMoving();

                setState(() {
                  pointerDownOffset = event.localPosition / itemScale;
                });
              },
              onPointerCancel: (details) {
                // hasArrowToKeyMap = {};

                pointerMoving = false;
              },
              onPointerUp: (PointerUpEvent event) {
                _controller.reverse();
                // print(event.position);
                // print(dataProvider.stackSizeHitTest(event.localPosition));
                pointerUpOffset = event.position;
                pointerUp = true;
                pointerMoving = false;
                dataProvider.firstItem = true;

                offset = Offset(0, 0);
              },
              onPointerMove: (PointerMoveEvent event) {
                //dataProvider.stackSizeHitTest(event.position);

                //update the position of all the arrows pointing to the window
                if (_dragStarted) {
                  updateArrowToKeyMap(feedbackKey);
                }

                offset = Offset(
                    offset.dx + event.delta.dx, offset.dy + event.delta.dy);

                _controller.reverse();

                //set if Pointer is Moving with threshold
                if ((event.localPosition.dx - pointerDownOffset.dx).abs() >
                        30 / itemScale ||
                    (event.localPosition.dy - pointerDownOffset.dy).abs() >
                        30 / itemScale) {
                  pointerMoving = true;
                }
              },
              child: GestureDetector(
                onDoubleTap: () {
                  // dataProvider.zoomToBox(key, context);
                },
                onLongPressStart: (details) {
                  HapticFeedback.mediumImpact();
                
 
                  dataProvider.addArrow(key);

                  dataProvider.onlySelectThis(key);
                },
                onLongPressMoveUpdate: (details) {
                  dataProvider.hitTest(key, details.globalPosition, context);
                  dataProvider.setArrowToPointer(key, details.globalPosition);
                },
                onLongPressEnd: (details) {
                  dataProvider.connectAndUnselect(key);
                },
                onLongPressUp: () {},
                onTap: () {
                  FocusScope.of(context).requestFocus(
                    new FocusNode(),
                  );
                  _isTapped = true;
                  //dataProvider.selectedMap[key] = !dataProvider.selectedMap[key];
                  _animation();
                  maxSimultaneousDrags = dataProvider.selectedMap[key] ? 0 : 1;
                  _isTapped = false;
                },
                child: LongPressDraggable(
                    //hapticFeedbackOnStart: true,
                    maxSimultaneousDrags: dataProvider.selectedMap[key] ? 0 : 1,
                    onDragEnd: (DraggableDetails details) {
                      onDragEndOffset = details.offset;

                      _timer = new Timer(Duration(milliseconds: 200), () {
                        setState(() {
                          updateArrowToKeyMap(key);
                          _dragStarted = false;
                          hasArrowToKeyMap = {};
                        });
                      });
                    },
                    onDragStarted: () {
                      HapticFeedback.mediumImpact();
                      _dragStarted = true;

                      _timer = new Timer(Duration(milliseconds: 200), () {
                        setState(() {
                          updateArrowToKeyMap(feedbackKey);
                        });
                      });
                    },
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

                      dataProvider.stackSizeChange(feedbackKey, off);
                    },
                    dragAnchor: DragAnchor.pointer,
                    childWhenDragging: Container(),
                    feedback: ChangeNotifierProvider<Data>.value(
                      value: Provider.of<Data>(context),
                      child: FeedbackWindowWidget(
                          key, pointerDownOffset, feedbackKey),
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
                        color: dataProvider.selectedMap[key]
                            ? Colors.black
                            : Colors.transparent,
                        width: 1 * itemScale),
                    borderRadius: BorderRadius.circular(28 * itemScale)),
                //margin: EdgeInsets.all(0),
                color: dataProvider.selectedMap[key]
                    ? tonedColor(dataProvider.structureMap[key].color)
                    : dataProvider.structureMap[key].color,
                child: WindowStackBuilder(key),
              ),
            ),
          ],
        ),
      );
}
