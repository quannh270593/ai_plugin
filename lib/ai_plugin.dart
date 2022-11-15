import 'dart:io';
import 'dart:math';

import 'package:ai_plugin/exercise_name.dart';
import 'package:ai_plugin/exercise_result.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  void Function(ExerciseResult) countCallback;
  void Function(ExerciseResult) adjustCameraCallback;

  AiPlugin({required this.countCallback, required this.adjustCameraCallback});

  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
  }

  ///poses will pushed real time from local
  void pushAdjustCameraData(
    List<Pose> poses,
    InputImageData inputImageData,
  ) {
    ExerciseResult percent = ExerciseResult(type: ResultType.percent);

    ///count here
    ///fake data
    //percent = Random().nextInt(100);

    ///x, y , x1, y1
    var imageRotation = inputImageData.imageRotation;
    var imageSize = inputImageData.size;
    var imageWidth = imageSize.width.toDouble();
    var imageHeight = imageSize.height.toDouble();
    int x = 0, y = 0, x1 = 0, y1 = 0;
    print("canhdt rotation $imageRotation");
    print("canhdt size $imageSize");
    if (Platform.isIOS) {
      y = ((imageHeight * 0.3) / 2).round();
      x = (imageWidth / 2).round();
      x = x - ((imageHeight * 0.7) / 6).round();
      x1 = x + ((imageHeight * 0.7) / 3).round();
      y1 = imageHeight.round() - y;
    } else {
      y = ((imageWidth * 0.3) / 2).round();
      x = (imageHeight / 2).round();
      x = x + ((imageWidth * 0.7) / 6).round();
      x1 = x - ((imageWidth * 0.7) / 3).round();
      y1 = imageWidth.round() - y;
    }
    print("canhdt traslated $x $y $x1 $y1");

    ///return data to local throw callback
    adjustCameraCallback.call(percent);
  }

  ///poses will pushed real time from local
  void pushPoseData(List<Pose> poses, String action) {
    ExerciseResult count = ExerciseResult(type: ResultType.count);

    ///count here
    ///fake data
    count.result = Random().nextInt(1000);

    ///return data to local throw callback
    countCallback.call(count);
  }
}
