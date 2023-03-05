import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadImage extends StatefulWidget {
  final Function _passImage;
  final String init_image;
  UploadImage(this._passImage, {this.init_image});
  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File _imageFile;

  // This will show a dialog that the user can choose the profile picture from
  // gallery or take a picuture right away
  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(children: [
        Text(
          'Select file',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                  child: GestureDetector(
                    child: Image.asset('assets/icons/gallery.png'),
                    onTap: () {
                      Navigator.of(context).pop('g');
                    },
                  ),
                ),
                const SizedBox(height: 5),
                const Text('Gallery'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                  child: GestureDetector(
                    child: Image.asset('assets/icons/camera.jpg'),
                    onTap: () {
                      Navigator.of(context).pop('c');
                    },
                  ),
                ),
                const SizedBox(height: 5),
                const Text('Photo'),
              ],
            )
          ],
        ),
        SizedBox(
            width: double.infinity,
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')))
      ]),
    ).then(
      (value) async {
        if (value == null) {
          return;
        }
        // when user choose the source of the picture (camera, gallery)
        // will direct the user to upload the picture
        final picker = ImagePicker();
        final pickedImage = await picker.pickImage(
            source: value == 'g' ? ImageSource.gallery : ImageSource.camera,
            imageQuality: 80,
            maxWidth: 500);
        if (pickedImage != null) {
          setState(() {
            _imageFile = File(pickedImage.path);
          });
          widget._passImage(_imageFile);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.init_image == null || _imageFile != null
            ? CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile)
                    : Image.asset(
                        'assets/icons/defaulticon.png',
                      ).image,
              )
            : CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey,
                backgroundImage: widget.init_image != null
                    ? NetworkImage(widget.init_image)
                    : Image.asset(
                        'assets/icons/defaulticon.png',
                      ).image,
              ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo),
            label: const Text('Choose a picture')),
      ],
    );
  }
}
