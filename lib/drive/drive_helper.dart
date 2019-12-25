import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as GoogleApis;
import 'package:http/io_client.dart';

class DriveHelper {

  GoogleApis.DriveApi _drive;

  DriveHelper(Map<String, String> authHeader){
    _drive = GoogleApis.DriveApi(_GoogleHttpClient(authHeader));
  }

  Future<String> createFolder(String folderName) async {
    
  }

  Future<String> uploadStringAsFile(String fileName, String content) async {
    GoogleApis.File file = GoogleApis.File();
    file.name =  fileName;
    file.parents = ['appDataFolder'];

    var existingId = await searchFile(fileName);

    var byteArray = utf8.encode(content);
    var media = GoogleApis.Media(Stream.value(byteArray), byteArray.length, contentType: 'text/plain; charset=UTF-8');

    if (existingId != null) {
      var response = await _drive.files.update(file, existingId, uploadMedia: media);
      return response?.id;
    } else {
      var response = await _drive.files.create(file, uploadMedia: media);
      return response?.id;
    }
  }

  Future<String> searchFile(String fileName) async {
    var fileList = await _drive.files.list(spaces: 'appDataFolder');
    return fileList.files.firstWhere((file) => file.name == fileName, orElse: () => null)?.id;
  }

  Future<String> downloadFileAsString(String fileId) async {
    GoogleApis.Media file = await _drive.files
        .get(fileId, downloadOptions: GoogleApis.DownloadOptions.FullMedia);
    var bytes = await file.stream.first;
    return Utf8Decoder().convert(bytes);
  }
}

class _GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  _GoogleHttpClient(this._headers) : super();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}