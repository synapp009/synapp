import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    print(ref.getDocuments());
    return ref.getDocuments();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.document(id).get();
  }

  Future<List<DocumentSnapshot>> getAppletById(String projectId) async {
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

  Future<void> addDocument(Map data) async {
    Map<String, dynamic> tempAppletList = data['appletList'];
    data.remove('appletList');
    var doc = await ref.add(data);
    var id = doc.documentID;
    var tempData = data;
    tempData["id"] = id;
    ref.document(id).updateData(tempData);
    tempAppletList.forEach((key, value) {
      ref.document(id).collection('applets').document(key).setData(value);
    });

    //.then((result) => addAppletMap(data, result.documentID));
  }

  Future<void> updateDocument(Map data, String id) {
    print('id from future $id');
    Map<String, dynamic> tempAppletList = data['appletList'];
    data.remove('appletList');
    var tempData = data;
    ref.document(id).updateData(tempData);
    tempAppletList.forEach((key, value) {
      ref.document(id).collection('applets').document(key).setData(value);
    });
    return ref.document(id).updateData(data);
  }

  Future<void> updateApplet(String projectId, Map data, String appletId) async {
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

  Stream<QuerySnapshot> streamAppletCollection(String projectId) {
    return ref.document(projectId).collection("applets").snapshots();

    /*return ref.document(projectId).collection("applets").snapshots().map((list)=>
    list.documents.map((doc) => Applet.fromMap(doc.data)).toList());*/
  }
}
