import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './tool_card_widget.dart';

class ToolsGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tools;
  final Function(Map<String, dynamic>) onToolTap;
  final Function(Map<String, dynamic>) onToolLongPress;

  const ToolsGridWidget({
    Key? key,
    required this.tools,
    required this.onToolTap,
    required this.onToolLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ToolCardWidget(
          title: tool['title'] as String,
          description: tool['description'] as String,
          iconName: tool['iconName'] as String,
          iconColor: tool['iconColor'] as Color,
          isFavorite: tool['isFavorite'] as bool? ?? false,
          hasRecentActivity: tool['hasRecentActivity'] as bool? ?? false,
          requiresInternet: tool['requiresInternet'] as bool? ?? false,
          onTap: () => onToolTap(tool),
          onLongPress: () => onToolLongPress(tool),
        );
      },
    );
  }

  int _getCrossAxisCount() {
    if (100.w > 600) {
      return 4; // Tablet landscape
    } else if (100.w > 400) {
      return 3; // Tablet portrait
    } else {
      return 2; // Phone
    }
  }
}
