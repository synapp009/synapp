import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:synapp/core/models/appletModel.dart';

class Api {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

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

  Future<DocumentReference> addDocument(Map data) {
    return ref.add(data);
    //.then((result) => addAppletMap(data, result.documentID));
  }

  /*Future<DocumentReference> addAppletMap(Map data, String id) {
    Applet applet = Applet(
          key: null,
          size: Size(0, 0),
          position: Offset(0, 0),
          scale: 1,
          childKeys: []
          );
    return ref.document(id).collection("appletMap").add(applet.toJson());
  }*/

  Future<void> updateDocument(Map data, String id) {
    return ref.document(id).updateData(data);
  }

  
}
