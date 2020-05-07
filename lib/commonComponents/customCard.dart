import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/ui/views/projectHome.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.projectDetails});

  final Project projectDetails;

  @override
  Widget build(BuildContext context) {
    //var dataProvider = Provider.of<Data>(context);

    void _openProject() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StreamProvider<Map<String, Applet>>.value(
            value: projectDetails.fetchAppletsChangesAsStream(),
            child: ChangeNotifierProxyProvider<Map<String, Applet>, Project>(
              create: (context) => projectDetails,
              update: (context, appletMap, projectDetail) =>
                  projectDetails.update(appletMap),
              child: Builder(builder: (context) {
                var snapshot = Provider.of<Map<String, Applet>>(context);
                projectDetails.displaySize = MediaQuery.of(context).size;
                if (snapshot == null) {
                  return new SpinKitDoubleBounce(
                    color: Color(0xff875AFF),
                    size: 50.0,
                  );
                } else {
                  projectDetails.statusBarHeight =
                      MediaQuery.of(context).padding.top;
                  return HomeView(project: projectDetails);
                }
              }),
            ),
          ),
        ),
      );
    }

    var crudProvider = Provider.of<CRUDModel>(context);
    return Card(
      child: Column(children: <Widget>[
        ListTile(
          title: Center(child: Text(projectDetails.name)),
          onTap: () {
            _openProject();
          },
        ),
        //FlatButton(child: Text("See More"), onPressed: () {}),
      ]),
    );
  }
}
