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
import 'package:path_provider/path_provider.dart';

// In Android use 10.0.2.2; In iOS use localhost
String ipAddress = "10.0.2.2";
String hostUrl = "http://" + ipAddress + ":8888" + "/";

List<String> acceptedExtensions = ["pdf", "jpg", "png", "jpeg"];
const int MAXIMUM_FILE_SIZE = 10;

Future<void> uploadFile(File file, CancelToken token, Function onSendProgress,
    Function fileUploadedCallback, Function fileUploadErrorCallback) async {
  bool fileValid = await isFileValid(file, fileUploadErrorCallback);
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

  var urlPath = hostUrl + 'uploadDocument';
  try {
    print(urlPath);
    await Dio().post(
      urlPath,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: token,
    );
  } on DioError catch (e) {
    fileUploadErrorCallback("File upload cancelled");
    return;
  }
  fileUploadedCallback(fileName);
}

Future<bool> isFileValid(File file, Function fileUploadErrorCallback) async {
  String fileExtension = file.path.split('.').last;
  if (!acceptedExtensions.contains(fileExtension)) {
    fileUploadErrorCallback(
        "Extension not supported. Only pdf, jpg, jpeg, png allowed");
    return false;
  }
  int fileSizeInBytes = await file.length();
  if (fileSizeInBytes > MAXIMUM_FILE_SIZE * 1000000) {
    fileUploadErrorCallback(
        "Maximum File Size " + MAXIMUM_FILE_SIZE.toString() + "MB exceeded");
    return false;
  }
  return true;
}

Future<String> downloadFile(
    String fileName, CancelToken token, Function onReceiveProgress) async {
  Directory tempDir = await getTemporaryDirectory();
  String saveFileToPath = tempDir.path + "/" + fileName + "'";

  String urlPath = hostUrl + "files/" + fileName;
  try {
    print(urlPath);
    await Dio().download(
      urlPath,
      saveFileToPath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: token,
    );
  } on DioError catch (e) {
    return "";
  }
  return saveFileToPath;
}
