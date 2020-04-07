import 'package:get_it/get_it.dart';

import './core/services/api.dart';
import './core/viewmodels/CRUDModel.dart';
import 'core/models/appletModel.dart';
import 'core/models/arrowModel.dart';
import 'core/models/projectModel.dart';

GetIt locator =  GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Api('projects'));
  locator.registerLazySingleton(() => CRUDModel()) ;
  locator.registerLazySingleton(() => Project());
  locator.registerLazySingleton(() => Applet());
  locator.registerLazySingleton(() => Arrow());
}