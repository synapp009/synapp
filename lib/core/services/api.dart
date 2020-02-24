import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  Future<void> removeDocument(String id) {
    return ref.document(id).delete();
  }

   Future<void>  addDocument(Map data) async {
    var doc = await ref.add(data);
    var id = doc.documentID;
    var tempData = data;
    tempData["id"] = id;
    ref.document(id).updateData(tempData);
    
    //.then((result) => addAppletMap(data, result.documentID));
  }



  Future<void> updateDocument(Map data, String id) {
    return ref.document(id).updateData(data);
  }

  Future<void> updateApplet(
      String projectId, Applet applet, String appletId) async {
    var snapshots =
        ref.document(projectId).collection('appletList').where((element) => element.data.containsValue(appletId)).getDocuments();

    print(snapshots);

    /*.forEach((document) async {
      document.reference.updateData(<String, dynamic>{
         
      });
    });*/
  }
}
