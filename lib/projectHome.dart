import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/projectHomeView.dart';
import 'core/models/appletModel.dart';
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
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var projectProvider = Provider.of<Project>(context);
    var crudProvider = Provider.of<CRUDModel>(context);

    //set stackSize & headerHeight
    projectProvider.statusBarHeight = MediaQuery.of(context).padding.top;

    if (projectProvider.stackSize == null) {
      projectProvider.stackSize = MediaQuery.of(context).size;
    }
    var statusBarHeight = MediaQuery.of(context).padding.top;
    //projectProvider.updateProvider(widget.project, statusBarHeight);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white, //Color.fromRGBO(153, 56, 255, 1),
        title: Text(widget.project.name, style: TextStyle(color: Colors.black)),

        leading: new IconButton(
          onPressed: () {

            crudProvider.updateProject(projectProvider, widget.project.id);
            //projectProvider.appletMap.clear();
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
