import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/weather_service.dart';
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
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _currentLocation = "Loading...";
  double? _currentLat;
  double? _currentLon;

  // Weather data
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _hourlyForecast = [];
  List<Map<String, dynamic>> _dailyForecast = [];
  List<Map<String, dynamic>> _weatherAlerts = [];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      final position = await _weatherService.getCurrentLocation();

      if (position != null) {
        _currentLat = position.latitude;
        _currentLon = position.longitude;

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
          setState(() {
            _currentLocation = locationName;
            _currentWeather = weatherData['current'];
            _hourlyForecast =
                List<Map<String, dynamic>>.from(weatherData['hourly']);
            _dailyForecast =
                List<Map<String, dynamic>>.from(weatherData['daily']);
            _weatherAlerts =
                List<Map<String, dynamic>>.from(weatherData['alerts']);
          });
        }
      } else {
        // Fallback to default location if location permission denied
        await _loadWeatherForCity('New York');
      }
    } catch (e) {
      print('Error loading weather data: $e');
      // Fallback to default location
      await _loadWeatherForCity('New York');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherForCity(String cityName) async {
    try {
      final weatherData = await _weatherService.getWeatherByCity(cityName);

      if (weatherData != null && mounted) {
        setState(() {
          _currentLocation = cityName;
          _currentWeather = weatherData['current'];
          _hourlyForecast =
              List<Map<String, dynamic>>.from(weatherData['hourly']);
          _dailyForecast =
              List<Map<String, dynamic>>.from(weatherData['daily']);
          _weatherAlerts =
              List<Map<String, dynamic>>.from(weatherData['alerts']);
        });
      }
    } catch (e) {
      print('Error loading weather for city: $e');
      // Use fallback data if API fails
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    // Fallback mock data if all else fails
    setState(() {
      _currentLocation = "Weather Unavailable";
      _currentWeather = {
        "temperature": 0,
        "condition": "Unknown",
        "feelsLike": 0,
        "humidity": 0,
        "windSpeed": 0,
        "pressure": 0,
      };
      _hourlyForecast = [];
      _dailyForecast = [];
      _weatherAlerts = [];
    });
  }

  Future<void> _refreshWeatherData() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = true;
    });

    if (_currentLat != null && _currentLon != null) {
      // Refresh with current coordinates
      try {
        final weatherData = await _weatherService.getWeatherByCoordinates(
          _currentLat!,
          _currentLon!,
        );

        if (weatherData != null && mounted) {
          setState(() {
            _currentWeather = weatherData['current'];
            _hourlyForecast =
                List<Map<String, dynamic>>.from(weatherData['hourly']);
            _dailyForecast =
                List<Map<String, dynamic>>.from(weatherData['daily']);
            _weatherAlerts =
                List<Map<String, dynamic>>.from(weatherData['alerts']);
          });
        }
      } catch (e) {
        print('Error refreshing weather: $e');
      }
    } else {
      // Try to get location again
      await _loadWeatherData();
    }

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
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
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        Future<void> searchCities(String query) async {
          if (query.length < 2) {
            setSheetState(() {
              searchResults = [];
            });
            return;
          }

          setSheetState(() {
            isSearching = true;
          });

          try {
            final results = await _weatherService.searchCities(query);
            setSheetState(() {
              searchResults = results;
              isSearching = false;
            });
          } catch (e) {
            setSheetState(() {
              searchResults = [];
              isSearching = false;
            });
          }
        }

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
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
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
                  controller: searchController,
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
                    suffixIcon: isSearching
                        ? Padding(
                            padding: EdgeInsets.all(3.w),
                            child: SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.lightTheme.primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    searchCities(value);
                  },
                ),
              ),
              SizedBox(height: 2.h),
              // Add current location option
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _loadWeatherData();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'my_location',
                          size: 5.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Use Current Location',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'gps_fixed',
                          size: 5.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final location = searchResults[index];

                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _currentLocation = location['name'];
                          _currentLat = location['lat'];
                          _currentLon = location['lon'];
                        });

                        try {
                          final weatherData =
                              await _weatherService.getWeatherByCoordinates(
                            location['lat'],
                            location['lon'],
                          );

                          if (weatherData != null && mounted) {
                            setState(() {
                              _currentWeather = weatherData['current'];
                              _hourlyForecast = List<Map<String, dynamic>>.from(
                                  weatherData['hourly']);
                              _dailyForecast = List<Map<String, dynamic>>.from(
                                  weatherData['daily']);
                              _weatherAlerts = List<Map<String, dynamic>>.from(
                                  weatherData['alerts']);
                              _isLoading = false;
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              size: 5.w,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                location['name'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
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
      },
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
