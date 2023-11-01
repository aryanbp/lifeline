// import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AccidentReport extends StatefulWidget {
  const AccidentReport({super.key});

  @override
  State<AccidentReport> createState() => _AccidentReportState();
}

class _AccidentReportState extends State<AccidentReport> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  int direction = 0;
  bool cameraLoading = true;

  @override
  void initState() {
      startCamera(0);
      super.initState();
  }

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraLoading = false;
      });
    }).catchError((e) {
      print('Error' + e);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return cameraLoading==false
        ? Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CameraPreview(cameraController),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          direction = direction == 0 ? 1 : 0;
                          startCamera(direction);
                        });
                      },
                      child: button(Icons.flip_camera_ios_outlined,
                          Alignment.bottomLeft)),
                  GestureDetector(
                    onTap: () {
                      cameraController.takePicture().then((XFile? file) {
                        if (mounted) {
                          if (file != null) {
                            print('Picture saved: ' + file.path);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Report Submitted",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                      });
                    },
                    child: button(
                        Icons.camera_alt_outlined, Alignment.bottomCenter),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: button(
                        Icons.arrow_back_outlined, Alignment.bottomCenter),
                  ),
                ]),
          ],
        ),
      ),
    )
        : Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }




  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 10,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black54,
        ),
      ),
    );
  }
}
