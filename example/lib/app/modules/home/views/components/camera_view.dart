import 'dart:io';
import 'package:ai_plugin_example/app/modules/home/views/components/pose_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../../../../main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.count,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.onScreenModeChanged,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;
  String count;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.gallery;
  CameraController? _controller;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  num _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  bool loading = false;

  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
    mode: PoseDetectionMode.stream,
    model: PoseDetectionModel.accurate,
  ));

  List<ImageJson> listImageJson = [];
  String filePath = "/sdcard/download";
  String fileName = "poses_json.json";
  TextEditingController labelController = TextEditingController();

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_allowPicker)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: _switchScreenMode,
                child: Icon(
                  _mode == ScreenMode.liveFeed
                      ? Icons.photo_library_outlined
                      : (Platform.isIOS
                          ? Icons.camera_alt_outlined
                          : Icons.camera),
                ),
              ),
            ),
        ],
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed) {
      body = _liveFeedBody();
    } else {
      body = _galleryBody();
    }
    return body;
  }

  Widget _imageItem(ImageJson image, int index) {
    var imageView = Image.file(File(image.file.path));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 400,
          width: 400,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              imageView,
              if (image.paint != null) image.paint!,
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            listImageJson.removeAt(index);
            setState(() {});
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }

  Widget _listImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return _imageItem(listImageJson[index], index);
              },
              itemCount: listImageJson.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              child: const Text('From Gallery'),
              onPressed: () async {
                _getImage(ImageSource.gallery);
              },
            ),
          ),
          Text("Image count: ${listImageJson.length}"),
          TextField(
            controller: labelController,
            decoration: const InputDecoration(hintText: "label"),
          ),
          TextButton(
            onPressed: () async {
              final directory = await getApplicationDocumentsDirectory();
              filePath = directory.path;
              print("canhdt filePath: $filePath");
              final File file = File("$filePath/$fileName");
              file.writeAsStringSync('[\n');
              for (int i = 0; i < listImageJson.length; i++) {
                await _processPickedFile(listImageJson[i]);
                if (i < listImageJson.length - 1) {
                  file.writeAsStringSync(',\n', mode: FileMode.append);
                }
              }
              file.writeAsStringSync(']\n', mode: FileMode.append);
            },
            child: const Text("make json file"),
          ),
        ],
      ),
    );
  }

  BuildContext? dialogContext;
  var pickedFile;

  Future _getImage(ImageSource source) async {
    //_image = null;

    _path = null;
    listImageJson = [];
    pickedFile = await _imagePicker?.pickMultiImage();

    for (var element in pickedFile!) {
      File image = File(element.path);
      img.Image? decodedImage = img.decodeImage(image.readAsBytesSync());
      final orientation = img.bakeOrientation(decodedImage!);
      await image.writeAsBytes(img.encodeJpg(orientation));

      final inputImage = InputImage.fromFilePath(element.path);
      _showMyDialog();
      final poses = await _poseDetector.processImage(inputImage);
      final name = inputImage.filePath?.split("/").last ?? "";
      ImageJson json = ImageJson();
      json.name = name;
      json.label = "temp";
      json.poses = poses;
      json.file = element;
      listImageJson.add(json);

      Size size = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );
      final painter = PosePainter(
        poses,
        size,
        InputImageRotation.rotation0deg,
      );
      json.paint = CustomPaint(painter: painter);
    }

    if (dialogContext != null) {
      Navigator.pop(dialogContext!);
      dialogContext = null;
    }
    if (_image == null) {
      setState(() {
        _image = File(pickedFile.first.path);
      });
    }
  }

  Future _processPickedFile(ImageJson image) async {
    ///write to local(final)
    image.label = labelController.text;
    final File file = File("$filePath/$fileName");
    file.writeAsStringSync(
      image.toJson(),
      mode: FileMode.append,
    );
  }

  Widget _galleryBody() {
    if (_image != null) {
      return _listImage();
    }
    return ListView(shrinkWrap: true, children: [
      const Icon(
        Icons.image,
        size: 200,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () async {
            _getImage(ImageSource.gallery);
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future<void> _showMyDialog() async {
    if (dialogContext != null) {
      Navigator.pop(dialogContext!);
      dialogContext = null;
    }
    return showDialog(
      context: context,
      builder: (context) {
        dialogContext = context;
        String mes = "${listImageJson.length}/${pickedFile.length}";
        return Center(child: Text(mes));
      },
    );
  }

  Widget _liveFeedBody() {
    if (_controller == null) {
      return const Center(
        child: Text("loading"),
      );
    }
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: _changingCameraLens
                  ? const Center(
                      child: Text('Changing camera lens'),
                    )
                  : CameraPreview(_controller!),
            ),
          ),
          Positioned(
            bottom: 200,
            left: 100,
            child: Text(
              widget.count,
              // "ccccc",
              style: const TextStyle(fontSize: 30, color: Colors.red),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  _controller!.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          )
        ],
      ),
    );
  }

  Widget? _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          onPressed: _switchLiveCamera,
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
        ));
  }

  void _switchScreenMode() {
    _image = null;
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      _startLiveFeed();
    }
    if (widget.onScreenModeChanged != null) {
      widget.onScreenModeChanged!(_mode);
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    var cameras = await availableCameras();
    final camera = cameras[_cameraIndex.toInt()];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex.toInt()];
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

    widget.onImage(inputImage);
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
          (element) => element.lensDirection == widget.initialDirection,
        ),
      );
    }

    _startLiveFeed();
  }
}

class ImageJson {
  String name = "";
  String label = "";
  late XFile file;
  List<Pose> poses = [];
  late TextEditingController nameController;
  late TextEditingController labelController;

  CustomPaint? paint;

  ImageJson() {
    nameController = TextEditingController();
    labelController = TextEditingController();
  }

  String posesToJson() {
    String json = "";
    for (var element in poses) {
      for (var item in element.landmarks.entries) {
        json +=
            "\"${item.key}\": [${item.value.x}, ${item.value.y}, ${item.value.z}],\n";
      }
    }
    if (json.length < 2) return "";
    if (json[json.length - 2] == ",") {
      json = json.substring(0, json.length - 2);
    }
    return json;
  }

  String toJson() {
    String json =
        "{\"name\": \"$name\",\n \"label\": \"$label\",\n \"landmarks\": {${posesToJson()}}\n}";
    return json;
  }
}
