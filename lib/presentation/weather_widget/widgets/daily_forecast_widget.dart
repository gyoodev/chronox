import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyForecastWidget extends StatefulWidget {
  final List<Map<String, dynamic>> dailyData;
  final bool isLoading;

  const DailyForecastWidget({
    Key? key,
    required this.dailyData,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<DailyForecastWidget> createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  int? expandedIndex;

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
              '7-Day Forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          widget.isLoading
              ? Container(
                height: 20.h,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.dailyData.length,
                itemBuilder: (context, index) {
                  final day = widget.dailyData[index];
                  final isExpanded = expandedIndex == index;
                  final isToday = index == 0;

                  return _buildDailyCard(
                    context,
                    day,
                    index,
                    isExpanded,
                    isToday,
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(
    BuildContext context,
    Map<String, dynamic> day,
    int index,
    bool isExpanded,
    bool isToday,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isToday ? 'Today' : (day['day'] ?? 'Monday'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isToday
                                ? AppTheme.lightTheme.primaryColor
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'water_drop',
                          size: 4.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "${day['precipitation'] ?? 10}%",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: _getWeatherIcon(
                          day['condition'] ?? 'partly_cloudy',
                        ),
                        size: 6.w,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "${day['high'] ?? 28}°/${day['low'] ?? 18}°",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName:
                        isExpanded
                            ? 'keyboard_arrow_up'
                            : 'keyboard_arrow_down',
                    size: 5.w,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              height: 1,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDetailItem(
                        context,
                        'Morning',
                        "${day['morning'] ?? 22}°",
                        'wb_sunny',
                      ),
                      _buildDetailItem(
                        context,
                        'Afternoon',
                        "${day['afternoon'] ?? 28}°",
                        'wb_sunny',
                      ),
                      _buildDetailItem(
                        context,
                        'Evening',
                        "${day['evening'] ?? 24}°",
                        'wb_cloudy',
                      ),
                      _buildDetailItem(
                        context,
                        'Night',
                        "${day['night'] ?? 18}°",
                        'nightlight_round',
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricItem(
                        context,
                        'humidity',
                        'Humidity',
                        "${day['humidity'] ?? 65}%",
                      ),
                      _buildMetricItem(
                        context,
                        'air',
                        'Wind',
                        "${day['windSpeed'] ?? 12} km/h",
                      ),
                      _buildMetricItem(
                        context,
                        'visibility',
                        'UV Index',
                        "${day['uvIndex'] ?? 6}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String time,
    String temp,
    String iconName,
  ) {
    return Column(
      children: [
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            size: 5.w,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          temp,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String iconName,
    String label,
    String value,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          size: 5.w,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
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
