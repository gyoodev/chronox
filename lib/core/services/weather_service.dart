import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geocodingUrl = 'https://api.openweathermap.org/geo/1.0';
  late final Dio _dio;
  late final String _apiKey;

  WeatherService() {
    _dio = Dio();
    _apiKey = _getApiKey();
  }

  String _getApiKey() {
    // In a real app, load from env.json or secure storage
    return 'your-openweathermap-api-key-here';
  }

  // Get current location using device GPS
  Future<Position?> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // For web, use browser geolocation
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        return position;
      } else {
        // For mobile, check permissions first
        final hasPermission = await _requestLocationPermission();
        if (!hasPermission) return null;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        return position;
      }
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<bool> _requestLocationPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.location.status;
    if (status.isGranted) return true;

    final result = await Permission.location.request();
    return result.isGranted;
  }

  // Get location name from coordinates
  Future<String> getLocationName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.administrativeArea ?? '';
        final country = place.country ?? '';
        return city.isNotEmpty ? '$city, $country' : 'Unknown Location';
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return 'Unknown Location';
  }

  // Get weather data by coordinates
  Future<Map<String, dynamic>?> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/onecall',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'exclude': 'minutely',
        },
      );

      if (response.statusCode == 200) {
        return _parseWeatherData(response.data);
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  // Get weather data by city name
  Future<Map<String, dynamic>?> getWeatherByCity(String cityName) async {
    try {
      // First get coordinates for the city
      final geoResponse = await _dio.get(
        '$_geocodingUrl/direct',
        queryParameters: {
          'q': cityName,
          'limit': 1,
          'appid': _apiKey,
        },
      );

      if (geoResponse.statusCode == 200 &&
          geoResponse.data is List &&
          (geoResponse.data as List).isNotEmpty) {
        final location = geoResponse.data[0];
        final lat = location['lat'];
        final lon = location['lon'];

        return await getWeatherByCoordinates(lat, lon);
      }
    } catch (e) {
      print('Error fetching weather by city: $e');
    }
    return null;
  }

  Map<String, dynamic> _parseWeatherData(Map<String, dynamic> data) {
    final current = data['current'];
    final hourly = data['hourly'] as List;
    final daily = data['daily'] as List;
    final alerts = data['alerts'] as List? ?? [];

    return {
      'current': {
        'temperature': current['temp'].round(),
        'condition': _getWeatherCondition(current['weather'][0]['main']),
        'description': current['weather'][0]['description'],
        'feelsLike': current['feels_like'].round(),
        'humidity': current['humidity'],
        'windSpeed':
            (current['wind_speed'] * 3.6).round(), // Convert m/s to km/h
        'pressure': current['pressure'],
        'uvIndex': current['uvi'].round(),
        'visibility': (current['visibility'] / 1000).round(), // Convert m to km
      },
      'hourly': hourly.take(8).map((hour) {
        return {
          'time': _formatHourlyTime(hour['dt']),
          'temperature': hour['temp'].round(),
          'condition': _getWeatherCondition(hour['weather'][0]['main']),
          'precipitation': ((hour['pop'] ?? 0) * 100).round(),
        };
      }).toList(),
      'daily': daily.take(7).map((day) {
        return {
          'day': _formatDailyTime(day['dt']),
          'condition': _getWeatherCondition(day['weather'][0]['main']),
          'high': day['temp']['max'].round(),
          'low': day['temp']['min'].round(),
          'precipitation': ((day['pop'] ?? 0) * 100).round(),
          'morning': day['temp']['morn'].round(),
          'afternoon': day['temp']['day'].round(),
          'evening': day['temp']['eve'].round(),
          'night': day['temp']['night'].round(),
          'humidity': day['humidity'],
          'windSpeed': (day['wind_speed'] * 3.6).round(),
          'uvIndex': day['uvi'].round(),
        };
      }).toList(),
      'alerts': alerts.map((alert) {
        return {
          'title': alert['event'] ?? 'Weather Alert',
          'severity': _getAlertSeverity(alert['event'] ?? ''),
          'time': 'Valid until ${_formatAlertTime(alert['end'])}',
          'description': alert['description'] ?? '',
          'startTime': _formatAlertTime(alert['start']),
          'endTime': _formatAlertTime(alert['end']),
        };
      }).toList(),
    };
  }

  String _getWeatherCondition(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rainy';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snowy';
      case 'mist':
      case 'fog':
        return 'foggy';
      default:
        return 'partly_cloudy';
    }
  }

  String _getAlertSeverity(String event) {
    final lowercaseEvent = event.toLowerCase();
    if (lowercaseEvent.contains('warning') ||
        lowercaseEvent.contains('severe') ||
        lowercaseEvent.contains('tornado') ||
        lowercaseEvent.contains('hurricane')) {
      return 'severe';
    } else if (lowercaseEvent.contains('watch') ||
        lowercaseEvent.contains('advisory')) {
      return 'moderate';
    }
    return 'minor';
  }

  String _formatHourlyTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();

    if (dateTime.hour == now.hour && dateTime.day == now.day) {
      return 'Now';
    }

    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  String _formatDailyTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();

    if (dateTime.day == now.day && dateTime.month == now.month) {
      return 'Today';
    } else if (dateTime.day == now.day + 1 && dateTime.month == now.month) {
      return 'Tomorrow';
    }

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[dateTime.weekday - 1];
  }

  String _formatAlertTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Search for cities (for location search functionality)
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_geocodingUrl/direct',
        queryParameters: {
          'q': query,
          'limit': 5,
          'appid': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((city) {
          final country = city['country'] ?? '';
          final state = city['state'] ?? '';
          final name = city['name'] ?? '';

          String displayName = name;
          if (state.isNotEmpty) {
            displayName += ', $state';
          }
          if (country.isNotEmpty) {
            displayName += ', $country';
          }

          return {
            'name': displayName,
            'lat': city['lat'],
            'lon': city['lon'],
          };
        }).toList();
      }
    } catch (e) {
      print('Error searching cities: $e');
    }
    return [];
  }
}
