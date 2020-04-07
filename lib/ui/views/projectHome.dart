import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:uuid/uuid.dart';

import '../../feedbackTextboxWidget.dart';
import '../../feedbackWindowWidget.dart';
import '../../stackAnimator.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, @required this.project}) : super(key: key);
  final Project project;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var isExec = true;
  @override
  void initState() {
    print('runinit');
    isExec = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);

    if (projectProvider.stackSize == null) {
      projectProvider.stackSize = MediaQuery.of(context).size;
    }
    if (!isExec) {
    projectProvider.initial = true;      
      projectProvider.statusBarHeight = MediaQuery.of(context).padding.top;

      projectProvider.updateStackWithMatrix(Matrix4.identity());
      isExec = true;
    }

    //projectProvider.updateProvider(widget.project, statusBarHeight);
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
      label: WindowApplet.label,
      iconData: WindowApplet.iconData,
      color: Colors.yellow,
    ),
    AppBuilder(
      id: null,
      itemKey: null,
      type: "TextApplet",
      label: TextApplet.label,
      iconData: TextApplet.iconData,
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
                  child: BottomSheetApp(
                      apps: _apps, projectProvider: projectProvider),
                ),
              );
              showFoatingActionButton(false);
              bottomSheetController.closed.then((value) {
                showFoatingActionButton(true);
              });
            },
            child: const Icon(Icons.add, size: 40),
          )
        : Container();
  }

  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}

class BottomSheetApp extends StatefulWidget {
  final List<AppBuilder> apps;
  final projectProvider;
  BottomSheetApp({this.apps, this.projectProvider});
  @override
  _BottomSheetAppState createState() =>
      _BottomSheetAppState(apps, projectProvider);
}

class _BottomSheetAppState extends State<BottomSheetApp> {
  _BottomSheetAppState(this.apps, this.projectProvider);
  List<AppBuilder> apps;
  var projectProvider;

  String id;
  GlobalKey feedbackKey;
  GlobalKey newAppKey;
  Offset _pointerDownOffset = Offset(0, 0);
  Offset _pointerUpOffset = Offset(0, 0);
  bool _appletDragged = false;
  Future<String> newAppletId;

  @override
  Widget build(BuildContext context) {
    apps = widget.apps;
    projectProvider = widget.projectProvider;

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
                    //Container(height:20,width:20,child:WindowWidget()),
                    FutureBuilder<String>(
                        future: newAppletId,
                        builder: (context, snapshot) {
                          if (projectProvider.appletMap[snapshot.data] !=
                                  null &&
                              snapshot.data != null) {
                            projectProvider.appletMap[snapshot.data].id =
                                snapshot.data;
                          }

                          return Listener(
                            onPointerDown: (event) {
                              //String id = new Uuid().v4();
                              GlobalKey newAppKey = new GlobalKey();
                              feedbackKey = new GlobalKey();

                              apps[index].itemKey = newAppKey;
                              apps[index].feedbackKey = feedbackKey;
                              newAppletId =
                                  projectProvider.createNewAppandReturnId(
                                      apps[index].type, newAppKey, context);

                              projectProvider.chosenId = newAppletId;
                              setState(() {});
                              _pointerDownOffset = Offset(75, 75);
                            },
                            onPointerMove: (event) {
                              projectProvider.appletMap[snapshot.data]
                                  .position = event.position;
                            },
                            onPointerUp: (event) {
                              _pointerUpOffset = event.position;

                              projectProvider.changeItemDropPosition(
                                  projectProvider.appletMap[snapshot.data],
                                  _pointerDownOffset,
                                  _pointerUpOffset);
                              projectProvider.chosenId = null;
                              /*    if (!_appletDragged) {
                          setState(() {
                            projectProvider.appletMap.remove(apps[index].id);
                          });
                        }*/
                              newAppletId = null;
                              setState(() {});
                            },
                            child: Draggable(
                              dragAnchor: DragAnchor.pointer,
                              onDragStarted: () {
                                _appletDragged = true;
                                HapticFeedback.mediumImpact();
                              },
                              onDragEnd: (details) => _appletDragged = false,
                              feedback: ChangeNotifierProvider<Project>.value(
                                value: projectProvider,
                                child: Material(
                                  color: Colors.transparent,
                                  child: FeedbackChooser(
                                      id: snapshot.data,
                                      type: apps[index].type,
                                      feedbackKey: feedbackKey),
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
                              data: projectProvider.appletMap[snapshot.data],
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
  final type;
  final id;
  final feedbackKey;

  FeedbackChooser({this.id, this.type, this.feedbackKey});

  @override
  Widget build(BuildContext context) {
    if (type == "WindowApplet") {
      return FeedbackWindowWidget(id, Offset(75.0, 75.0), feedbackKey);
    } else if (type == "TextApplet") {
      return FeedbackTextboxWidget(id, feedbackKey, Offset(25.0, 25.0));
    } else {
      return Container();
    }
  }
}
