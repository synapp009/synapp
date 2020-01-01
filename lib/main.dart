import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:instabug_flutter/Instabug.dart';

import '../../../development/flutter/.pub-cache/hosted/pub.dartlang.org/instabug_flutter-9.0.1/lib/BugReporting.dart';
import '../../../development/flutter/.pub-cache/hosted/pub.dartlang.org/instabug_flutter-9.0.1/lib/FeatureRequests.dart';
import '../../../development/flutter/.pub-cache/hosted/pub.dartlang.org/instabug_flutter-9.0.1/lib/Surveys.dart';
import 'constants.dart';

import 'homeView.dart';
import 'data.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}


  class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
  }
  
  class _MyAppState extends State<MyApp> {
   String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
   Instabug.start('7c1f6e78af62d1e514faa238cf33af2a', [InvocationEvent.shake]);
    }
    initPlatformState();
  }
  
    // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

    void show() {
    Instabug.show();
  }


  void sendBugReport() {
    BugReporting.show(ReportType.bug, [InvocationOption.emailFieldOptional]);
  }

  void sendFeedback() {
    BugReporting.show(ReportType.feedback, [InvocationOption.emailFieldOptional]);
  }

  void askQuestion() {
    BugReporting.show(ReportType.question, [InvocationOption.emailFieldOptional]);
  }

  void showNpsSurvey() {
    Surveys.showSurvey('pcV_mE2ttqHxT1iqvBxL0w');
  }

  void showMultipleQuestionSurvey() {
    Surveys.showSurvey('ZAKSlVz98QdPyOx1wIt8BA');
  }

  void showFeatureRequests () {
    FeatureRequests.show();
  }

  void setInvocationEvent(InvocationEvent invocationEvent) {
    BugReporting.setInvocationEvents([invocationEvent]);
  }

  void setPrimaryColor (Color c) {
    Instabug.setPrimaryColor(c);
  }

  void setColorTheme (ColorTheme colorTheme) {
    Instabug.setColorTheme(colorTheme);
  }


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
                lazy:true,
                create: (_) => Data(),
                child: HomeView(),
              )
        },
        initialRoute: Constants.HOME_SCREEN,
      ),
    );
  }
}
