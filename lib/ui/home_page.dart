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

import 'package:flutter/material.dart';
import 'package:my_drive/ui/download_widget.dart';
import 'package:my_drive/ui/upload_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String ipAddress = "10.0.2.2:8888";
  String hostUrl = "http://" + ipAddress + "/";

  String fileUploadedName = "";
  String fileUploadErrorText = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            UploadWidget(
              hostUrl: hostUrl,
              fileUploadedCallback: fileUploaded,
              fileUploadErrorCallback: fileError,
            ),
            SizedBox(width: 20),
            DownloadWidget(
              hostUrl: hostUrl,
              fileName: fileUploadedName,
              fileDownloadErrorCallback: fileError,
            ),
          ],
        ),
        SizedBox(height: 20),
        showFileUploadedName(),
        SizedBox(height: 20),
        showFileUploadError(),
      ],
    );
  }

  void fileError(String error) {
    setState(() {
      fileUploadErrorText = error;
    });
  }

  Widget showFileUploadError() {
    if (fileUploadErrorText.isEmpty) {
      return SizedBox();
    } else {
      return Text(
        'Error: ' + fileUploadErrorText,
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
  }

  Widget showFileUploadedName() {
    if (fileUploadedName.isEmpty) {
      return SizedBox();
    } else {
      return Text('File name: ' + fileUploadedName + " uploaded successfully");
    }
  }

  void fileUploaded(String fileName) {
    setState(() {
      fileUploadedName = fileName;
    });
  }
}
