import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/myHome.dart';
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
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(153, 56, 255, 1),
        title: Text('Synapp'),
       /* actions: <Widget>[
          IconButton(
            onPressed: () {
              dataProvider.createNewWindow();
            },
            icon: Icon(Icons.library_add),
          ),
          IconButton(
            onPressed: () {
              dataProvider.createNewTextBox();
            },
            icon: Icon(Icons.text_fields),
          ),
        ],*/
      ),
      
      body: MyHome(),
    );
  }
}
