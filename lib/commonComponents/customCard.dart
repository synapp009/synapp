import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synapp/core/models/projectModel.dart';
import 'package:synapp/core/viewmodels/CRUDModel.dart';
import 'package:synapp/homeView.dart';
import '../data.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.projectDetails});

  final Project projectDetails;

  @override
  Widget build(BuildContext context) {
    //dataProvider.structureMap = projectDetails.appletMap;

    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            Text(projectDetails.name),
            FlatButton(
                child: Text("See More"),
                onPressed: () {
                  
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
                      builder: (context) => ListenableProvider(
                        lazy: true,
                        create: (_) => Data(),
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
