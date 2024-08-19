// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Flutter3DController controller = Flutter3DController();
  String? appVersion;
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool isCameraPreview = false; // Track whether the camera preview is active
  String? chosenAnimation;
  String? chosenTexture;
  List<String> images = [
    'assets/helmet.glb',
    'assets/vr_headcat_headset.glb',
    'assets/behemoth.glb',
    'assets/argun.glb',
  ];
  int selectedIndex = 0;
  bool isPlaying = false; // Track whether the animation is playing or paused

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadAppVersion();
  }

  Future<void> loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras![0],
      ResolutionPreset.ultraHigh,
      fps: 60,
    );
    await cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background based on the isCameraPreview flag
          if (isCameraPreview &&
              cameraController != null &&
              cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(
                  cameraController!), // Camera feed as the background
            )
          else
            Positioned.fill(
              child: Container(color: Colors.white), // White background
            ),

          Positioned.fill(
            child: Flutter3DViewer(
              key: ValueKey(selectedIndex),
              src: images[selectedIndex],
              controller: controller,
              progressBarColor: Colors.grey,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                  text: 'view',
                  style: GoogleFonts.orbitron(
                    color: Colors.black45,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    WidgetSpan(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          '3D',
                          style: GoogleFonts.orbitron(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (appVersion != null) {
                      showAppInfoDialog(context, appVersion ?? '--');
                    }
                  },
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: Colors.black54),
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            selectedIndex =
                                (selectedIndex - 1 + images.length) %
                                    images.length;
                            controller = Flutter3DController();
                            isPlaying = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.resetCameraOrbit();
                        },
                        icon: const Icon(Icons.restore),
                      ),
                      IconButton(
                        icon: Icon(isCameraPreview
                            ? Icons.camera_alt_outlined
                            : Icons.camera_alt),
                        onPressed: () {
                          setState(() {
                            isCameraPreview = !isCameraPreview;
                          });
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (isPlaying) {
                              controller.pauseAnimation();
                            } else {
                              controller.playAnimation();
                            }
                            isPlaying = !isPlaying;
                          });
                        },
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            selectedIndex = (selectedIndex + 1) % images.length;
                            controller = Flutter3DController();
                            isPlaying = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppInfoDialog(BuildContext context, String appVersion) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'About view3D',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Version: $appVersion",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'view3D is an app for viewing and interacting with 3D models.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '- Control animations and camera.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const Text(
                '- View models from different angles.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    const url = 'https://github.com/alto-b';
                    await launch(url);
                  },
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text(
                    "Connect with developer",
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
