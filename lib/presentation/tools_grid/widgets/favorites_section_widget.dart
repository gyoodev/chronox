import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './tool_card_widget.dart';

class FavoritesSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteTools;
  final Function(Map<String, dynamic>) onToolTap;
  final Function(Map<String, dynamic>) onToolLongPress;

  const FavoritesSectionWidget({
    Key? key,
    required this.favoriteTools,
    required this.onToolTap,
    required this.onToolLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favoriteTools.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: AppTheme.warningColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Favorites',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          height: 22.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: favoriteTools.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final tool = favoriteTools[index];
              return Container(
                width: 40.w,
                child: ToolCardWidget(
                  title: tool['title'] as String,
                  description: tool['description'] as String,
                  iconName: tool['iconName'] as String,
                  iconColor: tool['iconColor'] as Color,
                  isFavorite: true,
                  hasRecentActivity:
                      tool['hasRecentActivity'] as bool? ?? false,
                  requiresInternet: tool['requiresInternet'] as bool? ?? false,
                  onTap: () => onToolTap(tool),
                  onLongPress: () => onToolLongPress(tool),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
