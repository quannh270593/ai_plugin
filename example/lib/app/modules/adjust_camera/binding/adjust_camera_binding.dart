import 'package:ai_plugin_example/app/modules/adjust_camera/controller/adjust_camera_controller.dart';
import 'package:get/get.dart';

class AdjustCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdjustCameraController>(
      () => AdjustCameraController(),
    );
  }
}
