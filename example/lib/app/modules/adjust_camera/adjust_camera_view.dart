import 'package:ai_plugin_example/app/modules/adjust_camera/controller/adjust_camera_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdjustCameraView extends GetView<AdjustCameraController> {
  const AdjustCameraView({super.key});

  @override
  Widget build(BuildContext context) {
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
      var adjusting = controller.adjusting.value;
      var customPaint = controller.customPaint.value;
      var scale = 0.0;
      Widget camera = Container();
      if (cameraController == null ||
          cameraController.value.previewSize == null) {
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
      Widget aiView = _adjustingView(scale, fitPercent);
      if (adjusting == false) {
        aiView = _countView(size.width, size.height, context);
      }
      return SizedBox(
        //height: 100,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(child: camera),
            aiView,
            Center(
              child: Container(
                  height: size.height * 0.7 * scale,
                  width: size.height * 0.7 / 3 * scale,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.red))),
            ),
            Center(
              child: Container(
                  // height: 0,
                  // width: 0,
                  // height: 896/scale,
                  // width: 299/scale,
                  width: controller.widthSendToAI.value.toDouble() / scale,
                  height: controller.heightSendToAi.value.toDouble() / scale,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blue))),
            ),
            if (customPaint != null) customPaint,
          ],
        ),
      );
    });
  }

  Widget _countView(double width, double height, BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 200,
          left: 100,
          child: Text(
            controller.count.value.toString(),
            style: const TextStyle(fontSize: 30, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _adjustingView(double scale, String fitPercent) {
    return Stack(
      children: [
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
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ],
    );
  }
}
