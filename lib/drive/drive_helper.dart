import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:googleapis/drive/v3.dart' as GoogleApis;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class DriveHelper {

  static const FOLDER_MIME = 'application/vnd.google-apps.folder';
  static const TEXT_MIME = 'text/plain';
  static const ROOT_APP_FOLDER = 'appDataFolder';

  GoogleApis.DriveApi _drive;

  DriveHelper(Map<String, String> authHeader){
    _drive = GoogleApis.DriveApi(_GoogleHttpClient(authHeader));
  }

  Future<String> createFolder(String folderName, {String folderId}) async {
    var existingFolder = await searchFile(folderName, mime: FOLDER_MIME);
    if (existingFolder != null) {
      return existingFolder.id;
    }

    GoogleApis.File file = GoogleApis.File();
    file.name =  folderName;
    file.parents = [folderId == null ? ROOT_APP_FOLDER : folderId];
    file.mimeType = FOLDER_MIME;
    var response = await _drive.files.create(file);
    return response?.id;
  }

  Future<String> uploadStringAsFile(String fileName, String folderId, String content) async {
    var existingFile = await searchFile(fileName, mime: TEXT_MIME, folderId: folderId);

    if (existingFile?.id != null) {
      await _drive.files.delete(existingFile.id);
    }

    var byteArray = utf8.encode(content);
    var media = GoogleApis.Media(Stream.value(byteArray), byteArray.length, contentType: TEXT_MIME);

    GoogleApis.File file = GoogleApis.File();
    file.name =  fileName;
    file.parents = [folderId];

    var response = await _drive.files.create(file, uploadMedia: media);
    return response?.id;
  }

  Future<GoogleApis.File> searchFile(String fileName, {String mime, String folderId}) async {
    var query = StringBuffer();
    query.write('name = \'$fileName\'');
    if (mime != null) {
      query.write(' and ');
      query.write('mimeType = \'$mime\'');
    }
    if (folderId != null) {
      query.write(' and ');
      query.write(' \'$folderId\' in parents');
    }

    var fileList = await _drive.files.list(spaces: ROOT_APP_FOLDER, q: query.toString());
    return fileList.files?.isEmpty == true ? null : fileList.files.first;
  }

  downloadFileAsString(String fileId, ValueChanged<String> onDownload) async {
    GoogleApis.Media file = await _drive.files
        .get(fileId, downloadOptions: GoogleApis.DownloadOptions.FullMedia);
    var data = List<int>();
    file.stream.listen((d){
      data.addAll(d);
    }, onDone: (){
      onDownload(Utf8Decoder().convert(data));
    });
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