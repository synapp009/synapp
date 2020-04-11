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
        .map((doc) => Project.fromMap(doc.data, doc.documentID))
        .toList();
    return projects;
  }

  Stream<QuerySnapshot> fetchProjectsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Project> getProjectById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Project.fromMap(doc.data, doc.documentID);
  }

  Future removeProject(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateProject(Project data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future addProject(Project data) async {
    _api.addDocument(data.toJson());

    return;
  }

  /*Stream<QuerySnapshot> fetchAppletsAsStream(String projectId) {
    return _api.streamAppletCollection(projectId);
  }*/

}
