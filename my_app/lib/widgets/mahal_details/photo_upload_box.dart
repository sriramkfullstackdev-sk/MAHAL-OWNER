import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadBox extends StatefulWidget {
  final String title;
  final Function(XFile?)? onImagePicked;

  const PhotoUploadBox({super.key, required this.title, this.onImagePicked});

  @override
  State<PhotoUploadBox> createState() => _PhotoUploadBoxState();
}

class _PhotoUploadBoxState extends State<PhotoUploadBox> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      if (widget.onImagePicked != null) {
        widget.onImagePicked!(image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade300,
          image: _pickedImage != null
              ? DecorationImage(
                  image: FileImage(File(_pickedImage!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _pickedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, size: 28),
                  const SizedBox(height: 5),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
      ),
    );
  }
}
