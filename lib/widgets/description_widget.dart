import 'package:apk_analyzer/widgets/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DescriptionList extends StatelessWidget {
  final List<DescriptionItem2> items;
  final double itemSpacing;
  final CrossAxisAlignment alignment;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final bool showDivider;

  const DescriptionList({
    super.key,
    required this.items,
    this.itemSpacing = 12.0,
    this.alignment = CrossAxisAlignment.start,
    this.titleStyle,
    this.valueStyle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.textTheme.bodySmall?.color,
      fontWeight: FontWeight.w500,
    );
    final defaultValueStyle = theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        for (int i = 0; i < items.length; i++)
          Column(
            crossAxisAlignment: alignment,
            children: [
              SizedBox(height: itemSpacing),
              _DescriptionItemWidget(
                title: items[i].title,
                value: items[i].value,
                icon: items[i].icon,
                titleStyle: titleStyle ?? defaultTitleStyle,
                valueStyle: valueStyle ?? defaultValueStyle,
              ),
              if (i != items.length - 1) SizedBox(height: itemSpacing),
              if (showDivider && i != items.length - 1)
                Divider(
                  height: itemSpacing * 0.8,
                  thickness: 1,
                  color: theme.dividerColor.withOpacity(0.2),
                ),
            ],
          ),
      ],
    );
  }
}

class DescriptionItem2 {
  final String title;
  final String value;
  final Icon icon; 

  DescriptionItem2(this.title, this.value, this.icon);
}

class _DescriptionItemWidget extends StatelessWidget {
  final String title;
  final String value;
  final Icon icon;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  const _DescriptionItemWidget({
    required this.title,
    required this.value,
    required this.icon,
    this.titleStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: icon,
        ),
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: titleStyle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value已复制到剪贴板'),duration: Duration(seconds: 1)),
              );
            },
            onDoubleTap: () {
              MyDialog(context, '详情', value);
            },
            child: Text(
            value,
            style: valueStyle,
            softWrap: true,
          ),
          ),
          
        ),
      ],
    );
  }
}