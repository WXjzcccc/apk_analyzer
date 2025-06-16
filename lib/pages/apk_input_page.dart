import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:apk_analyzer/utils/get_apk_info.dart';
import 'package:apk_analyzer/widgets/dialog_widget.dart';
import 'package:apk_analyzer/widgets/loading_widget.dart';

class ApkInputPage extends StatefulWidget {
  const ApkInputPage({super.key});

  @override
  State<ApkInputPage> createState() => _ApkInputPageState();
}

class _ApkInputPageState extends State<ApkInputPage> {
  String _fileName = '未选择文件';
  bool _isFileSelected = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Apk Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.android, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'APK分析工具',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Text(
                    '将APK文件拖入下方区域后点击按钮，获取分析结果',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 区域3: 文件拖入区域
            DropTarget(
              onDragDone: (DropDoneDetails details) {
                setState(() {
                  myLogger.d("拖放文 件列表：${details.files}");
                if(details.files.length != 1){
                  String warnMsg = "最多拖入一个文件";
                  MyDialog(context, '警告', warnMsg);
                  myLogger.w(warnMsg);
                }else if(!details.files.first.path.toLowerCase().endsWith(".apk")){
                  String warnMsg = "必须拖入APK文件";
                  MyDialog(context, '警告', warnMsg);
                  myLogger.e(warnMsg);
                }else{
                  _fileName = details.files.first.path;
                  myLogger.d("选择文件：$_fileName");
                  _isFileSelected = true;
                }
                });

              },
              child: Container(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isFileSelected ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isFileSelected ? Colors.green : Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isFileSelected ? Icons.check_circle : Icons.cloud_upload,
                        size: 50,
                        color: _isFileSelected ? Colors.green : Colors.blue,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _isFileSelected ? '已选择文件: $_fileName' : '拖放文件到这里',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isFileSelected ? Colors.green[800] : Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                )
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  // primary: _isFileSelected ? Colors.blue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isFileSelected
                    ? () async {
                        MyLoading.showLoading(context);
                        GetApkInfo apkParser = GetApkInfo(_fileName);
                        await apkParser.parse();
                        MyLoading.hideLoading();
                        Navigator.pushNamed(context, "/Home",arguments: apkParser);
                      }
                    : null,
                child: Text(
                  '立即分析',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
