import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class PhotoPage extends StatefulWidget {
  final String docId;
  const PhotoPage({super.key, required this.docId});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  String? logoUrl;
  List<String> otherImageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurants_photos/${widget.docId}');

      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        final downloadUrl = await item.getDownloadURL();
        if (item.name == 'logo.jpg') {
          setState(() {
            logoUrl = downloadUrl;
          });
        } else {
          setState(() {
            otherImageUrls.add(downloadUrl);
          });
        }
      }
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<void> uploadImage(String imageType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final imageBytes = await imageFile.readAsBytes();

      img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        final compressedBytes = img.encodeJpg(image, quality: 85);

        // Zapisz skompresowany obraz do pliku
        final compressedImageFile = File(pickedFile.path)
          ..writeAsBytesSync(compressedBytes);

        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('restaurants_photos/${widget.docId}/$imageType.jpg');

          await storageRef.putFile(compressedImageFile);

          final downloadUrl = await storageRef.getDownloadURL();
          setState(() {
            if (imageType == 'logo') {
              logoUrl = downloadUrl;
            } else {
              otherImageUrls.add(downloadUrl);
            }
          });

          print('File uploaded successfully. Download URL: $downloadUrl');
        } catch (e) {
          print('Error occurred while uploading image: $e');
        }
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      setState(() {
        otherImageUrls.remove(imageUrl);
      });

      print('File deleted successfully.');
    } catch (e) {
      print('Error occurred while deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (logoUrl != null)
              Column(
                children: [
                  const Text('Logo:'),
                  Image.network(
                    logoUrl!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () => uploadImage('logo'),
              child: const Text('Change Logo'),
            ),
            if (otherImageUrls.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Liczba kolumn
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: otherImageUrls.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.network(
                          otherImageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteImage(otherImageUrls[index]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed: () =>
                  uploadImage('other_${DateTime.now().millisecondsSinceEpoch}'),
              child: const Text('Upload Other Image'),
            ),
          ],
        ),
      ),
    );
  }
}
