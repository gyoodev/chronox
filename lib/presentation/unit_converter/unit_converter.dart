import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_chip_widget.dart';
import './widgets/conversion_history_widget.dart';
import './widgets/swap_button_widget.dart';
import './widgets/unit_input_widget.dart';
import './widgets/unit_selector_modal.dart';

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  String _fromValue = '';
  String _toValue = '';
  List<Map<String, dynamic>> _conversionHistory = [];

  final List<String> _categories = [
    'Length',
    'Mass',
    'Volume',
    'Area',
    'Temperature',
    'Speed',
  ];

  final Map<String, List<Map<String, dynamic>>> _unitData = {
    'Length': [
      {'name': 'Meter', 'symbol': 'm', 'toMeter': 1.0},
      {'name': 'Kilometer', 'symbol': 'km', 'toMeter': 1000.0},
      {'name': 'Centimeter', 'symbol': 'cm', 'toMeter': 0.01},
      {'name': 'Millimeter', 'symbol': 'mm', 'toMeter': 0.001},
      {'name': 'Inch', 'symbol': 'in', 'toMeter': 0.0254},
      {'name': 'Foot', 'symbol': 'ft', 'toMeter': 0.3048},
      {'name': 'Yard', 'symbol': 'yd', 'toMeter': 0.9144},
      {'name': 'Mile', 'symbol': 'mi', 'toMeter': 1609.34},
    ],
    'Mass': [
      {'name': 'Kilogram', 'symbol': 'kg', 'toKg': 1.0},
      {'name': 'Gram', 'symbol': 'g', 'toKg': 0.001},
      {'name': 'Pound', 'symbol': 'lb', 'toKg': 0.453592},
      {'name': 'Ounce', 'symbol': 'oz', 'toKg': 0.0283495},
      {'name': 'Ton', 'symbol': 't', 'toKg': 1000.0},
      {'name': 'Stone', 'symbol': 'st', 'toKg': 6.35029},
    ],
    'Volume': [
      {'name': 'Liter', 'symbol': 'L', 'toLiter': 1.0},
      {'name': 'Milliliter', 'symbol': 'mL', 'toLiter': 0.001},
      {'name': 'Gallon (US)', 'symbol': 'gal', 'toLiter': 3.78541},
      {'name': 'Quart (US)', 'symbol': 'qt', 'toLiter': 0.946353},
      {'name': 'Pint (US)', 'symbol': 'pt', 'toLiter': 0.473176},
      {'name': 'Cup (US)', 'symbol': 'cup', 'toLiter': 0.236588},
      {'name': 'Fluid Ounce (US)', 'symbol': 'fl oz', 'toLiter': 0.0295735},
    ],
    'Area': [
      {'name': 'Square Meter', 'symbol': 'm²', 'toSqMeter': 1.0},
      {'name': 'Square Kilometer', 'symbol': 'km²', 'toSqMeter': 1000000.0},
      {'name': 'Square Centimeter', 'symbol': 'cm²', 'toSqMeter': 0.0001},
      {'name': 'Square Foot', 'symbol': 'ft²', 'toSqMeter': 0.092903},
      {'name': 'Square Inch', 'symbol': 'in²', 'toSqMeter': 0.00064516},
      {'name': 'Acre', 'symbol': 'ac', 'toSqMeter': 4046.86},
      {'name': 'Hectare', 'symbol': 'ha', 'toSqMeter': 10000.0},
    ],
    'Temperature': [
      {'name': 'Celsius', 'symbol': '°C'},
      {'name': 'Fahrenheit', 'symbol': '°F'},
      {'name': 'Kelvin', 'symbol': 'K'},
      {'name': 'Rankine', 'symbol': '°R'},
    ],
    'Speed': [
      {'name': 'Meter per Second', 'symbol': 'm/s', 'toMps': 1.0},
      {'name': 'Kilometer per Hour', 'symbol': 'km/h', 'toMps': 0.277778},
      {'name': 'Mile per Hour', 'symbol': 'mph', 'toMps': 0.44704},
      {'name': 'Foot per Second', 'symbol': 'ft/s', 'toMps': 0.3048},
      {'name': 'Knot', 'symbol': 'kn', 'toMps': 0.514444},
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateUnitsForCategory();
  }

  void _updateUnitsForCategory() {
    final units = _unitData[_selectedCategory] ?? [];
    if (units.isNotEmpty) {
      _fromUnit = units[0]['name'] as String;
      _toUnit =
          units.length > 1
              ? units[1]['name'] as String
              : units[0]['name'] as String;
    }
    _fromValue = '';
    _toValue = '';
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _updateUnitsForCategory();
    });
  }

  void _swapUnits() {
    setState(() {
      final tempUnit = _fromUnit;
      final tempValue = _fromValue;
      _fromUnit = _toUnit;
      _toUnit = tempUnit;
      _fromValue = _toValue;
      _toValue = tempValue;
    });
  }

  void _showUnitSelector({required bool isFromUnit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => UnitSelectorModal(
            category: _selectedCategory,
            units: _unitData[_selectedCategory] ?? [],
            selectedUnit: isFromUnit ? _fromUnit : _toUnit,
            onUnitSelected: (unit) {
              setState(() {
                if (isFromUnit) {
                  _fromUnit = unit;
                } else {
                  _toUnit = unit;
                }
                if (_fromValue.isNotEmpty) {
                  _convertValue(_fromValue);
                }
              });
            },
          ),
    );
  }

  void _convertValue(String value) {
    if (value.isEmpty) {
      setState(() {
        _fromValue = value;
        _toValue = '';
      });
      return;
    }

    final inputValue = double.tryParse(value);
    if (inputValue == null) {
      setState(() {
        _fromValue = value;
        _toValue = 'Invalid input';
      });
      return;
    }

    setState(() {
      _fromValue = value;
      _toValue = _performConversion(
        inputValue,
        _fromUnit,
        _toUnit,
        _selectedCategory,
      );
    });

    // Add to history
    _addToHistory();
  }

  String _performConversion(
    double value,
    String fromUnit,
    String toUnit,
    String category,
  ) {
    if (fromUnit == toUnit) return value.toString();

    switch (category) {
      case 'Length':
        return _convertLength(value, fromUnit, toUnit);
      case 'Mass':
        return _convertMass(value, fromUnit, toUnit);
      case 'Volume':
        return _convertVolume(value, fromUnit, toUnit);
      case 'Area':
        return _convertArea(value, fromUnit, toUnit);
      case 'Temperature':
        return _convertTemperature(value, fromUnit, toUnit);
      case 'Speed':
        return _convertSpeed(value, fromUnit, toUnit);
      default:
        return value.toString();
    }
  }

  String _convertLength(double value, String fromUnit, String toUnit) {
    final units = _unitData['Length']!;
    final fromFactor =
        units.firstWhere((u) => u['name'] == fromUnit)['toMeter'] as double;
    final toFactor =
        units.firstWhere((u) => u['name'] == toUnit)['toMeter'] as double;

    final result = (value * fromFactor) / toFactor;
    return _formatResult(result);
  }

  String _convertMass(double value, String fromUnit, String toUnit) {
    final units = _unitData['Mass']!;
    final fromFactor =
        units.firstWhere((u) => u['name'] == fromUnit)['toKg'] as double;
    final toFactor =
        units.firstWhere((u) => u['name'] == toUnit)['toKg'] as double;

    final result = (value * fromFactor) / toFactor;
    return _formatResult(result);
  }

  String _convertVolume(double value, String fromUnit, String toUnit) {
    final units = _unitData['Volume']!;
    final fromFactor =
        units.firstWhere((u) => u['name'] == fromUnit)['toLiter'] as double;
    final toFactor =
        units.firstWhere((u) => u['name'] == toUnit)['toLiter'] as double;

    final result = (value * fromFactor) / toFactor;
    return _formatResult(result);
  }

  String _convertArea(double value, String fromUnit, String toUnit) {
    final units = _unitData['Area']!;
    final fromFactor =
        units.firstWhere((u) => u['name'] == fromUnit)['toSqMeter'] as double;
    final toFactor =
        units.firstWhere((u) => u['name'] == toUnit)['toSqMeter'] as double;

    final result = (value * fromFactor) / toFactor;
    return _formatResult(result);
  }

  String _convertTemperature(double value, String fromUnit, String toUnit) {
    double celsius = value;

    // Convert to Celsius first
    switch (fromUnit) {
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      case 'Rankine':
        celsius = (value - 491.67) * 5 / 9;
        break;
    }

    // Convert from Celsius to target unit
    double result = celsius;
    switch (toUnit) {
      case 'Fahrenheit':
        result = celsius * 9 / 5 + 32;
        break;
      case 'Kelvin':
        result = celsius + 273.15;
        break;
      case 'Rankine':
        result = celsius * 9 / 5 + 491.67;
        break;
    }

    return _formatResult(result);
  }

  String _convertSpeed(double value, String fromUnit, String toUnit) {
    final units = _unitData['Speed']!;
    final fromFactor =
        units.firstWhere((u) => u['name'] == fromUnit)['toMps'] as double;
    final toFactor =
        units.firstWhere((u) => u['name'] == toUnit)['toMps'] as double;

    final result = (value * fromFactor) / toFactor;
    return _formatResult(result);
  }

  String _formatResult(double result) {
    if (result == result.roundToDouble()) {
      return result.round().toString();
    } else if (result.abs() >= 1000000) {
      return result.toStringAsExponential(3);
    } else if (result.abs() < 0.001 && result != 0) {
      return result.toStringAsExponential(3);
    } else {
      return result
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0*\$'), '')
          .replaceAll(RegExp(r'\.\$'), '');
    }
  }

  void _addToHistory() {
    if (_fromValue.isNotEmpty &&
        _toValue.isNotEmpty &&
        _toValue != 'Invalid input') {
      final now = DateTime.now();
      final timestamp =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final conversion = {
        'category': _selectedCategory,
        'fromValue': _fromValue,
        'fromUnit': _fromUnit,
        'toValue': _toValue,
        'toUnit': _toUnit,
        'timestamp': timestamp,
      };

      setState(() {
        _conversionHistory.insert(0, conversion);
        if (_conversionHistory.length > 20) {
          _conversionHistory.removeLast();
        }
      });
    }
  }

  void _copyResult() {
    if (_toValue.isNotEmpty && _toValue != 'Invalid input') {
      Clipboard.setData(ClipboardData(text: _toValue));
      Fluttertoast.showToast(
        msg: 'Result copied to clipboard',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      _conversionHistory.removeAt(index);
    });
  }

  void _reuseConversion(Map<String, dynamic> conversion) {
    setState(() {
      _selectedCategory = conversion['category'] as String;
      _fromUnit = conversion['fromUnit'] as String;
      _toUnit = conversion['toUnit'] as String;
      _fromValue = conversion['fromValue'] as String;
      _toValue = conversion['toValue'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Unit Converter',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _fromValue = '';
                _toValue = '';
              });
            },
            child: Container(
              margin: EdgeInsets.all(2.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _fromValue = '';
            _toValue = '';
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category chips
              Container(
                height: 6.h,
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return CategoryChipWidget(
                      category: category,
                      isSelected: category == _selectedCategory,
                      onTap: () => _selectCategory(category),
                    );
                  },
                ),
              ),

              SizedBox(height: 2.h),

              // From unit input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: UnitInputWidget(
                  title: 'From',
                  selectedUnit: _fromUnit,
                  value: _fromValue,
                  onUnitTap: () => _showUnitSelector(isFromUnit: true),
                  onValueChanged: _convertValue,
                ),
              ),

              SizedBox(height: 2.h),

              // Swap button
              SwapButtonWidget(onSwap: _swapUnits),

              SizedBox(height: 2.h),

              // To unit input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: UnitInputWidget(
                  title: 'To',
                  selectedUnit: _toUnit,
                  value: _toValue,
                  isReadOnly: true,
                  onUnitTap: () => _showUnitSelector(isFromUnit: false),
                  onCopy: _copyResult,
                ),
              ),

              SizedBox(height: 4.h),

              // Conversion history
              ConversionHistoryWidget(
                history: _conversionHistory,
                onDelete: _deleteHistoryItem,
                onReuse: _reuseConversion,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
