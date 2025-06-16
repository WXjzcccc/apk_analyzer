import 'package:apk_analyzer/entity/apk_info.dart';
import 'package:apk_analyzer/utils/consts.dart';
import 'package:apk_analyzer/utils/hashes.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:apk_analyzer/utils/unzip.dart';
import 'package:process_run/process_run.dart';
import 'dart:io';
import 'dart:convert';
// import 'files.dart';

class GetApkInfo {
  ApkInfo apkinfo = ApkInfo();

  GetApkInfo(String apkPath) {
    apkinfo.apkPath = apkPath;
  }

  Future<String> _runAapt2(String apkPath, int type, [String arg = '']) async {
    var shell = Shell(stdoutEncoding: utf8, verbose: false);
    var cmd = '';
    switch (type) {
      case 0:
        cmd = extractBadgingCommand;
        break;
      case 1:
        cmd = extractManifestCommand;
        break;
      case 2:
        cmd = extractResourcesCommand;
        break;
      default:
        throw Exception('Unsupported type: $type');
    }
    try {
      var command = '$aapt2Path $cmd "$apkPath" $arg';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      return result.outText;
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return '';
    }
  }
// 解包APK
  // Future<String> _unpackApk() async {
  //   String apkPath = apkinfo.apkPath ?? '';
  //   if (!await checkFileExists(apkPath)) {
  //     myLogger.e('APK文件不存在: $apkPath');
  //     return '';
  //   }
  //   var shell = Shell(stdoutEncoding: utf8, verbose: false);
  //   try {
  //     var command =
  //         '$jrePath -jar $apktoolPath $unpackApkCommand "$apkPath" -o "$tempDirPath/${apkinfo.id}"';
  //     myLogger.i('执行命令: $command');
  //     await shell.run(command);
  //     return "$tempDirPath/${apkinfo.id}";
  //   } catch (e) {
  //     myLogger.e('解包失败: $e');
  //     return "";
  //   }
  // }

  Future<String> _runAapt(String apk) async {
    var shell = Shell(stdoutEncoding: utf8, verbose: false);
    String apkPath = apkinfo.apkPath ?? '';
    try {
      var command = '$aaptPath $extractBadgingCommand "$apkPath"';
      myLogger.i('执行命令: $command');
      var result = await shell.run(command);
      return result.outText;
    } catch (e) {
      myLogger.e('执行命令失败: $e');
      return '';
    }
  }

  Future<void> _setIconPath() async {
    /*aapt对图标的解析比aapt2好，所以这边再调一次 */
    String apkPath = apkinfo.apkPath ?? '';
    String output = await _runAapt(apkPath);
    RegExp iconRegex = RegExp(r"application: label='[^']+' icon='([^']+)'");
    Match? iconMatch = iconRegex.firstMatch(output);
    if (iconMatch != null) {
      String iconPath = iconMatch.group(1) ?? '';
      if (iconPath.isNotEmpty) {
        myLogger.i('找到图标信息: $iconPath');
        String path = await extractFileWithZip(apkPath, iconPath, '$tempDirPath/${apkinfo.id}');
        if (path.isNotEmpty) {
          apkinfo.iconPath = path;
          myLogger.i('图标路径设置成功: ${apkinfo.iconPath}');
        } else {
          myLogger.w('图标提取失败，未找到图标文件');
        }
      } else {
        myLogger.w('未找到图标信息');
      }
    }
  }

  Future<void> parse() async {
    String apkPath = apkinfo.apkPath ?? '';
    apkinfo.id = await getFileSHA256(apkPath);
    String badgingResult = await _runAapt2(apkPath, 0);
    RegExp packageNameRegex = RegExp(r"package: name='([^']+)'");
    RegExp versionNameRegex = RegExp(r"versionName='([^']+)'");
    RegExp versionCodeRegex = RegExp(r"versionCode='(\d+)'");
    RegExp appNameRegex = RegExp(r"application-label-zh-CN:'([^']+)'");
    RegExp appNameRegex2 = RegExp(r"application-label:'([^']+)'");
    RegExp minSdkVersionRegex = RegExp(r"sdkVersion:'(\d+)'");
    RegExp targetSdkVersionRegex = RegExp(r"targetSdkVersion:'(\d+)'");
    RegExp compileSdkVersionRegex = RegExp(r"compileSdkVersion='(\d+)'");
    RegExp launcherActivityRegex = RegExp(
      r"launchable-activity: name='([^']+)'",
    );
    RegExp permissionsRegex = RegExp(r"uses-permission: name='([^']+)'");
    Match? packageNameMatch = packageNameRegex.firstMatch(badgingResult);
    Match? versionNameMatch = versionNameRegex.firstMatch(badgingResult);
    Match? versionCodeMatch = versionCodeRegex.firstMatch(badgingResult);
    Match? appNameMatch = appNameRegex.firstMatch(badgingResult);
    Match? appNameMatch2 = appNameRegex2.firstMatch(badgingResult);
    Match? minSdkVersionMatch = minSdkVersionRegex.firstMatch(badgingResult);
    Match? targetSdkVersionMatch = targetSdkVersionRegex.firstMatch(
      badgingResult,
    );
    Match? compileSdkVersionMatch = compileSdkVersionRegex.firstMatch(
      badgingResult,
    );
    Match? launcherActivityMatch = launcherActivityRegex.firstMatch(
      badgingResult,
    );
    Iterable<Match> permissionsMatches = permissionsRegex.allMatches(
      badgingResult,
    );
    String manifestResult = await _runAapt2(apkPath, 1);
    RegExp activitiesRegex = RegExp(
      r'E: activity .*?A: http://schemas.android.com/apk/res/android:name\S+="([^"]+)"',
      dotAll: true,
    );
    RegExp servicesRegex = RegExp(
      r'E: service .*?A: http://schemas.android.com/apk/res/android:name\S+="([^"]+)"',
      dotAll: true,
    );
    RegExp broadcastReceiversRegex = RegExp(
      r'E: receiver .*?A: http://schemas.android.com/apk/res/android:name\S+="([^"]+)"',
      dotAll: true,
    );
    RegExp providersRegex = RegExp(
      r'E: provider .*?A: http://schemas.android.com/apk/res/android:name\S+="([^"]+)"',
      dotAll: true,
    );
    RegExp metaDataRegex = RegExp(
      r'E: meta-data .*?A: http://schemas.android.com/apk/res/android:name\S+="([^"]+)".*?A: http://schemas.android.com/apk/res/android:value\S+="([^"]+)"',
      dotAll: true,
    );
    Iterable<Match> activitiesMatches = activitiesRegex.allMatches(
      manifestResult,
    );
    Iterable<Match> servicesMatches = servicesRegex.allMatches(manifestResult);
    Iterable<Match> broadcastReceiversMatches = broadcastReceiversRegex
        .allMatches(manifestResult);
    Iterable<Match> providersMatches = providersRegex.allMatches(
      manifestResult,
    );
    Iterable<Match> metaDataMatches = metaDataRegex.allMatches(manifestResult);
    apkinfo.packageName = packageNameMatch?.group(1) ?? '解析失败';
    apkinfo.versionName = versionNameMatch?.group(1) ?? '解析失败';
    apkinfo.versionCode = versionCodeMatch?.group(1) ?? '解析失败';
    apkinfo.appName = appNameMatch?.group(1) ?? appNameMatch2?.group(1) ?? '解析失败'; //拿不到中文名就用默认的
    await _setIconPath();
    apkinfo.apkSize = (await File(apkPath).length()).toString();
    apkinfo.minSdkVersion = minSdkVersionMatch?.group(1) ?? '解析失败';
    apkinfo.targetSdkVersion = targetSdkVersionMatch?.group(1) ?? '解析失败';
    apkinfo.compileSdkVersion = compileSdkVersionMatch?.group(1) ?? '解析失败';
    apkinfo.launcherActivity = launcherActivityMatch?.group(1) ?? '解析失败';
    apkinfo.packedInfo = _getPackedInfo(apkPath);
    apkinfo.permissions = permissionsMatches.map((m) => m.group(1)!).toList();
    apkinfo.activities = activitiesMatches.map((m) => m.group(1)!).toList();
    apkinfo.services = servicesMatches.map((m) => m.group(1)!).toList();
    apkinfo.metaData = {};
    for (var match in metaDataMatches) {
      String key = match.group(1) ?? '';
      String value = match.group(2) ?? '';
      if (key.isNotEmpty && value.isNotEmpty) {
        apkinfo.metaData![key] = value;
      }
    }
    apkinfo.broadcastReceivers = broadcastReceiversMatches
        .map((m) => m.group(1)!)
        .toList();
    apkinfo.providers = providersMatches.map((m) => m.group(1)!).toList();
    myLogger.i('获取APK信息成功: ${apkinfo.toJson()}');
  }

  Map<String, List<List<String>>> getPermission() {
    /*
    将权限分成一般、敏感和危险三类
     */
    Map<String, List<List<String>>> permissionMap = {
      'normal': [],
      'dangerous': [],
      'sensitive': [],
    };
    List<String> permissions = apkinfo.permissions ?? [];
    for (String permission in permissions) {
      if (dangerPermissions.contains(permission)) {
        permissionMap['dangerous']?.add([
          permission,
          permissionDescriptions[permission]?['name'] ?? '未知权限',
          permissionDescriptions[permission]?['description'] ?? '未知权限',
        ]);
      } else if (sensitivePermissions.contains(permission)) {
        permissionMap['sensitive']?.add([
          permission,
          permissionDescriptions[permission]?['name'] ?? '未知权限',
          permissionDescriptions[permission]?['description'] ?? '未知权限',
        ]);
      } else {
        permissionMap['normal']?.add([
          permission,
          permissionDescriptions[permission]?['name'] ?? '未知权限',
          permissionDescriptions[permission]?['description'] ?? '未知权限',
        ]);
      }
    }
    return permissionMap;
  }

  Map<String, List<String>> getActRecEXt() {
    /*
     * 获取Activity、Service、BroadcastReceiver、Provider
     */
    Map<String, List<String>> actRecExtMap = {
      'activities': apkinfo.activities ?? [],
      'services': apkinfo.services ?? [],
      'broadcastReceivers': apkinfo.broadcastReceivers ?? [],
      'providers': apkinfo.providers ?? [],
    };
    return actRecExtMap;
  }

  Map<String, String> getBasicInfo() {
    /*
     * 获取包名等基本信息
     */
    Map<String, String> basicInfo = {
      'packageName': apkinfo.packageName!,
      'appName': apkinfo.appName!,
      'versionCode': apkinfo.versionCode!,
      'versionName': apkinfo.versionName!,
      'apkSize': apkinfo.apkSize!,
      'packedInfo': apkinfo.packedInfo!,
      'minSdkVersion': apkinfo.minSdkVersion!,
      'targetSdkVersion': apkinfo.targetSdkVersion!,
      'compileSdkVersion': apkinfo.compileSdkVersion!,
      'launcherActivity': apkinfo.launcherActivity!,
      'iconPath': apkinfo.iconPath!,
    };
    return basicInfo;
  }

  Map<String,String> getMetaData(){
    /*获取metadata数据*/
    return apkinfo.metaData!;
  }

  String getApkPath(){
    return apkinfo.apkPath ?? '';
  } 

  String _getPackedInfo(String apkPath){
    List<String> fileList = getFileList(apkPath);
    String packed = "未加固或未知加固";
    bool flag = false;
    for(String filePath in fileList){
      String fileName = filePath;
      if(filePath.contains("/")){
        fileName = filePath.split("/").last;
      }
      packedInfo.forEach((key,value){
        if(flag){
          return;
        }
        value.forEach((name,fileList){
          if(flag){
            return;
          }
          if(fileList.contains(filePath)||fileList.contains(fileName)){ //不考虑正则匹配，其余特征以及足够了
            flag = true;
            packed = key;
          }
        });
      });

    }
    return packed;
  }

}
