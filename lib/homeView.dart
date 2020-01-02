import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stackAnimator.dart';
import 'data.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);

    //set stackSize & headerHeight
    Provider.of<Data>(context).statusBarHeight =
        MediaQuery.of(context).padding.top;
    if (dataProvider.stackSize == null) {
      dataProvider.stackSize = MediaQuery.of(context).size;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(100, 71, 2, 255),
        title: Text('Synapp'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              dataProvider.createNewWindow();
            },
            icon: Icon(Icons.library_add),
          ),
          IconButton(
            onPressed: () {
              dataProvider.createNewTextfield();
            },
            icon: Icon(Icons.text_fields),
          ),
        ],
      ),
      body: StackAnimator(),
    );
  }
}
