import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://pic.cnblogs.com/avatar/2817142/20220328102437.png"),
            ),
            const SizedBox(height: 16),
            const Text(
              'Apk Analyzer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '版本: ${_getAppVersion()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'APK分析工具，支持解析基本信息、加固信息，支持一些frida功能',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('开发者信息'),
            _buildInfoItem(Icons.person, '作者', 'WXjzc'),
            _buildInfoItem(Icons.email, '邮箱', 'wxjzcroot@gmail.com'),
            _buildInfoItem(Icons.link, 'GitHub', 'https://www.github.com/wxjzcccc',
                isLink: true),
            _buildInfoItem(Icons.link, '博客', 'https://www.cnblogs.com/WXjzc',
                isLink: true),
            const SizedBox(height: 24),
            
            _buildSectionTitle('贡献者'),
            _buildInfoItem(Icons.person, 'WXjzc', 'https://www.github.com/wxjzcccc', isLink: true),
            const SizedBox(height: 24),

            _buildSectionTitle('感谢'),
            _buildInfoItem(Icons.link, 'ApkCheckPack（加固特征支持）', 'https://github.com/moyuwa/ApkCheckPack', isLink: true),
            const SizedBox(height: 24),

            _buildSectionTitle('开源许可'),
            const Text(
              '本项目基于LGPL-2.1开源协议发布\n'
              '使用Flutter框架开发',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 版权信息
            Text(
              '© ${DateTime.now().year} WXjzc',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {bool isLink = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: isLink
          ? GestureDetector(
              onTap: () => _launchURL(value),
              child: Text(
                value,
                style: const TextStyle(color: Colors.blue),
              ),
            )
          : Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _getAppVersion() {
    return '0.6.0';
  }
}