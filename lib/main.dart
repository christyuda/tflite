import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite/provider/image_state.dart';
import 'package:tflite/screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImageProviderClass(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(),
    );
  }
}
