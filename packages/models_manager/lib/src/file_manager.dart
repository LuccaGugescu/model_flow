import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ModelObject {
  final String src;
  final String name;

  ModelObject({required this.src, required this.name});

  // Convert ModelObject to JSON
  Map<String, dynamic> toJson() {
    return {
      'src': src,
      'name': name,
    };
  }

  // Create ModelObject from JSON
  factory ModelObject.fromJson(Map<String, dynamic> json) {
    return ModelObject(
      src: json['src'],
      name: json['name'],
    );
  }
}

class FileManager {
  List<ModelObject> _srcList = [];
  final String _fileName = 'model_objects.json';

  // Add this method to save the list to the phone's memory
  Future<void> saveListToFile() async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    File file = File('${appDocDir.path}/$_fileName');
    List<Map<String, dynamic>> srcListMap =
        _srcList.map((obj) => obj.toJson()).toList();
    await file.writeAsString(jsonEncode(srcListMap));
  }

  Future<List<ModelObject>> deleteModelObject(String name) async {
    _srcList.removeWhere((obj) => obj.name == name);
    await saveListToFile(); // Save the updated list to file
    return _srcList;
  }

  // Add this method to load the list from the phone's memory
  Future<List<ModelObject>> loadListFromFile() async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    File file = File('${appDocDir.path}/$_fileName');
    if (await file.exists()) {
      String fileContents = await file.readAsString();
      List<dynamic> srcListMap = jsonDecode(fileContents);
      // _srcList.clear();
      for (var obj in srcListMap) {
        _srcList.add(ModelObject.fromJson(obj));
      }
    }
    return _srcList;
  }

  // Modify pick3dModel method to save the list after adding new objects
  Future<List<ModelObject>> pick3dModel(context) async {
    List<ModelObject> srcList = [];

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      for (PlatformFile platformFile in result.files) {
        if (!platformFile.name.contains(".glb")) {
          // Show error dialog if file format is not supported
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "File Import Error: Only .glb files supported.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  "Please convert to the appropriate extension for compatibility. We recommend using online tools for conversion to .glb. We're currently working on expanding compatibility.",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          return _srcList;
        }

        // Check if the file name already exists in the list
        bool alreadyImported =
            _srcList.any((obj) => obj.name == platformFile.name);
        if (alreadyImported) {
          // Show error dialog if file is already imported
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "File Import Error: File Already Imported.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  "The selected file has already been imported.",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          return _srcList;
        } else {
          // Save the file permanently and add ModelObject to the list
          File file = File(platformFile.path!);
          String src = await saveFilePermanently(file);
          srcList.add(ModelObject(src: src, name: platformFile.name));
        }
      }
    } else {
      log("User canceled the picker");
    }

    // Add new objects to the existing list and save it to file
    _srcList.addAll(srcList); // Append new objects to the existing list
    await saveListToFile();

    return _srcList;
  }

  Future<String> saveFilePermanently(File file) async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    String fileName = generateSafeFileName(file);
    String filePath = '${appDocDir.path}/$fileName';
    try {
      await file.copy(filePath);
      return convertFilePathToUrl(filePath);
    } catch (e) {
      log('Error saving file: $e');
      throw Exception('Failed to save file');
    }
  }

  String convertFilePathToUrl(String filePath) {
    // Encode only the file name part
    String fileName = Uri.encodeComponent(filePath.split('/').last);
    String encodedFileName = Uri.encodeComponent(fileName);
    // Replace the file name in the path with the encoded version
    String encodedFilePath = filePath.replaceAll(fileName, encodedFileName);
    // Convert the file path to a file URI
    Uri fileUri = Uri.file(encodedFilePath);
    // Convert the file URI to a string
    return fileUri.toString();
  }

  String generateSafeFileName(File file) {
    String originalFileName = file.path.split('/').last;
    String safeFileName = originalFileName.replaceAll(RegExp(r'[^\w.-]+'), '');
    return '${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
  }
}
