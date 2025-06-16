import 'dart:io';

import 'package:apk_analyzer/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apk_analyzer/widgets/description_widget.dart';

class ApkInfoPage extends StatefulWidget {
  const ApkInfoPage({super.key});

  @override
  State<ApkInfoPage> createState() => _ApkInfoPageState();
}

class _ApkInfoPageState extends State<ApkInfoPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //从MyAppState中获取成员
    Map<String,String> basicInfo = appState.apkParser!.getBasicInfo();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 描述列表和图标
              Image.file(File(basicInfo['iconPath']!), width: 64, height: 64),
              _buildDescriptionSection(basicInfo),
          ],
        ),
      ),
    );
  }

  // 构建描述区域
  Widget _buildDescriptionSection(Map<String, String> basicInfo) {
    List<DescriptionItem2> descriptionItems = [
      DescriptionItem2(
        '包名',
        basicInfo['packageName']!,
        Icon(Icons.shape_line),
      ),
      DescriptionItem2('应用名', basicInfo['appName']!,Icon(Icons.mobile_friendly),),
      DescriptionItem2(
        '文件大小',
        '${basicInfo['apkSize']!}字节',
        Icon(Icons.more_vert),
      ),
      DescriptionItem2(
        '程序入口',
        basicInfo['launcherActivity']!,
        Icon(Icons.verified_outlined),
      ),
      DescriptionItem2(
        '版本代码',
        basicInfo['versionCode']!,
        Icon(Icons.code),
      ),
      DescriptionItem2(
        '版本号',
        basicInfo['versionName']!,
        Icon(Icons.code),
      ),
      DescriptionItem2(
        '加固信息',
        basicInfo['packedInfo']!,
        Icon(Icons.indeterminate_check_box)),
      DescriptionItem2(
        '框架信息',
        basicInfo['builtInfo']!,
        Icon(Icons.add_box)),
      DescriptionItem2(
        '最小SDK',
        basicInfo['minSdkVersion']!,
        Icon(Icons.code),
      ),
      DescriptionItem2(
        '最适合SDK',
        basicInfo['targetSdkVersion']!,
        Icon(Icons.code),
      ),
      DescriptionItem2(
        '编译SDK',
        basicInfo['compileSdkVersion']!,
        Icon(Icons.code),
      ),
    ];
    return Expanded(
      child: SingleChildScrollView(
        child: DescriptionList(
            items: descriptionItems.toList(),
            itemSpacing: 10,
          ),
      ),
    );
  }
}