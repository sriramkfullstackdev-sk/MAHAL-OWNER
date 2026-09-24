import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_upload_box.dart';

class PhotoGridSection extends StatelessWidget {
  final Function(int, XFile?)? onImagePicked;

  const PhotoGridSection({super.key, this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: [

        PhotoUploadBox(
          title: "Mahal\nfront Side pic",
          onImagePicked: (img) => onImagePicked?.call(0, img),
        ),

        PhotoUploadBox(
          title: "Mahal\nRoom\npic",
          onImagePicked: (img) => onImagePicked?.call(1, img),
        ),

        PhotoUploadBox(
          title: "Mahal\nStage pic",
          onImagePicked: (img) => onImagePicked?.call(2, img),
        ),

        PhotoUploadBox(
          title: "Mahal\nDining Hall pic",
          onImagePicked: (img) => onImagePicked?.call(3, img),
        ),

        PhotoUploadBox(
          title: "Mahal\nFront Hall pic",
          onImagePicked: (img) => onImagePicked?.call(4, img),
        ),

        PhotoUploadBox(
          title: "Mahal\nParking pic",
          onImagePicked: (img) => onImagePicked?.call(5, img),
        ),
      ],
    );
  }
}