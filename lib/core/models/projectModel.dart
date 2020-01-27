import 'package:flutter/material.dart';

import '../../constants.dart';
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
    // appletMap = Constants.initializeStructure(appletMap);
  }

  static Map<Key, Applet> fromAppletMap(snapshot, id) {
    Map<Key, Applet> tempMap = {};

    if (snapshot != null) {
      snapshot.forEach((dynamic k, dynamic a) {
        Key tempKey = Key(k);
        Applet tempApplet = Applet.fromMap(a, id);
        tempMap[tempKey] = tempApplet;
      });
    }

    return tempMap;
  }

  static Map<Key, Applet> tempMap;
  Project.fromMap(Map snapshot, String id)
      : id = id ?? '',
        //key = Key(snapshot['key']) ?? null,
        name = snapshot['name'] ?? '',
        img = snapshot['img'] ?? '',
        description = snapshot['description'] ?? '',
        appletMap = fromAppletMap(snapshot['appletMap'], id) ?? null,
        arrowMap = snapshot['arrowMap'] ?? null;

  /*tempMap = appletMap.map((k, v) {
        String tempK = k.toString();
        dynamic tempV = v.toJson();
        Map tempMap;
        return tempMap[tempK] = tempV;
      }),*/

  toJson() {
    Map<dynamic, dynamic> map;

    if (appletMap != null) {
      map = appletMap.map(
        (Key k, Applet v) => MapEntry(
          k.toString() ?? null,
          v.toJson() ?? null,
        ),
      );
    } else {
      map = {};
    }

    return {
      "id": id,
      //"key" : key.toString(),
      "name": name,
      "img": img,
      "appletMap": map,

      "arrowMap": arrowMap,
      "description": description
    };
  }
}
