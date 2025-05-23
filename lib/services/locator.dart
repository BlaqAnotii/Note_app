

import 'package:get_it/get_it.dart';
import 'package:note_taking_app/controllers/home.vm.dart';
import 'package:note_taking_app/services/app_cache.dart';
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
