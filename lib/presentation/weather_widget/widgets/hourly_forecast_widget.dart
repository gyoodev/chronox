import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;
  final bool isLoading;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyData,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              'Hourly Forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            height: 15.h,
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      itemCount: hourlyData.length,
                      itemBuilder: (context, index) {
                        final hour = hourlyData[index];
                        return _buildHourlyCard(context, hour, index == 0);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyCard(
    BuildContext context,
    Map<String, dynamic> hour,
    bool isFirst,
  ) {
    return Container(
      width: 18.w,
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color:
            isFirst
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isFirst
                ? Border.all(
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.3,
                  ),
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isFirst ? 'Now' : (hour['time'] ?? '12:00'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color:
                  isFirst
                      ? AppTheme.lightTheme.primaryColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color:
                  isFirst
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getWeatherIcon(hour['condition'] ?? 'partly_cloudy'),
              size: 6.w,
              color:
                  isFirst
                      ? AppTheme.lightTheme.primaryColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            "${hour['temperature'] ?? 22}°",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'water_drop',
                size: 3.w,
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(width: 1.w),
              Text(
                "${hour['precipitation'] ?? 0}%",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontSize: 8.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
      case 'overcast':
        return 'cloud';
      case 'partly_cloudy':
      case 'partly cloudy':
        return 'wb_cloudy';
      case 'rainy':
      case 'rain':
        return 'grain';
      case 'thunderstorm':
        return 'flash_on';
      case 'snow':
        return 'ac_unit';
      case 'fog':
      case 'mist':
        return 'blur_on';
      default:
        return 'wb_cloudy';
    }
  }
}
