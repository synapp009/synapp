import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';

import '../constants.dart';
import 'appletModel.dart';
import 'arrowModel.dart';

class Project with ChangeNotifier {
  String id;
  String name;
  String description;
  String img;
  //Key key;
  Map<Key, Applet> appletMap;
  Map<GlobalKey, List<Arrow>> arrowMap;

  Project(
      {this.id,
      //this.key,
      this.name,
      this.img,
      this.appletMap,
      this.arrowMap,
      this.description}) {
    appletMap = Constants.initializeStructure(appletMap);
  }

  static Map<Key, Applet> getAppletMap(List<dynamic> snapshot) {
    Map<Key, Applet> tempMap = {};
    if (snapshot != null) {
      snapshot.forEach((dynamic applet) {
        Applet tempApplet = Applet.fromMap(applet);
        Key newKey = tempApplet.id == 'null' ? null : new GlobalKey();
        tempMap[newKey] = tempApplet;
      });
    }

    return tempMap;
  }

  Project.fromMap(Map snapshot, String id)
      : id = id ?? '',
        //key = Key(snapshot['key']) ?? null,
        name = snapshot['name'] ?? '',
        img = snapshot['img'] ?? '',
        description = snapshot['description'] ?? '',
        appletMap = getAppletMap(snapshot['appletList']) ?? null,
        arrowMap = snapshot['arrowMap'] ?? null;

  /*tempMap = appletMap.map((k, v) {
        String tempK = k.toString();
        dynamic tempV = v.toJson();
        Map tempMap;
        return tempMap[tempK] = tempV;
      }),*/

  toJson() {
    List<dynamic> appletList = [];

    if (appletMap != null) {
      appletMap.forEach(
        (k, Applet v) => appletList.add(v.toJson()),
      );
    } 

    /*  Map<dynamic, dynamic> map = {};

    if (appletMap != null) {
      map = appletMap.map(
        (Key k, Applet v) => MapEntry(
          v.id,
          v.toJson(),
        ),
      );
    } else {
      map = {};
      
    }*/

    return {
      "id": id,
      //"key" : key.toString(),
      "name": name,
      "img": img,
      "appletList": appletList,
      "arrowMap": arrowMap,
      "description": description
    };
  }
}
