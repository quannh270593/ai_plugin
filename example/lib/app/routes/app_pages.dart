import 'package:ai_plugin_example/app/modules/adjust_camera/adjust_camera_view.dart';
import 'package:ai_plugin_example/app/modules/adjust_camera/binding/adjust_camera_binding.dart';
import 'package:ai_plugin_example/main.dart';
import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
  static final mainRoutes = [
    GetPage(name: _Paths.MAIN, page: () => MainApp()),
  ];
  static final adjustRoutes = [
    GetPage(
      name: _Paths.ADJUST,
      page: () => AdjustCameraView(),
      binding: AdjustCameraBinding(),
    ),
  ];
}
