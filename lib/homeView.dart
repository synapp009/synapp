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
    Provider.of<Data>(context).statusBarHeight =
        MediaQuery.of(context).padding.top;
    var _tempOffset = Offset(0, 0);
    var dataProvider = Provider.of<Data>(context);
    GlobalKey _containerKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(100, 71, 2, 255),
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
              setState(() {
                RenderBox _containerBox =
                    _containerKey.currentContext.findRenderObject();
                _tempOffset = _containerBox.globalToLocal(Offset.zero);
                dataProvider.notifier.value.setEntry(0, 3, 0);
                dataProvider.notifier.value.setEntry(1, 3, 0);
              });
              Provider.of<Data>(context).createNewTextfield();
            },
            icon: Icon(Icons.playlist_add),
          ),
        ],
      ),
      body: Stack(children: [
        Container(key: _containerKey, color: Colors.green),
        Positioned(
          top: _tempOffset.dy,
          left: _tempOffset.dx,
          child: StackAnimator(),
        ),
      ]),
    );
  }
}
