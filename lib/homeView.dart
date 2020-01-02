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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(153, 56, 255, 1),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomAppBar(
        color:Color.fromRGBO(153, 56, 255, 1) ,
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: StackAnimator(),
    );
  }
}
