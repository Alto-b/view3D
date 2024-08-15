import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Flutter3DController controller = Flutter3DController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'view', // First part of the text
            style: GoogleFonts.orbitron(
              color: Colors.grey,
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
                      color: Colors
                          .white, // Set this to white for the gradient to show
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
                showAppInfoDialog(context);
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    child: Flutter3DViewer(
                      key: ValueKey(
                          selectedIndex), // Assign a unique key based on the selected index
                      src: images[
                          selectedIndex], // Use selectedIndex to update the src
                      controller: controller,
                      progressBarColor: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //previous model
                              IconButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  setState(() {
                                    selectedIndex =
                                        (selectedIndex - 1 + images.length) %
                                            images.length;
                                    controller =
                                        Flutter3DController(); // Reset the controller
                                    isPlaying = false;
                                  });
                                },
                                icon: const Icon(Icons.arrow_back_ios),
                              ),
                              // Reset camera
                              IconButton(
                                onPressed: () {
                                  controller.resetCameraOrbit();
                                },
                                icon: const Icon(Icons.restore),
                              ),
                              // play/pause button
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
                                  isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                              //next model
                              IconButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  setState(() {
                                    selectedIndex =
                                        (selectedIndex + 1) % images.length;
                                    controller =
                                        Flutter3DController(); // Reset the controller
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
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

void showAppInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('About view3D'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 10),
            Text(
                'view3D is an app for viewing and interacting with 3D models.'),
            SizedBox(height: 10),
            Text('Features:'),
            SizedBox(height: 5),
            Text('- Load 3D models in various formats.'),
            Text('- Control animations and camera.'),
            Text('- View models from different angles.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
