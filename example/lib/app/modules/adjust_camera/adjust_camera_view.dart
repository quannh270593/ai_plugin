import 'package:ai_plugin_example/app/modules/adjust_camera/controller/adjust_camera_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdjustCameraView extends GetView<AdjustCameraController> {
  const AdjustCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdjustCameraController());
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: _cameraView(),
      ),
    );
  }

  Widget _cameraView() {
    return Obx(() {
      var cameraController = controller.cameraController.value;
      var mainRatio = 1.0;
      //var height = controller.cameraViewHeight.value;
      var height;
      var scale = 0.0;
      Widget camera = Container();
      if (cameraController != null) {
        camera = LayoutBuilder(builder: (context, constraints) {
          mainRatio = constraints.maxHeight / constraints.maxWidth;
          scale = cameraController.value.aspectRatio / mainRatio;
          //controller.cameraViewHeight.value = height * scale;
          height = constraints.maxHeight * scale;
          return Transform.scale(
            //scale: mainRatio / cameraController.value.aspectRatio,
            scale: 1,
            child: CameraPreview(cameraController),
          );
        });
      }
      return SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(
              color: Colors.black12,
            ),
            Center(child: camera),
            Center(
              child: Transform.scale(
                scale: 1,
                child: Image.asset(
                  "assets/body_outline.png",
                  color: Colors.red,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
