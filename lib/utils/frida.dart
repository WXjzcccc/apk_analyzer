import 'dart:convert';
import 'dart:io';
import 'package:apk_analyzer/utils/consts.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:process_run/process_run.dart';

List<Map<String,dynamic>> getPlugins(){
  String path = easyFridaPluginPath;
  File file = File(path);
  String data = file.readAsStringSync();
  List<Map<String,dynamic>> plugins = [];
  List<String> pluginList = data.split("\n");
  int cnt = 0;
  for(String plugin in pluginList){
    List<String> temp = plugin.split(" ");
    String name = temp.first;
    String message = temp.last;
    plugins.add({
      "id":cnt,
      "title":name,
      "message":message,
      "selected":false,
    });
    cnt += 1;
  }
  return plugins;
}

Future<bool> checkInstalled(String packageName) async {
  var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbRootCommand $adbCheckInstalledCommand';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      if(result.outText.contains(packageName)){
        return true;
      }
      return false;
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return false;
    }
}

Future<bool> installApk(String apkPath) async {
  var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbInstallCommand "$apkPath"';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      if(result.outText.contains("Success")){
        return true;
      }
      return false;
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return false;
    }
}


Future<String> _checkCpu() async {
  var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbRootCommand $adbUnameCommand';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      if(result.outText.contains("x86_64")){
        return "x86_64";
      }else if(result.outText.contains("aarch64")){
        return "arm64";
      }else{
        return "";
      }
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return "";
    }
}

Future<void> uploadFridaServer() async {
  String cpu = await _checkCpu();
  if(cpu.isNotEmpty){
    var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbUploadCommand $fsPath$cpu $adbFridaServer';
      myLogger.i('执行命令: $command');
      await shell.run(command);
      await shell.run('$adbPath $adbRootCommand chmod +x $adbFridaServer');
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return;
    }
  }
}

Future<void> runFridaServer() async {
  var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbRootCommand "$adbFridaServer&"';
      myLogger.i('执行命令: $command');
      await shell.run(command);
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return;
    }
}

Future<bool> checkFridaServer() async {
  var shell = Shell(stdoutEncoding: utf8, verbose: false);
    try {
      var command = '$adbPath $adbRootCommand $adbCheckFSCommand';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      if(result.outText == '1'){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return false;
    }
}