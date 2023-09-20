import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  PlatformFile? pickerFile;
  UploadTask? uploadTask;

  String? urlPhoto;
  List<String> listFiles = [];

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickerFile = result.files.first;
    });
  }

  Future upload() async {
    if (pickerFile == null) return;

    final path = 'files/${pickerFile!.name}';
    final file = File(pickerFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              selectImage();
            },
            icon: Icon(Icons.add_alarm),
          ),
          IconButton(
            onPressed: () {
              upload();
            },
            icon: Icon(Icons.upload),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            if (pickerFile != null)
              Expanded(
                child: Container(
                  child: Center(
                    child: Image.file(
                      File(pickerFile!.path!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            buildProgress()
          ],
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.deepPurpleAccent,
                  ),
                  Center(
                    child: Text(
                      '${(100 * progress).roundToDouble()}%',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(
              height: 50,
            );
          }
        },
      );
}
