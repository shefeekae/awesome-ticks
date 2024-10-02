import 'dart:io';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ImageViewer extends StatelessWidget {
  const ImageViewer({required this.file, required this.fileName, super.key});

  final File file;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(fileName)),
        actions: [
          IconButton(
            onPressed: () {
              FileServices().shareImage(filePath: file.path);
            },
            icon: const Icon(
              Icons.share,
            ),
          ),
          IconButton(
            onPressed: () {
              FileServices().downloadImagesToGallery(
                imagePath: file.path,
                context: context,
              );
            },
            icon: const Icon(
              Icons.download,
            ),
          )
        ],
      ),
      body: Center(
        child: Hero(
          tag: fileName,
          child: Image.file(file),
        ),
      ),
    );
  }
}
