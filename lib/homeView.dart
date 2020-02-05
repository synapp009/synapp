import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/myHome.dart';
import 'core/models/projectModel.dart';
import 'core/viewmodels/CRUDModel.dart';
import 'stackAnimator.dart';
import 'data.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, @required this.project}) : super(key: key);
  final Project project;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var crudProvider = Provider.of<CRUDModel>(context);
    dataProvider.structureMap = dataProvider.createStructureMap(widget.project);


    //set stackSize & headerHeight
    Provider.of<Data>(context).statusBarHeight =
        MediaQuery.of(context).padding.top;
    if (dataProvider.stackSize == null) {
      dataProvider.stackSize = MediaQuery.of(context).size;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white, //Color.fromRGBO(153, 56, 255, 1),
        title: Text(widget.project.name, style: TextStyle(color: Colors.black)),

        leading: new IconButton(
          onPressed: () {
            widget.project.appletMap = dataProvider.structureMap;
            //widget.project.appletMap = dataProvider.structureMap;
            crudProvider.updateProject(widget.project, widget.project.id);
            Navigator.pop(context);
          },
          color: Colors.black,
          icon: Icon(Icons.close),
        ),
      ),
      body: MyHome(widget.project.id),
    );
  }
}
