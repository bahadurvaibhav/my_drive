/*
  Copyright (c) 2020 Razeware LLC

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
      copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom
  the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  Notwithstanding the foregoing, you may not use, copy, modify,
      merge, publish, distribute, sublicense, create a derivative work,
  and/or sell copies of the Software in any work that is designed,
  intended, or marketed for pedagogical or instructional purposes
  related to programming, coding, application development, or
  information technology. Permission for such use, copying,
      modification, merger, publication, distribution, sublicensing,
      creation of derivative works, or sale is expressly withheld.

  This project and source code may use libraries or frameworks
  that are released under various Open-Source licenses. Use of
  those libraries and frameworks are governed by their own
  individual licenses.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.
*/

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

typedef FileUploadedCallback = void Function(String fileName);
typedef FileErrorCallback = void Function(String error);

class UploadWidget extends StatefulWidget {
  final String hostUrl;
  final FileUploadedCallback fileUploadedCallback;
  final FileErrorCallback fileUploadErrorCallback;

  UploadWidget({
    @required this.hostUrl,
    @required this.fileUploadedCallback,
    @required this.fileUploadErrorCallback,
  });

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  bool uploadInProgress = false;
  int sent = 0;
  int total = 0;
  CancelToken token;
  List<String> acceptedExtensions = ["pdf", "jpg", "png", "jpeg"];
  static const int MAXIMUM_FILE_SIZE = 10;
  double percentageCompleted = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        showUploadProgress(),
        RaisedButton(
          onPressed: uploadInProgress ? null : uploadButtonPressed,
          child: Text(
            'Upload File',
            style: TextStyle(color: Colors.white70),
          ),
          color: Colors.red,
        ),
        FlatButton(
          onPressed: uploadInProgress ? cancelUpload : null,
          child: Row(
            children: <Widget>[
              Icon(Icons.cancel),
              Text('Cancel Upload'),
            ],
          ),
        ),
      ],
    );
  }

  void cancelUpload() {
    token.cancel("Upload cancel");
    setState(() {
      uploadInProgress = false;
    });
  }

  Widget showUploadProgress() {
    if (total != 0) {
      percentageCompleted = sent / total * 100;
    }
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 5.0,
      percent: percentageCompleted / 100,
      center: new Text(percentageCompleted.round().toString() + "%"),
      progressColor: Colors.green,
    );
  }

  void uploadButtonPressed() async {
    widget.fileUploadErrorCallback("");
    widget.fileUploadedCallback("");
    setState(() {
      percentageCompleted = 0;
      uploadInProgress = true;
    });
    File file = await FilePicker.getFile();
    await uploadFile(file);
    setState(() {
      uploadInProgress = false;
    });
  }

  Future<void> uploadFile(File file) async {
    bool fileValid = await isFileValid(file);
    if (!fileValid) {
      return;
    }
    String fileName = file.path.split('/').last;

    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    token = CancelToken();
    var urlPath = widget.hostUrl + 'uploadDocument';
    try {
      await Dio().post(
        urlPath,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: token,
      );
    } on DioError catch (e) {
      widget.fileUploadErrorCallback("File upload cancelled");
      return;
    }
    widget.fileUploadedCallback(fileName);
  }

  Future<bool> isFileValid(File file) async {
    String fileExtension = file.path.split('.').last;
    if (!acceptedExtensions.contains(fileExtension)) {
      widget.fileUploadErrorCallback(
          "Extension not supported. Only pdf, jpg, jpeg, png allowed");
      return false;
    }
    int fileSizeInBytes = await file.length();
    if (fileSizeInBytes > MAXIMUM_FILE_SIZE * 1000000) {
      widget.fileUploadErrorCallback(
          "Maximum File Size " + MAXIMUM_FILE_SIZE.toString() + "MB exceeded");
      return false;
    }
    return true;
  }

  void onSendProgress(int count, int total) {
    setState(() {
      sent = count;
      this.total = total;
    });
  }
}
