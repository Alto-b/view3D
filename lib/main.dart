import 'package:flutter/material.dart';
import 'package:view3d/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'view3D',
      theme: ThemeData(
        iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
                iconSize: MaterialStatePropertyAll(25),
                elevation: MaterialStatePropertyAll(10),
                splashFactory: InkSparkle.splashFactory,
                iconColor: MaterialStatePropertyAll(
                  Colors.black,
                ))),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
