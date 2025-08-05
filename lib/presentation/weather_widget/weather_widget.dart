import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/current_conditions_widget.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/location_header_widget.dart';
import './widgets/weather_alerts_widget.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _currentLocation = "New York, NY";

  // Mock weather data
  final Map<String, dynamic> _currentWeather = {
    "temperature": 24,
    "condition": "Partly Cloudy",
    "feelsLike": 27,
    "humidity": 68,
    "windSpeed": 15,
    "pressure": 1013,
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      "time": "Now",
      "temperature": 24,
      "condition": "partly_cloudy",
      "precipitation": 10,
    },
    {
      "time": "11:00",
      "temperature": 26,
      "condition": "sunny",
      "precipitation": 5,
    },
    {
      "time": "12:00",
      "temperature": 28,
      "condition": "sunny",
      "precipitation": 0,
    },
    {
      "time": "13:00",
      "temperature": 29,
      "condition": "partly_cloudy",
      "precipitation": 15,
    },
    {
      "time": "14:00",
      "temperature": 27,
      "condition": "cloudy",
      "precipitation": 25,
    },
    {
      "time": "15:00",
      "temperature": 25,
      "condition": "rainy",
      "precipitation": 80,
    },
    {
      "time": "16:00",
      "temperature": 23,
      "condition": "rainy",
      "precipitation": 90,
    },
    {
      "time": "17:00",
      "temperature": 22,
      "condition": "thunderstorm",
      "precipitation": 95,
    },
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {
      "day": "Today",
      "condition": "partly_cloudy",
      "high": 29,
      "low": 18,
      "precipitation": 25,
      "morning": 20,
      "afternoon": 29,
      "evening": 25,
      "night": 18,
      "humidity": 68,
      "windSpeed": 15,
      "uvIndex": 7,
    },
    {
      "day": "Tomorrow",
      "condition": "rainy",
      "high": 22,
      "low": 15,
      "precipitation": 85,
      "morning": 18,
      "afternoon": 22,
      "evening": 19,
      "night": 15,
      "humidity": 82,
      "windSpeed": 22,
      "uvIndex": 3,
    },
    {
      "day": "Wednesday",
      "condition": "sunny",
      "high": 31,
      "low": 21,
      "precipitation": 5,
      "morning": 23,
      "afternoon": 31,
      "evening": 28,
      "night": 21,
      "humidity": 45,
      "windSpeed": 8,
      "uvIndex": 9,
    },
    {
      "day": "Thursday",
      "condition": "cloudy",
      "high": 26,
      "low": 19,
      "precipitation": 40,
      "morning": 21,
      "afternoon": 26,
      "evening": 24,
      "night": 19,
      "humidity": 72,
      "windSpeed": 12,
      "uvIndex": 5,
    },
    {
      "day": "Friday",
      "condition": "partly_cloudy",
      "high": 28,
      "low": 20,
      "precipitation": 20,
      "morning": 22,
      "afternoon": 28,
      "evening": 26,
      "night": 20,
      "humidity": 58,
      "windSpeed": 10,
      "uvIndex": 6,
    },
    {
      "day": "Saturday",
      "condition": "sunny",
      "high": 32,
      "low": 22,
      "precipitation": 0,
      "morning": 24,
      "afternoon": 32,
      "evening": 29,
      "night": 22,
      "humidity": 42,
      "windSpeed": 6,
      "uvIndex": 10,
    },
    {
      "day": "Sunday",
      "condition": "thunderstorm",
      "high": 25,
      "low": 17,
      "precipitation": 95,
      "morning": 19,
      "afternoon": 25,
      "evening": 21,
      "night": 17,
      "humidity": 88,
      "windSpeed": 25,
      "uvIndex": 2,
    },
  ];

  final List<Map<String, dynamic>> _weatherAlerts = [
    {
      "title": "Heavy Rain Warning",
      "severity": "moderate",
      "time": "Valid until 6:00 PM",
      "description":
          "Heavy rain expected with possible flooding in low-lying areas. Avoid unnecessary travel and stay indoors if possible. Monitor local conditions and follow safety guidelines.",
      "startTime": "2:00 PM",
      "endTime": "6:00 PM",
    },
    {
      "title": "Wind Advisory",
      "severity": "minor",
      "time": "Valid until 8:00 PM",
      "description":
          "Strong winds up to 45 mph expected. Secure loose outdoor items and use caution when driving, especially in high-profile vehicles.",
      "startTime": "4:00 PM",
      "endTime": "8:00 PM",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshWeatherData() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = true;
    });

    // Simulate API refresh
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationSearchSheet(),
    );
  }

  Widget _buildLocationSearchSheet() {
    final List<String> savedLocations = [
      "New York, NY",
      "Los Angeles, CA",
      "Chicago, IL",
      "Miami, FL",
      "Seattle, WA",
    ];

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      size: 5.w,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    size: 5.w,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: savedLocations.length,
              itemBuilder: (context, index) {
                final location = savedLocations[index];
                final isSelected = location == _currentLocation;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentLocation = location;
                    });
                    Navigator.pop(context);
                    _refreshWeatherData();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.lightTheme.primaryColor.withValues(
                                alpha: 0.1,
                              )
                              : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isSelected
                              ? Border.all(
                                color: AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.3),
                              )
                              : null,
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          size: 5.w,
                          color:
                              isSelected
                                  ? AppTheme.lightTheme.primaryColor
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                              color:
                                  isSelected
                                      ? AppTheme.lightTheme.primaryColor
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            size: 5.w,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _shareWeather() {
    final weatherText =
        "Current weather in $_currentLocation: ${_currentWeather['temperature']}° ${_currentWeather['condition']}. Feels like ${_currentWeather['feelsLike']}°. Shared via Chronox Weather.";

    // In a real app, you would use the share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather data copied to clipboard'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshWeatherData,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LocationHeaderWidget(
                  location: _currentLocation,
                  onLocationTap: _showLocationSearch,
                  onRefresh: _refreshWeatherData,
                  isRefreshing: _isRefreshing,
                ),
              ),
              SliverToBoxAdapter(
                child: CurrentConditionsWidget(
                  currentWeather: _currentWeather,
                  isLoading: _isLoading,
                ),
              ),
              SliverToBoxAdapter(
                child: HourlyForecastWidget(
                  hourlyData: _hourlyForecast,
                  isLoading: _isLoading,
                ),
              ),
              SliverToBoxAdapter(
                child: WeatherAlertsWidget(alerts: _weatherAlerts),
              ),
              SliverToBoxAdapter(
                child: DailyForecastWidget(
                  dailyData: _dailyForecast,
                  isLoading: _isLoading,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 4.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _shareWeather,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: CustomIconWidget(
          iconName: 'share',
          size: 6.w,
          color: Colors.white,
        ),
      ),
    );
  }
}
