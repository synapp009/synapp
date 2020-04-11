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

    // var projectProvider = Provider.of<Project>(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(children: <Widget>[
          Text(projectDetails.name),
          FlatButton(
              child: Text("See More"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StreamProvider<Map<String, Applet>>(
                      create: (context) =>
                          projectDetails.fetchAppletsChangesAsStream(),
                      child: ChangeNotifierProxyProvider<Map<String, Applet>,
                          Project>(
                        create: (context) => projectDetails,
                        update: (context, appletMap, projectDetail) =>
                            projectDetails.update(appletMap),
                        child: Builder(builder: (context) {
                          var snapshot =
                              Provider.of<Map<String, Applet>>(context);
                          projectDetails.displaySize =
                              MediaQuery.of(context).size;
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
              }),
        ]),
      ),
    );
  }
}

/*ListenableProvider.value(
                      value: projectDetails,
                      child: StreamBuilder<Map<String, Applet>>(
                          stream: projectDetails.fetchAppletsAsStream(),

                          //Firestore.instance.collection("projects").snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<Map<String, Applet>> snapshot2) {
                            if (snapshot2.hasError)
                              return new Text('Error: ${snapshot2.error}');
                            switch (snapshot2.connectionState) {
                              case ConnectionState.waiting:
                                return new SpinKitDoubleBounce(
                                  color: Color(0xff875AFF),
                                  size: 50.0,
                                );
                              default:
                                if (snapshot2.hasData) {
                                  if (projectDetails.appletMap == null) {
                                    projectDetails.appletMap = {};
                                  }
                                  projectDetails.update(snapshot2.data);

                                 
                                }
                                return HomeView(project: projectDetails);
                            }
                          }),
                    ),
                  ),
                );

                /* StreamProvider<List<Applet>>.value(
                        value: crudProvider
                            .fetchAppletsAsStream(projectDetails.projectId),
                        child: HomeView(project: projectDetails),
                      ),*/
              }),
        ]),
      ),
    );
  }
}*/
