import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/weather_service.dart';
import './widgets/quick_tools_widget.dart';
import './widgets/recent_calculations_widget.dart';
import './widgets/today_highlights_widget.dart';
import './widgets/weather_card_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final ScrollController _scrollController = ScrollController();
  final WeatherService _weatherService = WeatherService();
  bool _isRefreshing = false;

  // Weather data - now loaded from real API
  Map<String, dynamic> _weatherData = {
    "temperature": 0,
    "condition": "Loading...",
    "location": "Loading...",
    "humidity": 0,
    "windSpeed": 0,
    "lastUpdated": DateTime.now().toString(),
  };

  // Mock data for quick tools
  final List<Map<String, dynamic>> _quickTools = [
    {
      "id": 1,
      "title": "Currency Converter",
      "icon": "currency_exchange",
      "route": "/currency-converter",
      "color": Color(0xFF1976D2),
      "lastValue": "100 USD = 85 EUR",
    },
    {
      "id": 2,
      "title": "Unit Converter",
      "icon": "straighten",
      "route": "/unit-converter",
      "color": Color(0xFFFF6B35),
      "lastValue": "1 m = 3.28 ft",
    },
    {
      "id": 3,
      "title": "BMI Calculator",
      "icon": "monitor_weight",
      "route": "/tools-grid",
      "color": Color(0xFF4CAF50),
      "lastValue": "BMI: 22.5",
    },
    {
      "id": 4,
      "title": "Temperature",
      "icon": "thermostat",
      "route": "/tools-grid",
      "color": Color(0xFFFF9800),
      "lastValue": "25°C = 77°F",
    },
    {
      "id": 5,
      "title": "Finance Calculator",
      "icon": "calculate",
      "route": "/tools-grid",
      "color": Color(0xFF9C27B0),
      "lastValue": null,
    },
    {
      "id": 6,
      "title": "Data Storage",
      "icon": "storage",
      "route": "/tools-grid",
      "color": Color(0xFF607D8B),
      "lastValue": "1 GB = 1024 MB",
    },
  ];

  // Mock data for recent calculations
  final List<Map<String, dynamic>> _recentCalculations = [
    {
      "id": 1,
      "toolName": "Currency Converter",
      "toolIcon": "currency_exchange",
      "toolColor": Color(0xFF1976D2),
      "calculation": "100 USD to EUR",
      "result": "85.50 EUR",
      "time": "2 hours ago",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": 2,
      "toolName": "BMI Calculator",
      "toolIcon": "monitor_weight",
      "toolColor": Color(0xFF4CAF50),
      "calculation": "Height: 175cm, Weight: 70kg",
      "result": "BMI: 22.9 (Normal)",
      "time": "5 hours ago",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
    },
    {
      "id": 3,
      "toolName": "Unit Converter",
      "toolIcon": "straighten",
      "toolColor": Color(0xFFFF6B35),
      "calculation": "5 meters to feet",
      "result": "16.40 feet",
      "time": "1 day ago",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
    },
    {
      "id": 4,
      "toolName": "Temperature Converter",
      "toolIcon": "thermostat",
      "toolColor": Color(0xFFFF9800),
      "calculation": "25°C to Fahrenheit",
      "result": "77°F",
      "time": "2 days ago",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
    },
  ];

  // Mock data for today's highlights
  late Map<String, dynamic> _highlightsData;

  @override
  void initState() {
    super.initState();
    _initializeHighlights();
    _loadWeatherData();
  }

  void _initializeHighlights() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final weekOfYear = ((dayOfYear - now.weekday + 10) / 7).floor();
    final daysUntilWeekend = 6 - now.weekday;
    final currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    _highlightsData = {
      "dayOfYear": dayOfYear,
      "weekOfYear": weekOfYear,
      "daysUntilWeekend": daysUntilWeekend > 0 ? daysUntilWeekend : 0,
      "currentTime": currentTime,
    };
  }

  Future<void> _loadWeatherData() async {
    try {
      // Get current location
      final position = await _weatherService.getCurrentLocation();

      if (position != null) {
        // Get location name
        final locationName = await _weatherService.getLocationName(
          position.latitude,
          position.longitude,
        );

        // Get weather data
        final weatherData = await _weatherService.getWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );

        if (weatherData != null && mounted) {
          final current = weatherData['current'];
          setState(() {
            _weatherData = {
              "temperature": current['temperature'],
              "condition": current['condition'],
              "location": locationName,
              "humidity": current['humidity'],
              "windSpeed": current['windSpeed'],
              "lastUpdated": DateTime.now().toString(),
            };
          });
        }
      } else {
        // Fallback to a default city
        await _loadWeatherForCity('New York');
      }
    } catch (e) {
      print('Error loading weather data: $e');
      // Fallback to a default city
      await _loadWeatherForCity('New York');
    }
  }

  Future<void> _loadWeatherForCity(String cityName) async {
    try {
      final weatherData = await _weatherService.getWeatherByCity(cityName);

      if (weatherData != null && mounted) {
        final current = weatherData['current'];
        setState(() {
          _weatherData = {
            "temperature": current['temperature'],
            "condition": current['condition'],
            "location": cityName,
            "humidity": current['humidity'],
            "windSpeed": current['windSpeed'],
            "lastUpdated": DateTime.now().toString(),
          };
        });
      }
    } catch (e) {
      print('Error loading weather for city: $e');
      // Keep the loading state or show error
      setState(() {
        _weatherData = {
          "temperature": 0,
          "condition": "Weather Unavailable",
          "location": "Unable to Load",
          "humidity": 0,
          "windSpeed": 0,
          "lastUpdated": DateTime.now().toString(),
        };
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return "${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Reload weather data with real API call
    await _loadWeatherData();

    // Refresh highlights data
    _initializeHighlights();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _handleToolTap(String route) {
    Navigator.pushNamed(context, route);
  }

  void _handleDeleteCalculation(int index) {
    setState(() {
      _recentCalculations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculation removed'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // In a real app, you would restore the deleted item
          },
        ),
      ),
    );
  }

  void _handleWeatherTap() {
    Navigator.pushNamed(context, '/weather-widget');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Header
              SliverAppBar(
                expandedHeight: 15.h,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getCurrentDate(),
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Handle search/quick tool discovery
                    },
                    icon: CustomIconWidget(
                      iconName: 'search',
                      size: 6.w,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
              ),

              // Main Content
              SliverList(
                delegate: SliverChildListDelegate([
                  // Weather Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: WeatherCardWidget(
                      weatherData: _weatherData,
                      onTap: _handleWeatherTap,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Quick Tools Section
                  QuickToolsWidget(
                    quickTools: _quickTools,
                    onToolTap: _handleToolTap,
                  ),

                  SizedBox(height: 3.h),

                  // Today's Highlights
                  TodayHighlightsWidget(highlightsData: _highlightsData),

                  SizedBox(height: 3.h),

                  // Recent Calculations
                  RecentCalculationsWidget(
                    recentCalculations: _recentCalculations,
                    onDelete: _handleDeleteCalculation,
                  ),

                  SizedBox(height: 10.h), // Bottom padding for navigation
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleToolTap('/tools-grid'),
        backgroundColor: AppTheme.accentColor,
        child: CustomIconWidget(
          iconName: 'apps',
          size: 6.w,
          color: Colors.white,
        ),
      ),
    );
  }
}
