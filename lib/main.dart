import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/locator.dart';
import 'package:synapp/ui/router.dart';

import 'core/viewmodels/CRUDModel.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //ChangeNotifierProvider<Data>(create:(_) => Data() ),
        //ChangeNotifierProvider<Project>(create:(_) => Project()),
        ChangeNotifierProvider(
          create: (_) => locator<CRUDModel>(),
        
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Synapp',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          onGenerateRoute: Router.generateRoute),
    );
  }
}
