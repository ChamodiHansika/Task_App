import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:task_app/home.dart';

void main() => runApp(
    DevicePreview(
        builder: (context)=> MyApp())
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
