import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:archive/archive.dart';
import 'dart:io';

String extractFileWithZip(
  String apkPath,
  String resourcePath,
  String outputPath,
) {
  if (resourcePath.startsWith('/')) {
    resourcePath = resourcePath.substring(1);
  }
  try {
    var bytes = File(apkPath).readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      if (file.isFile && file.name == resourcePath) {
        var outputFile = File('$outputPath/$resourcePath');
        outputFile.createSync(recursive: true);
        outputFile.writeAsBytesSync(file.readBytes() as List<int>);
        return outputFile.path;
      }
    }
    myLogger.e('未找到指定资源: $resourcePath');
    return '';
  } catch (e) {
    myLogger.e('解压失败: $e');
    return '';
  }
}

List<String> getFileList(String apkPath) {
  try {
    var bytes = File(apkPath).readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    List<String> fileList = [];
    for (var file in archive) {
      if (file.isFile) {
        if (file.name.endsWith(".so") ||
            file.name.endsWith(".dex") ||
            file.name.endsWith(".jar") ||
            file.name.endsWith(".dat") ||
            file.name.endsWith(".bin") ||
            file.name.endsWith(".RSA") ||
            file.name.endsWith(".DSA") ||
            file.name.startsWith("assets") ||
            file.name.startsWith("lib")) {
          fileList.add(file.name);
        }
      }
    }
    return fileList;
  } catch (e) {
    myLogger.e('获取apk文件列表失败: $e');
    return [];
  }
}

Future<bool> extractFileWithXZ(String filePath,String outputFilePath) async {
  try {
    var bytes = File(filePath).readAsBytesSync();
    var archive = XZDecoder().decodeBytes(bytes);
    var outputFile = File(outputFilePath);
    await outputFile.create(recursive: true);
    await outputFile.writeAsBytes(archive as List<int>);
    myLogger.d('解压: $filePath成功');
    return true;
  } catch (e) {
    myLogger.e('解压失败: $e');
    return false;
  }
}