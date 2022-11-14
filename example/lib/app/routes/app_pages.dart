import 'dart:io';

import 'package:ai_plugin_example/app/modules/adjust_camera/adjust_camera_view.dart';
import 'package:ai_plugin_example/app/modules/adjust_camera/binding/adjust_camera_binding.dart';
import 'package:ai_plugin_example/app/modules/home/bindings/home_binding.dart';
import 'package:ai_plugin_example/app/modules/home/views/home_view.dart';
import 'package:ai_plugin_example/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/default_route.dart';
class RouteName {
  static const String root = "/root";
  static const String home = "/home";
  static const String camera = "/camera";
}

/// AppRouter manages routes of app
class AppRoutes {
  /// Generate Route that returns a Route<dynamic> and takes in RouteSettings
  static Route<Widget> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.root:
        return GetPageRoute(
            page: () => const MainApp(),
            settings: settings);
      case RouteName.home:
        return GetPageRoute(
            page: () => HomeView(),
            binding: HomeBinding(),
            settings: settings);
      case RouteName.camera:
        return GetPageRoute(
            page: () => const AdjustCameraView(),
            binding: AdjustCameraBinding(),
            settings: settings);
      default:
        return GetPageRoute<Widget>(
          page: () => const Scaffold(),
        );
    }
  }
}
