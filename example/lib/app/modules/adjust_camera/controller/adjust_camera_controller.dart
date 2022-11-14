import 'package:ai_plugin/ai_plugin.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AdjustCameraController extends GetxController {
  List<CameraDescription> cameras = [];
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
    mode: PoseDetectionMode.stream,
    model: PoseDetectionModel.accurate,
  ));

  final AiPlugin aiPlugin = AiPlugin();
  bool adjusting = false;

  ///state
  var cameraController = Rxn<CameraController>();
  var cameraViewHeight = 0.0.obs;
  var cameraIndex = 1;
  var percentFit = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    cameras = await availableCameras();
    cameraController.value = CameraController(
      cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
    );
    aiPlugin.adjustCameraCallback = (percent) {
      percentFit.value = percent;
    };
    await cameraController.value?.initialize();
    cameraController.value?.startImageStream(_onAdjustCameraImage);
    cameraController.refresh();
  }

  Future<void> _onAdjustCameraImage(CameraImage image) async {
    // if (!_canProcess) {
    //   //print("canhdt !_canProcess");
    //   return;
    // }
    if (adjusting) {
      //print("canhdt !_isBusy");
      return;
    }
    adjusting = true;
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final camera = cameras[cameraIndex.toInt()];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    final poses = await _poseDetector.processImage(inputImage);
    var imageWidth = image.width.toDouble();
    var imageHeight = image.height.toDouble();

    //print("canhdt $imageWidth $imageHeight");
    int y = (imageHeight * 0.3).round();
    int x = (imageWidth / 2).round();
    x = x - ((imageHeight * 0.7) / 8).round();
    int x1 = (imageWidth / 2).round() + ((imageHeight * 0.7) / 8).round();
    int y1 = imageHeight.round() - (imageHeight * 0.3).round();
    aiPlugin.pushAdjustCameraData(poses, x, y, x1, y1);

    adjusting = false;
  }
}
