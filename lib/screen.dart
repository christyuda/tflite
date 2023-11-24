import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tflite/provider/image_state.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  var _recognitions;
  var v = "";

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        context.read<ImageProviderClass>().setImage(image);
        detectImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectImage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  void _showBottomSheet(BuildContext context, List<dynamic> predictions) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Detection Result:'),
              SizedBox(height: 8),
              _buildPredictionsList(predictions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredictionsList(List<dynamic> predictions) {
    return predictions != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: predictions.map((prediction) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jenis Tanaman: ${prediction['label'].toString().split(' ').sublist(1).join(' ')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Label Tanaman: Label ${prediction['index']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Index Tanaman: Index ${prediction['index']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Confidence: ${prediction['confidence']}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    var imageProvider = context.watch<ImageProviderClass>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFlite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (imageProvider.image != null)
              Image.file(
                File(imageProvider.image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(context),
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showBottomSheet(context, _recognitions);
              },
              child: Text('Show Result'),
            ),
          ],
        ),
      ),
    );
  }
}
