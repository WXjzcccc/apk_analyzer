import 'package:apk_analyzer/main.dart';
import 'package:apk_analyzer/utils/consts.dart';
import 'package:apk_analyzer/utils/frida.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:apk_analyzer/widgets/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:process/process.dart';
import 'package:charset/charset.dart';

class FridaPage extends StatefulWidget {
  const FridaPage({super.key});

  @override
  State<FridaPage> createState() => _FridaPageState();
}

class _FridaPageState extends State<FridaPage> {
  // 左侧复选框列表数据
  final List<Map<String, dynamic>> plugins = getPlugins();

  // 右侧输入框控制器
  final TextEditingController _classNameController = TextEditingController();
  int pid = -1;
  bool _isMethod = false;
  bool _isSpawn = true;
  String appName = '';
  String packageName = '';
  String apkPath = '';

  List<String> outputContent = [];

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //从MyAppState中获取成员
    Map<String, String> basicInfo = appState.apkParser!.getBasicInfo();
    appName = basicInfo['appName']!;
    packageName = basicInfo['packageName']!;
    apkPath = appState.apkParser!.getApkPath();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '功能列表',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: plugins.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(plugins[index]['title']),
                          subtitle: Tooltip(
                            message: plugins[index]['message'],
                            child: const Text(
                              '详情',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          value: plugins[index]['selected'],
                          onChanged: (bool? value) {
                            setState(() {
                              plugins[index]['selected'] = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧输入框和按钮区域
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _classNameController,
                    decoration: const InputDecoration(
                      labelText:
                          'className参数，equals,strcmp,tracer可选，使用tracer时，前两个不应当使用',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 按钮行
                  Row(
                    children: [
                      const Text('是否函数:'),
                      Checkbox(
                        value: _isMethod,
                        onChanged: (value) {
                          setState(() {
                            _isMethod = !_isMethod;
                          });
                        },
                      ),
                      const Text('Spawn模式:'),
                      Checkbox(
                        value: _isSpawn,
                        onChanged: (value) {
                          setState(() {
                            _isSpawn = !_isSpawn;
                          });
                        },
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _startEasyFrida,
                          child: const Text('开始'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _killEasyFrida,
                          child: const Text('停止'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 富文本展示区域
                  const Text(
                    '输出内容:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText.rich(
                          TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: _buildRichTextSpans(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建富文本内容
  List<TextSpan> _buildRichTextSpans() {
    if (outputContent.isEmpty) {
      return [const TextSpan(text: '暂无内容')];
    }

    return [
      TextSpan(
        text: outputContent.map((e) => e).join(''),
        style: const TextStyle(color: Colors.blueAccent),
      ),
    ];
  }

  // 启动frida
  Future<void> _startEasyFrida() async {
    final selectedItems = plugins.where((item) => item['selected']).toList();
    if (selectedItems.isEmpty) {
      MyDialog(context, '警告', '至少选择一项功能');
      return;
    }
    final selectedPlugins = selectedItems.map((e) => e['title']).join(',');
    if (selectedPlugins.contains("tracer") &&
        (selectedPlugins.contains("equals") ||
            selectedPlugins.contains("strcmp"))) {
      MyDialog(context, '警告', 'tracer和equals、strcmp不能同时使用');
      return;
    }
    final className = _classNameController.text;

    List<String> cmd = [easyFridaExePath];
    if (_isSpawn) {
      cmd.add(easyFridaSpawnCommand);
      cmd.add(packageName);
    } else {
      cmd.add(easyFridaAttachCommand);
      cmd.add(appName);
    }
    cmd.add(easyFridaPluginCommand);
    cmd.add(selectedPlugins);
    if (className.isNotEmpty) {
      cmd.add(easyFridaClassCommand);
      cmd.add(className);
    }
    if (_isMethod) {
      cmd.add(easyFridaIsMethodCommand);
    }
    cmd.add(easyFridaLogCommand);
    cmd.add(logDirPath);
    myLogger.i("构建easyFrida命令：${cmd.map((e) => e).join(' ')}");
    bool hasFs = await checkFridaServer();
    bool installed = await checkInstalled(packageName);
    if (!installed) {
      myLogger.d("APK未安装");
      setState(() {
        outputContent.add("APK未安装\n开始安装");
      });
      if (!await installApk(apkPath)) {
        myLogger.e("安装失败");
        setState(() {
          outputContent.add("安装失败\n");
        });
        return;
      }
    }
    if (!hasFs) {
      setState(() {
          outputContent.add("上传frida-server\n");
        });
      await uploadFridaServer();
    }
    await runFridaServer();
    final process = await LocalProcessManager().start(cmd);
    pid = process.pid;
    // 实时捕获标准输出
    process.stdout.transform(gbk.decoder).listen((data) {
      setState(() {
        if (outputContent.length > 500) {
          outputContent.removeAt(0);
        }
        outputContent.add(data);
      });
    });

    // 实时捕获错误输出
    process.stderr.transform(gbk.decoder).listen((data) {
      setState(() {
        outputContent.add(data);
      });
    });
    // 等待进程结束
    final exitCode = await process.exitCode;
    setState(() {
      outputContent.add('进程结束，退出码: $exitCode');
    });
  }

  // 终止frida进程
  void _killEasyFrida() {
    LocalProcessManager().killPid(pid);
  }
}
