import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'dart:async';

import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';

class Api {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;
  DocumentReference doc;

  Api(this.path) {
    ref = _db.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.getDocuments();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.document(id).get();
  }

Future<DocumentSnapshot> getAppletById(String projectId,String appletId) async{
  return ref.document(projectId).collection('applets').document(appletId).get();
}

Stream<DocumentSnapshot> getAppletByIdAsStream(String projectId,String appletId) {
  return ref.document(projectId).collection('applets').document(appletId).snapshots();
}


  Future<List<DocumentSnapshot>> getAppletsById(String projectId) async {
    List<DocumentSnapshot> tempList;
    QuerySnapshot collectionSnapshot =
        await ref.document(projectId).collection('applets').getDocuments();

    tempList = collectionSnapshot.documents;
    return tempList;
    // return ref.document(projectId).collection('applets').document(appletId).get();
  }

  Future<void> removeDocument(String id) {
    return ref.document(id).delete();
  }


  Future<void> addDocument(Map<String, dynamic> data) async {
    //Map<String, dynamic> tempAppletList = data['appletList'];
    //data.remove('appletList');

    Map<String, dynamic> initializeApplet =
        Constants.initializeApplet().toJson();

    var doc = await ref.add(data);

    var id = doc.documentID;
    var tempData = data;
    tempData["id"] = id;
    ref.document(id).updateData(tempData);
    ref
        .document(id)
        .collection('applets')
        .document("parentApplet")
        .setData(initializeApplet);

    /*tempAppletList.forEach((key, value) {
      ref.document(id).collection('applets').document(key).setData(value);
    });*/

    //.then((result) => addAppletMap(data, result.documentID));
  }



  Future<void> updateProjectDetails(Map data, String projectId){
    ref.document(projectId).updateData(data);
  }

  Future<void> updateApplet(String projectId, Map data, String appletId) {
    return ref
        .document(projectId)
        .collection('applets')
        .document(appletId)
        .updateData(data);
  }

  Future<void> addApplet(
    String projectId,
    Map data,
  ) async {
    var doc = await ref.document(projectId).collection("applets").add(data);
    var id = doc.documentID;
    var tempData = data;
    tempData["id"] = id;
    ref
        .document(projectId)
        .collection("applets")
        .document(id)
        .updateData(tempData);

    //.then((result) => addAppletMap(data, result.documentID));
  }

  Future<void> addArrow(String projectId, String originId, Map data) {
    return ref
        .document(projectId)
        .collection("arrows")
        .document(originId)
        .updateData(data);
  }


  Stream<QuerySnapshot> streamAppletCollection(String projectId) {
    return ref.document(projectId).collection("applets").snapshots();

  }
}
