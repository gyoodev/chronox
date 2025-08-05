import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ToolCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final Color iconColor;
  final bool isFavorite;
  final bool hasRecentActivity;
  final bool requiresInternet;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ToolCardWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.iconColor,
    this.isFavorite = false,
    this.hasRecentActivity = false,
    this.requiresInternet = false,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: BoxConstraints(minHeight: 20.h, maxHeight: 25.h),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon and badges row
                Stack(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: iconName,
                          color: iconColor,
                          size: 6.w,
                        ),
                      ),
                    ),
                    // Favorite badge
                    if (isFavorite)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'star',
                              color: Colors.white,
                              size: 2.5.w,
                            ),
                          ),
                        ),
                      ),
                    // Recent activity badge
                    if (hasRecentActivity && !isFavorite)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'access_time',
                              color: Colors.white,
                              size: 2.5.w,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                // Description
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Internet requirement indicator
                if (requiresInternet)
                  Container(
                    margin: EdgeInsets.only(top: 1.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'wifi',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Online',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontSize: 8.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
