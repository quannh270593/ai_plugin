
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'components/camera_view.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  @override
  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (context) {
      return CameraView(
        count: controller.count.toString(),
        title: 'Pose Detector',
        customPaint: controller.customPaint,
        text: controller.text,
        onImage: (inputImage) {
          controller.processImage(inputImage);
        },
      );
    });
  }
}
