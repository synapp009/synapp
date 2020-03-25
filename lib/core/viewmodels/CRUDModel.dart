import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import '../../locator.dart';
import '../services/api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CRUDModel extends ChangeNotifier {
  Api _api = locator<Api>();

  List<Project> projects;

  Future<List<Project>> fetchProjects() async {
    var result = await _api.getDataCollection();
    projects = result.documents
        .map((doc) => Project.fromMap(doc, doc.documentID))
        .toList();
    return projects;
  }

  Stream<QuerySnapshot> fetchProjectsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Project> getProjectById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Project.fromMap(doc, doc.documentID);
  }

  Future removeProject(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateProject(Project data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future updateApplet(String projectId, Applet applet, String appletId) async {
    await _api.updateApplet(projectId, applet.toJson(), appletId);
    return;
  }

  Future addApplet(String projectId, Applet data) async {
    await _api.addApplet(projectId, data.toJson());
    return;
  }

  Future addProject(Project data) async {
    await _api.addDocument(data.toJson());
    return;
  }

  Stream<List<Applet>> fetchAppletsAsStream(String projectId) {
    var ref = Firestore.instance
        .collection('projects')
        .document(projectId)
        .collection('applets');
    return ref.snapshots().map(
        (list) => list.documents.map((doc) => Applet.fromMap(doc)).toList());
  }
  /*Stream<QuerySnapshot> fetchAppletsAsStream(String projectId) {
    print('stream snapshot ${_api.streamAppletCollection(projectId)}');
    return _api.streamAppletCollection(projectId);
  }*/

  Future<List<Applet>> getAppletsById(String id) async {
    List<Applet> list = new List();
    var doc = await _api.getAppletById(id);
    doc.forEach((DocumentSnapshot docSnapshot) {
      list.add(Applet.fromMap(docSnapshot));
    });
    /*map((DocumentSnapshot docSnapshot) {
     
       Applet.fromMap(docSnapshot);
    }).toList();*/
    return list;
  }

  Future<String> createNewAppandReturnId(
      String projectId, Key newAppKey, BuildContext context) async {
    //RenderBox itemBox = itemKey.currentContext.findRenderObject();
    //Offset appPosition = itemBox.globalToLocal(Offset.zero);
    String appletId;

    Applet newApplet = new Applet(key: newAppKey, selected: false);
    String newEntry = 'newApplet';
    Map<String, dynamic> data = {'new': newEntry};

   var doc =  await Firestore.instance
        .collection("projects")
        .document(projectId)
        .collection("applets")
        .add(data);

      var id =  doc.documentID;
      var tempData = data;
      tempData["id"] = id;

      Firestore.instance
          .collection("projects")
          .document(projectId)
          .collection("applets")
          .document(id)
          .updateData(tempData);
 
    /*
    if (type == "WindowApplet") {
      id = createNewWindow(newAppKey, context);
    } else if (type == 'TextApplet') {
      createNewTextBox(newAppKey, context);
    }
    print('id inside provier $id');*/
    print('created it $id');
    return id;
  }
}
