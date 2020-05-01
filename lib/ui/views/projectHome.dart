import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/ui/widgets/arrowWidget.dart';
import 'package:synapp/ui/widgets/textboxWidget.dart';
import 'package:synapp/ui/widgets/windowWidget.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

import 'package:after_layout/after_layout.dart';

import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

import 'package:zefyr/zefyr.dart';
import '../../core/models/appletModel.dart';
import '../../core/models/projectModel.dart';

import '../../core/models/arrowModel.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, @required this.project}) : super(key: key);
  final Project project;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AfterLayoutMixin<HomeView> {
  bool isExec = false;

  @override
  void afterFirstLayout(BuildContext context) {
    var projectProvider = Provider.of<Project>(context, listen: false);

    setState(() {
      projectProvider.setInitialStackSizeAndOffset();
      projectProvider.getInitialStackViewAsMatrix(Matrix4.identity());
    });
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    if (projectProvider.stackSize == null) {
      projectProvider.stackSize = MediaQuery.of(context).size;
    }
    if (!isExec) {
      //projectProvider.updateStackWithMatrix(Matrix4.identity());
      isExec = true;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white, //Color.fromRGBO(153, 56, 255, 1),
        title: Text(widget.project.name, style: TextStyle(color: Colors.black)),

        leading: new IconButton(
          onPressed: () {
            //crudProvider.updateProject(projectProvider, widget.project.projectId);

            Navigator.pop(context);
          },
          color: Colors.black,
          icon: Icon(Icons.close),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: MyHome(widget.project),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  final project;
  MyHome(this.project);
  @override
  _MyHomeState createState() => _MyHomeState();
}

class AppBuilder {
  String id;
  dynamic type;
  String label;
  IconData iconData;
  Color color;
  GlobalKey itemKey;
  GlobalKey feedbackKey;
  AppBuilder(
      {this.id,
      this.label,
      this.iconData,
      this.type,
      this.color,
      this.itemKey,
      this.feedbackKey});
}

class _MyHomeState extends State<MyHome> {
  List<AppBuilder> _apps = [
    AppBuilder(
      id: null,
      itemKey: null,
      type: "WindowApplet",
      label: Applet.iconLabelMap["WindowApplet"],
      iconData: Applet.iconDataMap["WindowApplet"],
      color: Colors.yellow,
    ),
    AppBuilder(
      id: null,
      itemKey: null,
      type: "TextApplet",
      label: Applet.iconLabelMap["TextApplet"],
      iconData: Applet.iconDataMap["TextApplet"],
      color: Colors.yellowAccent,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _MyFloatingActionButton(_apps, projectProvider),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(244, 245, 248, 1),
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              color: Colors.grey[900],
              icon: Icon(Icons.chat),
              onPressed: () {},
            ),
            IconButton(
              color: Colors.grey[900],
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: StackAnimator(widget.project),
    );
  }
}

class _MyFloatingActionButton extends StatefulWidget {
  _MyFloatingActionButton(this._apps, this.projectProvider);
  final List<AppBuilder> _apps;
  final projectProvider;
  @override
  __MyFloatingActionButtonState createState() =>
      __MyFloatingActionButtonState(_apps, projectProvider);
}

class __MyFloatingActionButtonState extends State<_MyFloatingActionButton> {
  bool showFab = true;
  List<AppBuilder> _apps;
  var projectProvider;
  __MyFloatingActionButtonState(this._apps, this.projectProvider);

  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            backgroundColor: Colors.grey[900],
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => Container(
                  //color: Color.fromRGBO(244, 245, 248, 1),
                  height: 120,
                  decoration: new BoxDecoration(
                    //boxShadow:[BoxShadow(color: Colors.black, offset: Offset(0.0, -5.0))],
                    color: Color.fromRGBO(244, 245, 248, 1),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(40.0),
                      topRight: const Radius.circular(40.0),
                    ),
                  ),
                  child: BottomSheetApp(apps: _apps),
                ),
              );
              showFloatingActionButton(false);
              bottomSheetController.closed.then((value) {
                showFloatingActionButton(true);
              });
            },
            child: const Icon(Icons.add, size: 40),
          )
        : Container();
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}

class BottomSheetApp extends StatefulWidget {
  final List<AppBuilder> apps;

  BottomSheetApp({this.apps});
  @override
  _BottomSheetAppState createState() => _BottomSheetAppState(apps);
}

class _BottomSheetAppState extends State<BottomSheetApp> {
  _BottomSheetAppState(this.apps);
  List<AppBuilder> apps;

  String id;
  GlobalKey _feedbackKey;
  Offset _pointerDownOffset = Offset(0, 0);
  Offset _pointerUpOffset = Offset(0, 0);
  String newAppId;
  Future<Applet> newApplet;
  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var stackOffset = projectProvider.stackOffset;
    var stackScale = projectProvider.stackScale;
    return FractionallySizedBox(
      //heightFactor: 0.2,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Container(
          //scrollDirection: Axis.vertical,
          child: GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            itemCount: apps.length,
            //scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<Applet>(
                        future: newApplet,
                        builder: (context, newAppletFuture) {
                          return Listener(
                            onPointerDown: (event) {
                              _feedbackKey = new GlobalKey();
                              newApplet = projectProvider
                                  .createNewApp(apps[index].type);
                              setState(() {});

                              _pointerDownOffset = Offset(75, 75);
                            },
                            onPointerMove: (event) {
                              newAppletFuture.data.position =
                                  projectProvider.getDropPosition(
                                      applet: newAppletFuture.data,
                                      pointerDownOffset: _pointerDownOffset,
                                      pointerUpOffset: event.position);
                            },
                            onPointerUp: (event) {
                              _pointerUpOffset = event.position;
                              projectProvider.chosenId = null;
                              setState(() {});
                            },
                            child: Draggable(
                              onDragEnd: (details) {
                                print('ondragend');
                              },
                              onDragCompleted: () {
                                print('ondrag completed');
                                projectProvider.changeItemDropPosition(
                                    initialize: true,
                                    applet: newAppletFuture.data,
                                    feedbackKey: _feedbackKey,
                                    pointerDownOffset: _pointerDownOffset,
                                    pointerUpOffset: _pointerUpOffset);
/*
                                projectProvider.changeItemDropPosition(
                                    applet: newAppletFuture.data,
                                    feedbackKey: _feedbackKey,
                                    pointerDownOffset: _pointerDownOffset,
                                    pointerUpOffset: _pointerUpOffset);*/
                              },
                              onDraggableCanceled: (v, o) {
                                projectProvider.changeItemDropPosition(
                                    initialize: true,
                                    applet: newAppletFuture.data,
                                    feedbackKey: _feedbackKey,
                                    pointerDownOffset: _pointerDownOffset,
                                    pointerUpOffset: _pointerUpOffset);
                              },
                              childWhenDragging: RawMaterialButton(
                                onPressed: () {},
                                child: new Icon(
                                  apps[index].iconData,
                                  color: Colors.black87,
                                  size: 35.0,
                                ),
                                shape: new CircleBorder(),
                                elevation: 0.0,
                                fillColor: apps[index].color,
                                padding: const EdgeInsets.all(15.0),
                              ),
                              dragAnchor: DragAnchor.pointer,
                              onDragStarted: () {
                                HapticFeedback.mediumImpact();
                              },
                              //onDragEnd: (details) => _appletDragged = false,
                              feedback: ChangeNotifierProvider<Project>.value(
                                value: projectProvider,
                                child: Material(
                                  color: Colors.transparent,
                                  child: FeedbackChooser(
                                      applet: newAppletFuture.data,
                                      feedbackKey: _feedbackKey),
                                ),
                              ),
                              child: RawMaterialButton(
                                onPressed: () {},
                                child: new Icon(
                                  apps[index].iconData,
                                  color: Colors.black87,
                                  size: 35.0,
                                ),
                                shape: new CircleBorder(),
                                elevation: 0.0,
                                fillColor: apps[index].color,
                                padding: const EdgeInsets.all(15.0),
                              ),
                              data: newAppletFuture.data,
                            ),
                          );
                        }),
                    Text(apps[index].label),
                  ]);
            },
            //padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class FeedbackChooser extends StatelessWidget {
  final applet;
  final feedbackKey;

  FeedbackChooser({this.applet, this.feedbackKey});

  @override
  Widget build(BuildContext context) {
    if (applet.type == "WindowApplet") {
      return FeedbackWindowWidget(applet, Offset(75.0, 75.0), feedbackKey);
    } else if (applet.type == "TextApplet") {
      return FeedbackTextboxWidget(applet, feedbackKey, Offset(25.0, 25.0));
    } else {
      return Container();
    }
  }
}

class StackAnimator extends StatefulWidget {
  final project;
  StackAnimator(this.project);
  @override
  _StackAnimatorState createState() => _StackAnimatorState();
}

class _StackAnimatorState extends State<StackAnimator>
    with AfterLayoutMixin<StackAnimator> {
  bool isExec = true;
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    isExec = false;
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Matrix4> notifier;
    var projectProvider = Provider.of<Project>(context);
    if (projectProvider.notifier == null) {
      projectProvider.notifier =
          Constants.initializeNotifier(Matrix4.identity());
    }
    notifier = projectProvider.notifier;

    return ZefyrScaffold(
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          //notifier.value = m;

          projectProvider.stackScale = notifier.value.row0[0];
          projectProvider.stackOffset =
              Offset(notifier.value.row0.a, notifier.value.row1.a);
//continue with the initial view after moving but then change to matrixgesturedetector input
          notifier.value =
              !isExec ? projectProvider.getInitialStackViewAsMatrix(m) : m;

          isExec = true;
          projectProvider.setMaxScaleAndOffset(context);
        },
        shouldRotate: false,
        child: Stack(children: [
          Container(color: Colors.transparent),
          Positioned(
            top: 0,
            left: 0,
            child: AnimatedBuilder(
                animation: projectProvider.notifier,
                builder: (context, child) {
                  return Transform(
                    transform: projectProvider.notifier.value,
                    child: ItemStackBuilder(widget.project.projectId),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}

class ItemStackBuilder extends StatefulWidget {
  final id;
  ItemStackBuilder(this.id);

  @override
  _ItemStackBuilderState createState() => _ItemStackBuilderState();
}

class _ItemStackBuilderState extends State<ItemStackBuilder>
    with AfterLayoutMixin<ItemStackBuilder> {
  void afterFirstLayout(BuildContext context) {
    isExec = false;
  }

  bool isExec = true;
  var _backgroundStackKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    projectProvider.backgroundStackKey = _backgroundStackKey;

    return Stack(overflow: Overflow.visible, children: [
      DragTarget(
        builder: (buildContext, List<dynamic> candidateData, rejectData) {
          return Container(
            key: _backgroundStackKey,
            decoration: new BoxDecoration(
              border: Border.all(color: Colors.grey[900]),
              borderRadius: BorderRadius.circular(3),
            ),
            width: projectProvider.stackSize.width,
            height: projectProvider.stackSize.height,
            child: GestureDetector(
              onTap: () {
                //remove focus
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                projectProvider.unselectAll();
              },
            ),
          );
        },
        onWillAccept: (Applet data) {
          var stackOffset = Offset(projectProvider.notifier.value.row0.a,
              projectProvider.notifier.value.row1.a);
          double _scaleChange = data.scale;
          projectProvider.targetId = "parentApplet";

          data.scale = 1.0;
          projectProvider.currentTargetPosition = stackOffset;
          projectProvider.scaleChange = data.scale / _scaleChange;
          projectProvider.notifyListeners();
          if (data.type == "WindowApplet") {
            List<String> childrenList =
                Provider.of<Project>(context, listen: false)
                    .getAllChildren(applet: data);
            if (childrenList != null) {
              childrenList.forEach((element) {
                if (element != null) {
                  projectProvider.appletMap[element].scale =
                      projectProvider.appletMap[element].scale *
                          projectProvider.scaleChange;
                }
              });
            }
          }

          if (!projectProvider.appletMap["parentApplet"].childIds
              .contains(data.id)) {
            /*projectProvider.changeItemListPosition(
                itemId: data.id, newId: "parentApplet", applet: data);*/
            return true;
          } else {
            return false;
          }
        },
        onLeave: (Applet data) {},
        onAccept: (Applet data) {
          if (!projectProvider.appletMap["parentApplet"].childIds
              .contains(data.id)) {}

          if (data.type == 'TextApplet') {
            data.scale = 1.0;
            if (data.selected == true) {
              data.fixed = true;
              data.position = Offset(10, 10);
              data.size = data.size * 0.9;
            } else {
              data.fixed = false;
            }
            data.selected = false;
          }
        },
      ),
      ...stackItems(context),
      ...arrowItems(context),
    ]);
  }

  List<Widget> stackItems(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    List<Widget> stackItemsList = [];
    Widget stackItemDraggable;
    List childIdList = [];
    List<GlobalKey> childKeyList = [];
    if (projectProvider.appletMap["parentApplet"] != null) {
      childIdList = projectProvider.appletMap["parentApplet"].childIds;
      childKeyList = projectProvider.appletMap["parentApplet"].childIds
          .map((e) => projectProvider.getGlobalKeyFromId(e))
          .toList();
    }

    List<Applet> appletList = projectProvider.appletMap["parentApplet"].childIds
        .map((v) => projectProvider.appletMap[v])
        .toList();

    for (int i = 0; i < appletList.length; i++) {
      if (appletList[i].type == "WindowApplet") {
        stackItemDraggable = WindowWidget(applet: appletList[i]);
      } else if (appletList[i].type == "TextApplet") {
        stackItemDraggable = TextboxWidget(applet: appletList[i]);
      } else {
        stackItemDraggable = Container(width: 0, height: 0);
      }

      stackItemsList.add(stackItemDraggable);
    }
    return stackItemsList;
  }
}

List<Widget> arrowItems(BuildContext context) {
  var projectProvider = Provider.of<Project>(context);
  List<Widget> arrowItemsList = [];
  List<Applet> appletList = projectProvider.appletMap.values.toList();
  Key originKey;
  Key targetKey;
  for (int i = 0; i < appletList.length; i++) {
    if (appletList[i].arrowMap != null) {
      appletList[i].arrowMap.forEach((String id, Arrow arrow) => {
            originKey = projectProvider.getKeyFromId(appletList[i].id),
            if (originKey != null)
              {
                targetKey = projectProvider.getKeyFromId(id),
                arrowItemsList.add(ArrowWidget(originKey, targetKey)),
              }
          });
    }
  }
  return arrowItemsList;
}
