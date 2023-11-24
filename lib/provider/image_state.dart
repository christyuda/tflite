import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageProviderClass with ChangeNotifier {
  XFile? _image;

  XFile? get image => _image;

  void setImage(XFile image) {
    _image = image;
    notifyListeners();
  }
}
