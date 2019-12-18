import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stackAnimator.dart';
import 'data.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<Data>(context).statusBarHeight =
        MediaQuery.of(context).padding.top;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Synapp'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Provider.of<Data>(context).createNewWindow();
              },
              icon: Icon(Icons.library_add),
            ),
            IconButton(
              onPressed: () {
                Provider.of<Data>(context).createNewTextfield();
              },
              icon: Icon(Icons.playlist_add),
            ),
            IconButton(
              onPressed: () {
                Provider.of<Data>(context).createNewTextfield();
              },
              icon: Icon(Icons.linear_scale),
            ),
          ],
        ),
        body:
          StackAnimator(),
        ),
      
    );
  }
}
