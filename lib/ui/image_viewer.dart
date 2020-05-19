import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String path;
  final String fileName;

  ImageViewer(this.path, this.fileName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Container(child: Image.file(File(path))),
    );
  }
}
