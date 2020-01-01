import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import 'constants.dart';

import 'homeView.dart';
import 'data.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Synapp',
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          Constants.HOME_SCREEN: (BuildContext context) =>
              ChangeNotifierProvider<Data>(
                lazy: true,
                create: (_) => Data(),
                child: HomeView(),
              )
        },
        initialRoute: Constants.HOME_SCREEN,
      ),
    );
  }
}
