import 'package:ai_plugin_example/app/modules/adjust_camera/adjust_camera_view.dart';
import 'package:ai_plugin_example/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  // runApp(GetMaterialApp(
  //       title: "Application",
  //       initialRoute: AppPages.INITIAL,
  //       getPages: AppPages.routes,
  //     ));
  runApp(MaterialApp(
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  //late CameraController controller;

  @override
  void initState() {
    super.initState();

    Permission.storage.request();
    Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeView()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text("camera"),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdjustCameraView()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text("adjust camera"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }
}
