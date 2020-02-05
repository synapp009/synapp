import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/locator.dart';
import 'package:synapp/ui/router.dart';

import 'core/viewmodels/CRUDModel.dart';
import 'data.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => locator<CRUDModel>(),
        ),
        ListenableProvider(
          create: (_) => Data(),
        )
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
