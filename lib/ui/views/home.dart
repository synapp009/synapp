import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synapp/commonComponents/customCard.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:zefyr/zefyr.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid})
      : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String uid; //include this

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Project> projects;

  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;

  @override
  initState() {
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    final crudProvider = Provider.of<CRUDModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text("Log Out"),
            textColor: Colors.white,
            onPressed: () {
              FirebaseAuth.instance
                  .signOut()
                  .then((result) =>
                      Navigator.pushReplacementNamed(context, "/login"))
                  .catchError((err) => print(err));
            },
          )
        ],
      ),
      body: Scaffold(
        resizeToAvoidBottomPadding: true,
        body: ZefyrScaffold(
          child: Container(
            padding: const EdgeInsets.all(5.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: crudProvider.fetchProjectsAsStream(),
              //Firestore.instance.collection("projects").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new SpinKitRotatingCircle(
                      color: Colors.white,
                      size: 50.0,
                    );
                  default:
                    projects = snapshot.data.documents
                        .map(
                          (doc) => Project.fromMap(doc, doc.documentID),
                        )
                        .toList();
                    return new ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (buildContext, index) =>
                          CustomCard(projectDetails: projects[index]),
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showDialog,
          tooltip: 'Add',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: Column(
              children: <Widget>[
                Text("Please fill all fields to create a new task"),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: 'Task Title*'),
                    controller: taskTitleInputController,
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Task Description*'),
                    controller: taskDescripInputController,
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    taskTitleInputController.clear();
                    taskDescripInputController.clear();
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (taskDescripInputController.text.isNotEmpty &&
                        taskTitleInputController.text.isNotEmpty) {
                      Project project = new Project(
                          name: taskTitleInputController.text,
                          description: taskDescripInputController.text,
                          appletMap: {},
                          arrowMap: {});

                      Provider.of<CRUDModel>(context, listen: false)
                          .addProject(project)
                          .then((result) => {
                                Navigator.pop(context),
                                taskTitleInputController.clear(),
                                taskDescripInputController.clear(),
                              })
                          .catchError((err) => print(err));
                      //await Provider.of<CRUDModel>(context, listen: false)
                      //.addAppletMap(applet, docRef.documentID);

                      /*
                      docRef.setData(project)
                          .then((result) => {
                  
                                Navigator.pop(context),                              
                                taskTitleInputController.clear(),
                                taskDescripInputController.clear(),
                              })
                          .catchError((err) => print(err));*/

                    }
                  })
            ],
          );
        });
  }
}
