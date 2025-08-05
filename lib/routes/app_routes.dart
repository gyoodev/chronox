import 'package:flutter/material.dart';
import '../presentation/tools_grid/tools_grid.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/weather_widget/weather_widget.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/unit_converter/unit_converter.dart';
import '../presentation/currency_converter/currency_converter.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String toolsGrid = '/tools-grid';
  static const String splash = '/splash-screen';
  static const String weatherWidget = '/weather-widget';
  static const String homeDashboard = '/home-dashboard';
  static const String unitConverter = '/unit-converter';
  static const String currencyConverter = '/currency-converter';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    toolsGrid: (context) => const ToolsGrid(),
    splash: (context) => const SplashScreen(),
    weatherWidget: (context) => const WeatherWidget(),
    homeDashboard: (context) => const HomeDashboard(),
    unitConverter: (context) => const UnitConverter(),
    currencyConverter: (context) => const CurrencyConverter(),
    // TODO: Add your other routes here
  };
}
