import 'dart:io';

import 'package:ai_plugin/ai_plugin.dart';
import 'package:ai_plugin_example/app/modules/home/views/components/pose_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isBusy = false;

  ///state
  var adjusting = true.obs;
  var cameraController = Rxn<CameraController>();
  var cameraViewHeight = 0.0.obs;
  var cameraIndex = 1;
  var percentFit = 0.obs;
  var count = 0.obs;
  var customPaint = Rxn<CustomPaint>();

  var widthSendToAI = 0.obs;
  var heightSendToAi = 0.obs;

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
      if (percent > 90) {
        //print("canhdt end adjusting");
        adjusting.value = false;
      }
    };
    aiPlugin.countCallback = (count) {
      this.count.value = count;
    };
    await cameraController.value?.initialize();
    cameraController.value?.startImageStream(_onAdjustCameraImage);
    cameraController.refresh();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.portraitUp,
    // ]);
    print("canhdt oninit");
  }

  Future<void> _onAdjustCameraImage(CameraImage image) async {
    // if (!_canProcess) {
    //   //print("canhdt !_canProcess");
    //   return;
    // }
    if (isBusy) {
      //print("canhdt !_isBusy");
      return;
    }
    isBusy = true;
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

    ///
    var imageWidth = image.width.toDouble();
    var imageHeight = image.height.toDouble();
    // if (imageHeight < imageWidth) {
    //   var temp = imageWidth;
    //   imageWidth = imageHeight;
    //   imageHeight = temp;
    // }
    int x = 0, y = 0, x1 = 0, y1 = 0;
    print("canhdt rotation $imageRotation");
    print("canhdt size $imageSize");
    if (Platform.isIOS) {
      y = ((imageHeight * 0.3) / 2).round();
      x = (imageWidth / 2).round();
      x = x - ((imageHeight * 0.7) / 6).round();
      x1 = x + ((imageHeight * 0.7) / 3).round();
      y1 = imageHeight.round() - y;
      widthSendToAI.value = (x1 - x).abs();
      heightSendToAi.value = (y1 - y).abs();
    } else {
      y = ((imageWidth * 0.3) / 2).round();
      x = (imageHeight / 2).round();
      x = x - ((imageWidth * 0.7) / 6).round();
      x1 = x + ((imageWidth * 0.7) / 3).round();
      y1 = imageWidth.round() - y;
      widthSendToAI.value = (x1 - x).abs();
      heightSendToAi.value = (y1 - y).abs();
    }

    // print("canhdt original $x $y $x1 $y1");
    // x = translateX(x.toDouble(), imageRotation, inputImageData.size,
    //         inputImageData.size)
    //     .round();
    // y = translateX(y.toDouble(), imageRotation, inputImageData.size,
    //         inputImageData.size)
    //     .round();
    // x1 = translateX(x1.toDouble(), imageRotation, inputImageData.size,
    //         inputImageData.size)
    //     .round();
    // y1 = translateX(y1.toDouble(), imageRotation, inputImageData.size,
    //         inputImageData.size)
    //     .round();

    print("canhdt traslated $x $y $x1 $y1");
    print("canhdt ${widthSendToAI.value} ${heightSendToAi.value}");

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      var painter = PosePainter(
        poses,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      customPaint.value = CustomPaint(painter: painter);
    } else {
      customPaint.value = null;
    }

    if (adjusting.value == true) {
      aiPlugin.pushAdjustCameraData(poses, x, y, x1, y1, inputImageData);
    } else {
      aiPlugin.pushPoseData(poses, "squat");
    }
    isBusy = false;
  }

  @override
  void onClose() async {
    super.onClose();

    await cameraController.value?.stopImageStream();
    await cameraController.value?.dispose();
    print("canhdt onclose");
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
  }

  @override
  void onReady() {
    super.onReady();
    print("canhdt onReady");
  }

  double translateX(double x, InputImageRotation rotation, Size size,
      Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x *
            size.width /
            (Platform.isIOS
                ? absoluteImageSize.width
                : absoluteImageSize.height);
      case InputImageRotation.rotation270deg:
        return size.width -
            x *
                size.width /
                (Platform.isIOS
                    ? absoluteImageSize.width
                    : absoluteImageSize.height);
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double translateY(double y, InputImageRotation rotation, Size size,
      Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y *
            size.height /
            (Platform.isIOS
                ? absoluteImageSize.height
                : absoluteImageSize.width);
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }
}
