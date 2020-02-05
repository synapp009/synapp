import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/stackAnimator.dart';

import 'core/models/appletModel.dart';
import 'data.dart';

class MyHome extends StatefulWidget {
final id;
MyHome(this.id);
  @override
  _MyHomeState createState() => _MyHomeState();
}

class AppBuilder {
  dynamic type;
  String label;
  IconData iconData;
  Color color;
  GlobalKey itemKey;
  AppBuilder({this.label, this.iconData, this.type, this.color, this.itemKey});
}

class _MyHomeState extends State<MyHome> {
  List<AppBuilder> _apps = [
    AppBuilder(
      itemKey: new GlobalKey(),
      type: new WindowApplet(),
      label: WindowApplet.label,
      iconData: WindowApplet.iconData,
      color: Colors.yellow,
    ),
    AppBuilder(
      itemKey: new GlobalKey(),
      type: new TextApplet(),
      label: TextApplet.label,
      iconData: TextApplet.iconData,
      color: Colors.yellowAccent,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var crudProvider = Provider.of<CRUDModel>(context);
    BottomSheetApp modal = new BottomSheetApp(_apps, dataProvider);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () => modal.mainBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(244, 245, 248, 1),
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              color: Colors.black87,
              icon: Icon(Icons.chat),
              onPressed: () {},
            ),
            IconButton(
              color: Colors.black87,
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: StackAnimator(widget.id),
    );
  }
}

class BottomSheetApp {
  final _apps;
  final dataProvider;
  BottomSheetApp(this._apps, this.dataProvider);
  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color.fromRGBO(244, 245, 248, 1),
        isScrollControlled:
            true, //bottomsheet goes full screen, if bottomsheet has a scrollable widget such as a listview as a child.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Container(
                //scrollDirection: Axis.vertical,
                child: GridView.builder(
                  physics: new NeverScrollableScrollPhysics(),
                  itemCount: _apps.length,
                  //scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            key: _apps[index].itemKey,
                            onPressed: () {
                              //Navigator.pop(context);
                              dataProvider.createNewApp(
                                  _apps[index].type, _apps[index].itemKey);
                            },
                            child: new Icon(
                              _apps[index].iconData,
                              color: Colors.black87,
                              size: 35.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 0.0,
                            fillColor: _apps[index].color,
                            padding: const EdgeInsets.all(15.0),
                          ),
                          Text(_apps[index].label),
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
        });
  }
}

ListTile _createTile(BuildContext context, String name, IconData icon,
    Function action, dataProvider) {
  return ListTile(
    leading: Icon(icon),
    title: Text(name),
    onTap: () {
      dataProvider.createNewWindow();
      action();
    },
  );
}

_action1() {
}
