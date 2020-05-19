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

class UploadWidget extends StatefulWidget {
  final String hostUrl;
  final FileUploadedCallback fileUploadedCallback;

  UploadWidget({
    @required this.hostUrl,
    @required this.fileUploadedCallback,
  });

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  bool uploadInProgress = false;
  int sent = 0;
  int total = 0;
  CancelToken token;

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
    token.cancel("Cancelled Upload");
    setState(() {
      uploadInProgress = false;
    });
  }

  Widget showUploadProgress() {
    double percentageCompleted = 0;
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
    setState(() {
      uploadInProgress = true;
    });
    File file = await FilePicker.getFile();
    await uploadFile(file);
    setState(() {
      uploadInProgress = false;
    });
  }

  Future<void> uploadFile(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    token = CancelToken();
    await Dio().post(
      widget.hostUrl + 'uploadDocument.php',
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: token,
    );
    widget.fileUploadedCallback(fileName);
  }

  void onSendProgress(int count, int total) {
    setState(() {
      sent = count;
      this.total = total;
    });
  }
}
