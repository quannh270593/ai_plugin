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
      //appBar: AppBar(),
      body: SafeArea(
        child: _cameraView(context),
      ),
    );
  }

  Widget _cameraView(BuildContext context) {
    return Obx(() {
      var cameraController = controller.cameraController.value;
      var fitPercent = controller.percentFit.value.toString();
      var scale = 0.0;
      Widget camera = Container();
      if (cameraController == null || cameraController.value.previewSize == null) {
        return Container();
      }

      ///this scale uses for camera view full scr
      ///replace size by widget size if not full screen
      final size = MediaQuery.of(context).size;
      scale = size.aspectRatio * cameraController.value.aspectRatio;
      if (scale < 1) scale = 1 / scale;
      camera = Transform.scale(
        scale: scale,
        child: CameraPreview(cameraController),
      );

      return SizedBox(
        //height: 500,
        child: Stack(
          children: [
            Center(child: camera),
            Center(
              child: Transform.scale(
                scale: 1 * scale * 0.7,
                child: Image.asset(
                  "assets/body_outline.png",
                  color: Colors.pink,
                ),
              ),
            ),
            Center(
              child: Text(
                fitPercent,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      );
    });
  }
}
