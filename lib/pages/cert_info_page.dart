import 'package:apk_analyzer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:provider/provider.dart';

class CertInfoPage extends StatefulWidget {
  const CertInfoPage({super.key});

  @override
  State<CertInfoPage> createState() => _CertInfoPageState();
}

class _CertInfoPageState extends State<CertInfoPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //从MyAppState中获取成员
    Map<String,dynamic> certInfo = appState.apkParser!.getCertInfo();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SingleChildScrollView(
              child: JsonView.map(
                certInfo,
                theme: JsonViewTheme(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}