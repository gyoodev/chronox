import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayHighlightsWidget extends StatelessWidget {
  final Map<String, dynamic> highlightsData;

  const TodayHighlightsWidget({Key? key, required this.highlightsData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayOfYear = highlightsData['dayOfYear'] ?? 0;
    final weekOfYear = highlightsData['weekOfYear'] ?? 0;
    final daysUntilWeekend = highlightsData['daysUntilWeekend'] ?? 0;
    final currentTime = highlightsData['currentTime'] ?? '';

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Highlights',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  icon: 'calendar_today',
                  title: 'Day of Year',
                  value: dayOfYear.toString(),
                  subtitle: 'of 365',
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildHighlightCard(
                  icon: 'date_range',
                  title: 'Week of Year',
                  value: weekOfYear.toString(),
                  subtitle: 'of 52',
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  icon: 'weekend',
                  title: 'Days to Weekend',
                  value: daysUntilWeekend.toString(),
                  subtitle: daysUntilWeekend == 1 ? 'day left' : 'days left',
                  color: AppTheme.successColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildHighlightCard(
                  icon: 'access_time',
                  title: 'Current Time',
                  value: currentTime,
                  subtitle: 'Local time',
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  size: 5.w,
                  color: color,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
