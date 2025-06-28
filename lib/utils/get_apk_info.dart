import 'package:apk_analyzer/entity/apk_info.dart';
import 'package:apk_analyzer/utils/consts.dart';
import 'package:apk_analyzer/utils/files.dart';
import 'package:apk_analyzer/utils/hashes.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:apk_analyzer/utils/unzip.dart';
import 'package:crypto/crypto.dart';
import 'package:pkcs7/pkcs7.dart';
import 'package:process_run/process_run.dart';
import 'dart:io';
import 'dart:convert';
// import 'files.dart';

class GetApkInfo {
  ApkInfo apkinfo = ApkInfo();
  List<String> fileList = [];

  GetApkInfo(String apkPath) {
    apkinfo.apkPath = apkPath;
    apkinfo.iconPath = unFoundIconPath;
    fileList = getFileList(apkPath);
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
    if(output.isEmpty) {
      myLogger.w('aapt命令执行失败，无法获取图标信息');
      return;
    }
    RegExp iconRegex = RegExp(r"application: label='[^']+' icon='([^']+)'");
    Match? iconMatch = iconRegex.firstMatch(output);
    if (iconMatch != null) {
      String iconPath = iconMatch.group(1) ?? '';
      if (iconPath.isNotEmpty) {
        myLogger.i('找到图标信息: $iconPath');
        String path = extractFileWithZip(apkPath, iconPath, '$tempDirPath/${apkinfo.id}');
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
    apkinfo.packedInfo = _getPackedInfo();
    apkinfo.builtInfo = _getBuiltInfo();
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
      'builtInfo': apkinfo.builtInfo!,
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

  String _getPackedInfo(){
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
          if(fileList.contains(filePath)||fileList.contains(fileName)){ //不考虑正则匹配，其余特征已经足够了
            flag = true;
            packed = key;
          }
        });
      });

    }
    return packed;
  }

  String _getBuiltInfo(){
    String built = "原生或未知框架";
    bool flag = false;
    for(String filePath in fileList){
      String fileName = filePath;
      if(filePath.contains("/")){
        fileName = filePath.split("/").last;
      }
      builtInfo.forEach((key,value){
        if(flag){
          return;
        }
        value.forEach((name,fileList){
          if(flag){
            return;
          }
          if(fileList.contains(filePath)||fileList.contains(fileName)){
            flag = true;
            built = key;
          }
        });
      });
    }
    if(apkinfo.launcherActivity == 'org.golang.app.GoNativeActivity'){
      built = "Fyne（所有逻辑都在so当中）";
    }
    return built;
  }

  Map<String,dynamic> getCertInfo() {
    for(String filePath in fileList){
      if(filePath.startsWith("META-INF") && (filePath.endsWith(".RSA") || filePath.endsWith(".DSA"))){
        String certFilePath = extractFileWithZip(apkinfo.apkPath!, filePath, '$tempDirPath/${apkinfo.id}');
        if(checkFileExists(certFilePath)) {
          return readPkcs7Certificate(certFilePath);
        }else{
          myLogger.e("证书文件不存在: $certFilePath");
        }
      }
    }
    return {};
  }

  Map<String, dynamic> readPkcs7Certificate(String filePath) {
    File certFile = File(filePath);
    Map<String, dynamic> certInfo = {};
    var derData = certFile.readAsBytesSync();
    var cert = Pkcs7.fromDer(derData);
    certInfo['版本'] = cert.version;
    certInfo['内容类型'] = cert.contentType.objectIdentifierAsString;
    certInfo['证书列表'] = [];
    certInfo['签名列表'] = [];
    for (var certificate in cert.certificates) {
      Map<String, dynamic> certData = {};
      certData['版本'] = certificate.version.toString();
      certData['序列号'] = certificate.serialNumber.toString();
      certData['主题'] = certificate.subject.toList().map((e) => "${e.key.readableName}=${e.value}").join(', ');
      certData['颁发者'] = certificate.issuer.toList().map((e) => "${e.key.readableName}=${e.value}").join(', ');
      certData['序列号'] = certificate.serialNumber.toString();
      certData['有效期始'] = certificate.notBefore.toString();
      certData['有效期至'] = certificate.notAfter.toString();
      try{
        certData['指纹'] = certificate.fingerprint.toString();
      }catch(e){
        myLogger.w("获取证书指纹失败: $e");
        certData['指纹'] = "获取失败";
      }
      certData['签名算法'] = certificate.digestAlgorithmID.name;
      certData['RSA-e'] = certificate.publicKey.publicExponent.toString();
      certData['RSA-n'] = certificate.publicKey.n.toString();
      certInfo['证书列表'].add(certData);
    }
    for (var signerInfo in cert.signerInfo) {
      Map<String, dynamic> signData = {};
      signData['版本'] = signerInfo.version.toString();
      signData['序列号'] = signerInfo.serial.toString();
      signData['签名算法'] = signerInfo.digestAlgorithmID.name;
      final sha_256 = sha256.convert(cert.certificates.last.der);
      final sha_1 = sha1.convert(cert.certificates.last.der);
      final md_5 = md5.convert(cert.certificates.last.der);
      signData["MD5 签名"] = md_5.toString();
      signData["SHA1 签名"] = sha_1.toString();
      signData["SHA256 签名"] = sha_256.toString();
      certInfo['签名列表'].add(signData);
    }
    myLogger.i('读取证书信息成功: ${certInfo.toString()}');
    return certInfo;
  }

}
