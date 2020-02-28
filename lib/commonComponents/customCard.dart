import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/constants.dart';
import 'package:synapp/core/models/appletModel.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/projectHome.dart';
import '../data.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.projectDetails});

  final Project projectDetails;

  @override
  Widget build(BuildContext context) {
    //var dataProvider = Provider.of<Data>(context);
    var crudProvider = Provider.of<CRUDModel>(context);
   // var projectProvider = Provider.of<Project>(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            Text(projectDetails.name),
            FlatButton(
                child: Text("See More"),
                onPressed: () {
                /*  var statusBarHeight = MediaQuery.of(context).padding.top;
                  projectProvider.updateProvider(
                      projectDetails, statusBarHeight);*/

                  // projectDetails.appletMap.forEach((key, value) {projectProvider.appletMap[key] = value; });
                  /* projectProvider.selectedMap = Constants.initializeSelectedMap(
                      projectProvider.appletMap);*/
                  //dataProvider.createStructureMap(projectDetails);

                  /** Push a named route to the stcak, which does not require data to be  passed */
                  // Navigator.pushNamed(context, "/task");

                  /** Create a new page and push it to stack each time the button is pressed */
                  // Navigator.push(context, MaterialPageRoute<void>(
                  //   builder: (BuildContext context) {
                  //     return Scaffold(
                  //       appBar: AppBar(title: Text('My Page')),
                  //       body: Center(
                  //         child: FlatButton(
                  //           child: Text('POP'),
                  //           onPressed: () {
                  //             Navigator.pop(context);
                  //           },
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ));

                  /** Push a new page while passing data to it */

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => Project(),
                        child: HomeView(project: projectDetails),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
