
import 'package:flutter_template/controllers/home.vm.dart';

import 'package:flutter_template/services/app_cache.dart';
import 'package:get_it/get_it.dart';
import '../controllers/base.vm.dart';
import 'navigation_service.dart';

GetIt getIt = GetIt.I;

void setupLocator() {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AppData>(() => AppData());
  

  /*getIt.registerLazySingleton<AppCache>(() => AppCache());
  */
  registerViewModel();
}

void registerViewModel() {
  getIt.registerFactory<BaseViewModel>(() => BaseViewModel());
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());


  //View Model
}
