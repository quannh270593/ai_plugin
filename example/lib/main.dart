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
    // if(cameras.isNotEmpty){
    //   controller = CameraController(cameras[0], ResolutionPreset.max);
    // }
    //
    // controller.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {});
    // }).catchError((Object e) {
    //   if (e is CameraException) {
    //     switch (e.code) {
    //       case 'CameraAccessDenied':
    //         print('User denied camera access.');
    //         break;
    //       default:
    //         print('Handle other errors.');
    //         break;
    //     }
    //   }
    // });

    Permission.storage.request();
    Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Get.put(GetMaterialApp(
            //   title: "Application",
            //   initialRoute: AppPages.INITIAL,
            //   getPages: AppPages.routes,
            // ));
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeView()));
          },
          child: Container(
            padding: EdgeInsets.all(20),
            child: Text("camera"),
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
