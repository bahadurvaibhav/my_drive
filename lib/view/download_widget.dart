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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_drive/gateway/client.dart';
import 'package:my_drive/view/image_viewer.dart';
import 'package:my_drive/view/pdf_viewer.dart';
import 'package:my_drive/view/upload_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadWidget extends StatefulWidget {
  final String fileName;
  final FileErrorCallback fileDownloadErrorCallback;

  DownloadWidget({
    @required this.fileName,
    @required this.fileDownloadErrorCallback,
  });

  @override
  _DownloadWidgetState createState() => _DownloadWidgetState();
}

class _DownloadWidgetState extends State<DownloadWidget> {
  bool downloadInProgress = false;
  int received = 0;
  int total = 0;
  CancelToken token;
  double percentageCompleted = 0;

  @override
  Widget build(BuildContext context) {
    bool disableButton = downloadInProgress || widget.fileName.isEmpty;
    return Column(
      children: <Widget>[
        showDownloadProgress(),
        RaisedButton(
          onPressed: disableButton ? null : downloadButtonPressed,
          child: Text(
            'Download File',
            style: TextStyle(color: Colors.white70),
          ),
          color: Colors.red,
        ),
        FlatButton(
          onPressed: downloadInProgress ? cancelDownload : null,
          child: Row(
            children: <Widget>[
              Icon(Icons.cancel),
              Text('Cancel Download'),
            ],
          ),
        ),
      ],
    );
  }

  void cancelDownload() {
    token.cancel("Download cancel");
    setState(() {
      downloadInProgress = false;
    });
  }

  Widget showDownloadProgress() {
    if (total != 0 && total != -1) {
      percentageCompleted = received / total * 100;
    }
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 5.0,
      percent: percentageCompleted / 100,
      center: new Text(percentageCompleted.round().toString() + "%"),
      progressColor: Colors.green,
    );
  }

  void downloadButtonPressed() async {
    widget.fileDownloadErrorCallback("");
    setState(() {
      percentageCompleted = 0;
      downloadInProgress = true;
    });
    token = CancelToken();
    String savedFilePath =
        await downloadFile(widget.fileName, token, onReceiveProgress);
    if (savedFilePath.isNotEmpty) {
      viewFile(savedFilePath);
    } else {
      widget.fileDownloadErrorCallback("File download cancelled");
    }
    setState(() {
      downloadInProgress = false;
    });
  }

  void onReceiveProgress(int count, int total) {
    setState(() {
      received = count;
      this.total = total;
    });
  }

  Future<void> viewFile(String savedFilePath) async {
    String fileExtension =
        widget.fileName.substring(widget.fileName.lastIndexOf(".") + 1);
    if (fileExtension.toLowerCase() == "pdf") {
      setState(() {
        percentageCompleted = 100;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPdfViewer(savedFilePath, widget.fileName),
        ),
      );
    } else {
      setState(() {
        percentageCompleted = 100;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(savedFilePath, widget.fileName),
        ),
      );
    }
  }
}
