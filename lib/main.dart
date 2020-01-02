//import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'dart:async';
// import 'dart:io';
//import 'package:testfairy/testfairy.dart';




import 'constants.dart';
import 'homeView.dart';
import 'data.dart';

void main() {
    runApp(MyApp());
   /* HttpOverrides.runWithHttpOverrides(
         () async {
           try {
             // Enables widget error logging
             FlutterError.onError =
                 (details) => TestFairy.logError(details.exception);

             // Initializes a session
             await TestFairy.begin('SDK-w3ovBM7O');

             // Runs your app
             runApp(MyApp());
           } catch (error) {

             // Logs synchronous errors
             TestFairy.logError(error);

           }
         },

         // Logs network events
         TestFairy.httpOverrides(),

         // Logs asynchronous errors
         onError: TestFairy.logError,

         // Logs console messages
         zoneSpecification: new ZoneSpecification(
           print: (self, parent, zone, message) {
             TestFairy.log(message);
           },
         )
     );*/
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
