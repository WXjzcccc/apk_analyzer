import 'package:apk_analyzer/main.dart';
import 'package:apk_analyzer/utils/get_apk_info.dart';
import 'package:apk_analyzer/utils/my_logger.dart';
import 'package:apk_analyzer/widgets/dialog_widget.dart';
import 'package:apk_analyzer/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apk_analyzer/utils/table.dart';

class ApkTablePage extends StatefulWidget {
  const ApkTablePage({super.key});

  @override
  State<ApkTablePage> createState() => _ApkTablePageState();
}

class _ApkTablePageState extends State<ApkTablePage> {
  // 当前选中的表格数据索引
  int _currentTableIndex = 0;
  String searchText = "";

  MyTableData setPermission(GetApkInfo apkParser){
    Map<String,List<List<String>>> permissions =apkParser.getPermission();
    List<MyTableRow> permissionRows = [];
    var cnt = 1;
    permissions.forEach((key,value) {
      var color = Colors.brown[50];
      switch(key) {
        case 'dangerous':
          color = Colors.red;
          break;
        case 'sensitive':
          color = Colors.orange;
          break;
        case 'normal':
          color = Colors.green;
          break;
        default:
          color = Colors.brown[50];
      }
      for(List<String> column in value){
        List<String> c = [cnt.toString()];
        c.addAll(column);
        permissionRows.add(MyTableRow(cells: c,color: color));
        cnt += 1;
      }
    });
    MyTableData permissionT = MyTableData(title: '权限列表', headers: ['序号','权限','名称','描述'], rows: permissionRows);
    return permissionT;
  }


  List<MyTableData> setActRec(GetApkInfo apkParser){
    List<MyTableData> t = [];
    Map<String,List<String>> acts = apkParser.getActRecEXt();
    acts.forEach((key,value){
      var title = '';
      var cnt = 1;
      List<MyTableRow> rows = [];
      switch(key){
        case 'activities':
          title = '界面';
          break;
        case 'services':
          title = '服务';
          break;
        case 'broadcastReceivers':
          title = '广播接收器';
          break;
        case 'providers':
          title = '生产者';
          break;
        default:
          title = 'err';
      }
      for(String k in value){
        List<String> c = [cnt.toString()];
        c.add(k);
        var color = const Color.fromARGB(255, 245, 177, 152);
        if(cnt % 2 == 0){
          color = const Color.fromARGB(255, 73, 130, 194);
        }
        rows.add(MyTableRow(cells: c,color: color));
        cnt += 1;
      }
      t.add(MyTableData(title: title, headers: ['序号','类名'], rows: rows));
    });
    return t;
  }

  MyTableData setMetaData(GetApkInfo apkParser){
    List<MyTableRow> rows = [];
    Map<String,String> metaData = apkParser.getMetaData();
    var cnt = 1;
    metaData.forEach((key,value){
      List<String> c = [cnt.toString(),key,value];
      var color = const Color.fromARGB(255, 245, 177, 152);
      if(cnt % 2 == 0){
        color = const Color.fromARGB(255, 73, 130, 194);
      }
      rows.add(MyTableRow(cells: c,color: color));
      cnt += 1;
    });
    return MyTableData(title: 'Meta-Data', headers: ['序号','字段名','字段值'], rows: rows);
  }

  List<MyTableData> initTable(GetApkInfo apkParser){
    List<MyTableData> t = [];
    t.add(setPermission(apkParser));
    t.add(setMetaData(apkParser));
    t.addAll(setActRec(apkParser));
    return t;
  }

  List<MyTableRow> getTableData(List<MyTableRow> rows, String searchText) {
    if (searchText.isEmpty) {
      return rows; // 如果搜索文本为空，返回所有行
    }
    return rows.where((row) {
      // 检查行中的每个单元格是否包含搜索文本
      return row.cells.any((cell) => cell.toLowerCase().contains(searchText.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //从MyAppState中获取成员
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: _buildTableSection(appState.apkParser!),
            ),
          ],
        ),
      ),
    );
  }
  // 构建表格区域
  Widget _buildTableSection(GetApkInfo apkParser) {
    try{
    List<MyTableData> tableDataList = initTable(apkParser);
    return Column(
      children: [
        // 表格切换标签
        Row(
          children: tableDataList.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentTableIndex == index
                        ? Colors.blue
                        : Colors.grey[300],
                    foregroundColor: _currentTableIndex == index
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentTableIndex = index;
                    });
                  },
                  child: Text(data.title),
                ),
              ),
            );
          }).toList(),
        ),
        // const SizedBox(height: 8),
        // 自定义表格
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: MyDataTable(
              headers: tableDataList[_currentTableIndex].headers,
              rows: getTableData(tableDataList[_currentTableIndex].rows,searchText),
            ),
          ),
        ),
        TextField(
            decoration: InputDecoration(
              labelText: '搜索',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          )
      ],
    );
    }catch(e){
      myLogger.e('解析遇到问题：$e');
      MyDialog(context, '错误', '解析遇到问题：$e');
    }
    return Column();
  }
}
