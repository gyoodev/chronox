import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherService {
  static const String _baseUrl = 'http://dataservice.accuweather.com';
  late final Dio _dio;
  late final Future<String> _apiKey;

  WeatherService() {
    _dio = Dio();
    _apiKey = _loadApiKey();
  }

  Future<String> _loadApiKey() async {
    final String jsonString = await rootBundle.loadString('env.json');
    final Map<String, dynamic> env = json.decode(jsonString);
    return env['ACCUWEATHER_API_KEY'] ?? '';
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

    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      }
    } else if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
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

  Future<String?> _getLocationKeyFromCoords(double lat, double lon) async {
    final apiKey = await _apiKey;
    try {
      final response = await _dio.get(
        '$_baseUrl/locations/v1/cities/geoposition/search',
        queryParameters: {
          'apikey': apiKey,
          'q': '$lat,$lon',
        },
      );
      if (response.statusCode == 200) {
        return response.data['Key'];
      }
    } catch (e) {
      print('Error getting location key from coords: $e');
    }
    return null;
  }

  Future<String?> _getLocationKeyFromCity(String cityName) async {
    final apiKey = await _apiKey;
    try {
      final response = await _dio.get(
        '$_baseUrl/locations/v1/cities/search',
        queryParameters: {
          'apikey': apiKey,
          'q': cityName,
        },
      );
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        return response.data[0]['Key'];
      }
    } catch (e) {
      print('Error getting location key from city: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final locationKey = await _getLocationKeyFromCoords(lat, lon);
    if (locationKey == null) return null;
    return _getWeatherByLocationKey(locationKey);
  }

  Future<Map<String, dynamic>?> getWeatherByCity(String cityName) async {
    final locationKey = await _getLocationKeyFromCity(cityName);
    if (locationKey == null) return null;
    return _getWeatherByLocationKey(locationKey);
  }

  Future<Map<String, dynamic>?> _getWeatherByLocationKey(
      String locationKey) async {
    final apiKey = await _apiKey;
    try {
      final currentConditionsFuture = _dio.get(
        '$_baseUrl/currentconditions/v1/$locationKey',
        queryParameters: {'apikey': apiKey, 'details': 'true'},
      );

      final hourlyForecastFuture = _dio.get(
        '$_baseUrl/forecasts/v1/hourly/12hour/$locationKey',
        queryParameters: {'apikey': apiKey, 'metric': 'true'},
      );

      final dailyForecastFuture = _dio.get(
        '$_baseUrl/forecasts/v1/daily/5day/$locationKey',
        queryParameters: {'apikey': apiKey, 'metric': 'true'},
      );

      final responses = await Future.wait([
        currentConditionsFuture,
        hourlyForecastFuture,
        dailyForecastFuture,
      ]);

      if (responses.every((res) => res.statusCode == 200)) {
        return _parseWeatherData(
          responses[0].data[0],
          responses[1].data,
          responses[2].data,
        );
      }
    } catch (e) {
      print('Error fetching weather by location key: $e');
    }
    return null;
  }

  Map<String, dynamic> _parseWeatherData(
    Map<String, dynamic> current,
    List<dynamic> hourly,
    Map<String, dynamic> daily,
  ) {
    return {
      'current': {
        'temperature': current['Temperature']['Metric']['Value'].round(),
        'condition': _getWeatherCondition(current['WeatherText']),
        'description': current['WeatherText'],
        'feelsLike':
            current['RealFeelTemperature']['Metric']['Value'].round(),
        'humidity': current['RelativeHumidity'],
        'windSpeed':
            current['Wind']['Speed']['Metric']['Value'].round(),
        'pressure': current['Pressure']['Metric']['Value'].round(),
        'uvIndex': current['UVIndex'],
        'visibility':
            current['Visibility']['Metric']['Value'].round(),
      },
      'hourly': hourly.map((hour) {
        return {
          'time': _formatHourlyTime(hour['EpochDateTime']),
          'temperature': hour['Temperature']['Value'].round(),
          'condition': _getWeatherCondition(hour['IconPhrase']),
          'precipitation': hour['PrecipitationProbability'],
        };
      }).toList(),
      'daily': (daily['DailyForecasts'] as List).map((day) {
        return {
          'day': _formatDailyTime(day['EpochDate']),
          'condition': _getWeatherCondition(day['Day']['IconPhrase']),
          'high': day['Temperature']['Maximum']['Value'].round(),
          'low': day['Temperature']['Minimum']['Value'].round(),
          'precipitation': day['Day']['PrecipitationProbability'],
          'morning': day['RealFeelTemperature']['Maximum']['Value'].round(),
          'afternoon': day['RealFeelTemperature']['Maximum']['Value'].round(),
          'evening': day['RealFeelTemperature']['Minimum']['Value'].round(),
          'night': day['RealFeelTemperature']['Minimum']['Value'].round(),
          'humidity': 0, // Not available in daily forecast
          'windSpeed':
              day['Day']['Wind']['Speed']['Value'].round(),
          'uvIndex': 0, // Not available in daily forecast
        };
      }).toList(),
      'alerts': [], // AccuWeather alerts API is separate and not implemented here
    };
  }

  String _getWeatherCondition(String phrase) {
    final p = phrase.toLowerCase();
    if (p.contains('sunny') || p.contains('clear')) return 'sunny';
    if (p.contains('cloudy') || p.contains('clouds')) return 'cloudy';
    if (p.contains('rain') || p.contains('showers')) return 'rainy';
    if (p.contains('t-storms') || p.contains('thunderstorm')) return 'thunderstorm';
    if (p.contains('snow')) return 'snowy';
    if (p.contains('fog') || p.contains('mist')) return 'foggy';
    return 'partly_cloudy';
  }

  String _formatHourlyTime(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:00';
  }

  String _formatDailyTime(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final now = DateTime.now();
    if (dt.day == now.day) return 'Today';
    if (dt.day == now.day + 1) return 'Tomorrow';
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[dt.weekday - 1];
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];
    final apiKey = await _apiKey;
    try {
      final response = await _dio.get(
        '$_baseUrl/locations/v1/cities/autocomplete',
        queryParameters: {
          'apikey': apiKey,
          'q': query,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((city) {
          return {
            'name': city['LocalizedName'] +
                ', ' +
                city['Country']['LocalizedName'],
            'lat': 0.0, // AccuWeather autocomplete doesn't provide lat/lon
            'lon': 0.0,
          };
        }).toList();
      }
    } catch (e) {
      print('Error searching cities: $e');
    }
    return [];
  }
}
