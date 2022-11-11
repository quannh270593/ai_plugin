import 'package:camera/camera.dart';
import 'package:get/get.dart';

class AdjustCameraController extends GetxController {
  List<CameraDescription> cameras = [];


  var cameraController = Rxn<CameraController>();
  var cameraViewHeight = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
    cameras = await availableCameras();
    cameraController.value = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController.value?.initialize();
    cameraController.refresh();
    print("canhdt init adj controller");
  }
}
