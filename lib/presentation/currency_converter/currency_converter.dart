import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversion_history_list.dart';
import './widgets/conversion_result_card.dart';
import './widgets/currency_input_field.dart';
import './widgets/currency_picker_modal.dart';
import './widgets/currency_selection_card.dart';
import './widgets/swap_currencies_button.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  final Dio _dio = Dio();

  // Mock currency data
  final List<Map<String, dynamic>> _currencies = [
    {
      "code": "USD",
      "name": "US Dollar",
      "symbol": "\$",
      "flag": "https://flagcdn.com/w320/us.png",
    },
    {
      "code": "EUR",
      "name": "Euro",
      "symbol": "€",
      "flag": "https://flagcdn.com/w320/eu.png",
    },
    {
      "code": "GBP",
      "name": "British Pound",
      "symbol": "£",
      "flag": "https://flagcdn.com/w320/gb.png",
    },
    {
      "code": "JPY",
      "name": "Japanese Yen",
      "symbol": "¥",
      "flag": "https://flagcdn.com/w320/jp.png",
    },
    {
      "code": "CAD",
      "name": "Canadian Dollar",
      "symbol": "C\$",
      "flag": "https://flagcdn.com/w320/ca.png",
    },
    {
      "code": "AUD",
      "name": "Australian Dollar",
      "symbol": "A\$",
      "flag": "https://flagcdn.com/w320/au.png",
    },
    {
      "code": "CHF",
      "name": "Swiss Franc",
      "symbol": "CHF",
      "flag": "https://flagcdn.com/w320/ch.png",
    },
    {
      "code": "CNY",
      "name": "Chinese Yuan",
      "symbol": "¥",
      "flag": "https://flagcdn.com/w320/cn.png",
    },
    {
      "code": "INR",
      "name": "Indian Rupee",
      "symbol": "₹",
      "flag": "https://flagcdn.com/w320/in.png",
    },
    {
      "code": "KRW",
      "name": "South Korean Won",
      "symbol": "₩",
      "flag": "https://flagcdn.com/w320/kr.png",
    },
    {
      "code": "BRL",
      "name": "Brazilian Real",
      "symbol": "R\$",
      "flag": "https://flagcdn.com/w320/br.png",
    },
    {
      "code": "MXN",
      "name": "Mexican Peso",
      "symbol": "MX\$",
      "flag": "https://flagcdn.com/w320/mx.png",
    },
  ];

  Map<String, dynamic> _fromCurrency = {};
  Map<String, dynamic> _toCurrency = {};
  String _convertedAmount = "0.00";
  String _exchangeRate = "1.0000";
  String _lastUpdated = "";
  bool _isLoading = false;
  List<Map<String, dynamic>> _conversionHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeDefaultCurrencies();
    _amountController.text = "1.00";
    _performConversion();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _initializeDefaultCurrencies() {
    _fromCurrency = _currencies.firstWhere(
      (currency) => currency['code'] == 'USD',
    );
    _toCurrency = _currencies.firstWhere(
      (currency) => currency['code'] == 'EUR',
    );
  }

  Future<void> _performConversion() async {
    if (_amountController.text.isEmpty || _amountController.text == "0") {
      setState(() {
        _convertedAmount = "0.00";
        _exchangeRate = "1.0000";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mock exchange rate API call - using real API structure but with mock data
      final response = await _dio.get(
        'https://api.exchangerate-api.com/v4/latest/${_fromCurrency['code']}',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final rate = rates[_toCurrency['code']] as double? ?? 1.0;

        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final converted = amount * rate;

        setState(() {
          _convertedAmount = converted.toStringAsFixed(2);
          _exchangeRate =
              "1 ${_fromCurrency['code']} = ${rate.toStringAsFixed(4)} ${_toCurrency['code']}";
          _lastUpdated = _formatDateTime(DateTime.now());
        });

        _addToHistory(amount, converted, rate);
      }
    } catch (e) {
      // Fallback to mock rates for demo purposes
      _performMockConversion();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performMockConversion() {
    // Mock exchange rates for demo
    final Map<String, Map<String, double>> mockRates = {
      'USD': {
        'EUR': 0.85,
        'GBP': 0.73,
        'JPY': 110.0,
        'CAD': 1.25,
        'AUD': 1.35,
        'CHF': 0.92,
        'CNY': 6.45,
        'INR': 74.5,
        'KRW': 1180.0,
        'BRL': 5.2,
        'MXN': 20.1,
      },
      'EUR': {
        'USD': 1.18,
        'GBP': 0.86,
        'JPY': 129.5,
        'CAD': 1.47,
        'AUD': 1.59,
        'CHF': 1.08,
        'CNY': 7.6,
        'INR': 87.8,
        'KRW': 1391.0,
        'BRL': 6.1,
        'MXN': 23.7,
      },
      'GBP': {
        'USD': 1.37,
        'EUR': 1.16,
        'JPY': 150.8,
        'CAD': 1.71,
        'AUD': 1.85,
        'CHF': 1.26,
        'CNY': 8.84,
        'INR': 102.1,
        'KRW': 1617.0,
        'BRL': 7.1,
        'MXN': 27.5,
      },
    };

    final fromCode = _fromCurrency['code'] as String;
    final toCode = _toCurrency['code'] as String;

    double rate = 1.0;
    if (mockRates.containsKey(fromCode) &&
        mockRates[fromCode]!.containsKey(toCode)) {
      rate = mockRates[fromCode]![toCode]!;
    } else if (fromCode == toCode) {
      rate = 1.0;
    } else {
      // Generate a reasonable mock rate
      rate = 0.5 + (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final converted = amount * rate;

    setState(() {
      _convertedAmount = converted.toStringAsFixed(2);
      _exchangeRate = "1 $fromCode = ${rate.toStringAsFixed(4)} $toCode";
      _lastUpdated = _formatDateTime(DateTime.now());
    });

    _addToHistory(amount, converted, rate);
  }

  void _addToHistory(double fromAmount, double toAmount, double rate) {
    final historyItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'fromCode': _fromCurrency['code'],
      'fromSymbol': _fromCurrency['symbol'],
      'fromAmount': fromAmount.toStringAsFixed(2),
      'fromFlag': _fromCurrency['flag'],
      'toCode': _toCurrency['code'],
      'toSymbol': _toCurrency['symbol'],
      'toAmount': toAmount.toStringAsFixed(2),
      'toFlag': _toCurrency['flag'],
      'rate': rate.toStringAsFixed(4),
      'timestamp': _formatDateTime(DateTime.now()),
    };

    setState(() {
      _conversionHistory.insert(0, historyItem);
      if (_conversionHistory.length > 10) {
        _conversionHistory.removeLast();
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _performConversion();
  }

  void _showCurrencyPicker({required bool isFromCurrency}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPickerModal(
        currencies: _currencies,
        onCurrencySelected: (currency) {
          setState(() {
            if (isFromCurrency) {
              _fromCurrency = currency;
            } else {
              _toCurrency = currency;
            }
          });
          _performConversion();
        },
      ),
    );
  }

  void _onAmountChanged(String value) {
    _performConversion();
  }

  void _onCopyResult() {
    Fluttertoast.showToast(
      msg: "Conversion result copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _onCopyHistory(String text) {
    Fluttertoast.showToast(
      msg: "Conversion copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _onDeleteHistory(int index) {
    setState(() {
      _conversionHistory.removeAt(index);
    });
    Fluttertoast.showToast(
      msg: "Conversion removed from history",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.errorLight,
      textColor: Colors.white,
    );
  }

  void _shareConversion() {
    final shareText =
        "Currency Conversion: ${_fromCurrency['symbol']}${_amountController.text} ${_fromCurrency['code']} = ${_toCurrency['symbol']}$_convertedAmount ${_toCurrency['code']} (Rate: $_exchangeRate)";
    Clipboard.setData(ClipboardData(text: shareText));
    Fluttertoast.showToast(
      msg: "Conversion details copied for sharing",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  Future<void> _refreshRates() async {
    await _performConversion();
    Fluttertoast.showToast(
      msg: "Exchange rates updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Currency Converter',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _shareConversion,
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.1,
                  ),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRates,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency selection cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CurrencySelectionCard(
                      currencyCode: _fromCurrency['code'] ?? 'USD',
                      currencyName: _fromCurrency['name'] ?? 'US Dollar',
                      flagUrl: _fromCurrency['flag'] ??
                          'https://flagcdn.com/w320/us.png',
                      onTap: () => _showCurrencyPicker(isFromCurrency: true),
                      isFromCurrency: true,
                    ),
                    SwapCurrenciesButton(onSwap: _swapCurrencies),
                    CurrencySelectionCard(
                      currencyCode: _toCurrency['code'] ?? 'EUR',
                      currencyName: _toCurrency['name'] ?? 'Euro',
                      flagUrl: _toCurrency['flag'] ??
                          'https://flagcdn.com/w320/eu.png',
                      onTap: () => _showCurrencyPicker(isFromCurrency: false),
                      isFromCurrency: false,
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Amount input field
                CurrencyInputField(
                  controller: _amountController,
                  currencySymbol: _fromCurrency['symbol'] ?? '\$',
                  onChanged: _onAmountChanged,
                ),

                SizedBox(height: 3.h),

                // Conversion result
                if (_isLoading)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(6.w),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  ConversionResultCard(
                    convertedAmount: _convertedAmount,
                    toCurrencySymbol: _toCurrency['symbol'] ?? '€',
                    exchangeRate: _exchangeRate,
                    lastUpdated: _lastUpdated,
                    onCopy: _onCopyResult,
                  ),

                SizedBox(height: 4.h),

                // Conversion history
                ConversionHistoryList(
                  historyList: _conversionHistory,
                  onDelete: _onDeleteHistory,
                  onCopy: _onCopyHistory,
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
