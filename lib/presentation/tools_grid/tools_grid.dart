import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_filter_widget.dart';
import './widgets/empty_search_widget.dart';
import './widgets/favorites_section_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/tools_grid_widget.dart';

class ToolsGrid extends StatefulWidget {
  const ToolsGrid({Key? key}) : super(key: key);

  @override
  State<ToolsGrid> createState() => _ToolsGridState();
}

class _ToolsGridState extends State<ToolsGrid> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'Date Tools',
    'Converters',
    'Calculators',
    'Utilities',
  ];

  final List<Map<String, dynamic>> _allTools = [
    {
      'id': 'currency_converter',
      'title': 'Currency Converter',
      'description':
          'Convert between different currencies with real-time rates',
      'iconName': 'currency_exchange',
      'iconColor': AppTheme.successColor,
      'category': 'Converters',
      'route': '/currency-converter',
      'isFavorite': true,
      'hasRecentActivity': true,
      'requiresInternet': true,
    },
    {
      'id': 'unit_converter',
      'title': 'Unit Converter',
      'description': 'Convert length, weight, area, and volume measurements',
      'iconName': 'straighten',
      'iconColor': AppTheme.lightTheme.primaryColor,
      'category': 'Converters',
      'route': '/unit-converter',
      'isFavorite': false,
      'hasRecentActivity': true,
      'requiresInternet': false,
    },
    {
      'id': 'weather_widget',
      'title': 'Weather Widget',
      'description': 'Get current weather and forecasts for your location',
      'iconName': 'wb_sunny',
      'iconColor': AppTheme.warningColor,
      'category': 'Utilities',
      'route': '/weather-widget',
      'isFavorite': true,
      'hasRecentActivity': false,
      'requiresInternet': true,
    },
    {
      'id': 'date_calculator',
      'title': 'Date Calculator',
      'description': 'Calculate days between dates and date arithmetic',
      'iconName': 'date_range',
      'iconColor': AppTheme.accentColor,
      'category': 'Date Tools',
      'route': '/date-calculator',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'time_zone_converter',
      'title': 'Time Zone Converter',
      'description': 'Convert time between different time zones worldwide',
      'iconName': 'schedule',
      'iconColor': AppTheme.lightTheme.primaryColor,
      'category': 'Date Tools',
      'route': '/timezone-converter',
      'isFavorite': false,
      'hasRecentActivity': true,
      'requiresInternet': false,
    },
    {
      'id': 'loan_calculator',
      'title': 'Loan Calculator',
      'description': 'Calculate loan payments, interest, and amortization',
      'iconName': 'calculate',
      'iconColor': AppTheme.successColor,
      'category': 'Calculators',
      'route': '/loan-calculator',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'bmi_calculator',
      'title': 'BMI Calculator',
      'description': 'Calculate Body Mass Index and health recommendations',
      'iconName': 'monitor_weight',
      'iconColor': AppTheme.errorLight,
      'category': 'Calculators',
      'route': '/bmi-calculator',
      'isFavorite': true,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'discount_calculator',
      'title': 'Discount Calculator',
      'description': 'Calculate discounts, tax, and final prices',
      'iconName': 'local_offer',
      'iconColor': AppTheme.warningColor,
      'category': 'Calculators',
      'route': '/discount-calculator',
      'isFavorite': false,
      'hasRecentActivity': true,
      'requiresInternet': false,
    },
    {
      'id': 'temperature_converter',
      'title': 'Temperature Converter',
      'description': 'Convert between Celsius, Fahrenheit, and Kelvin',
      'iconName': 'thermostat',
      'iconColor': AppTheme.accentColor,
      'category': 'Converters',
      'route': '/temperature-converter',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'number_system_converter',
      'title': 'Number System',
      'description': 'Convert between binary, decimal, and hexadecimal',
      'iconName': 'code',
      'iconColor': AppTheme.lightTheme.primaryColor,
      'category': 'Converters',
      'route': '/number-converter',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'speed_converter',
      'title': 'Speed Converter',
      'description': 'Convert between different speed units',
      'iconName': 'speed',
      'iconColor': AppTheme.successColor,
      'category': 'Converters',
      'route': '/speed-converter',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
    {
      'id': 'data_storage_converter',
      'title': 'Data Storage',
      'description': 'Convert between bytes, KB, MB, GB, and TB',
      'iconName': 'storage',
      'iconColor': AppTheme.lightTheme.primaryColor,
      'category': 'Converters',
      'route': '/data-converter',
      'isFavorite': false,
      'hasRecentActivity': false,
      'requiresInternet': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredTools {
    List<Map<String, dynamic>> filtered = _allTools;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered
              .where((tool) => tool['category'] == _selectedCategory)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((tool) {
            final title = (tool['title'] as String).toLowerCase();
            final description = (tool['description'] as String).toLowerCase();
            final category = (tool['category'] as String).toLowerCase();
            final query = _searchQuery.toLowerCase();

            return title.contains(query) ||
                description.contains(query) ||
                category.contains(query);
          }).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _favoriteTools {
    return _allTools.where((tool) => tool['isFavorite'] == true).toList();
  }

  List<String> get _searchSuggestions {
    return [
      'Currency',
      'Temperature',
      'Calculator',
      'Date',
      'Weather',
      'BMI',
      'Loan',
    ];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call for exchange rates and weather data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exchange rates and weather data updated'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleToolTap(Map<String, dynamic> tool) {
    final route = tool['route'] as String?;
    if (route != null) {
      Navigator.pushNamed(context, route);
    }
  }

  void _handleToolLongPress(Map<String, dynamic> tool) {
    _showToolActions(tool);
  }

  void _showToolActions(Map<String, dynamic> tool) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tool['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildActionTile(
                  icon: tool['isFavorite'] == true ? 'star' : 'star_border',
                  title:
                      tool['isFavorite'] == true
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                  onTap: () {
                    _toggleFavorite(tool);
                    Navigator.pop(context);
                  },
                ),
                _buildActionTile(
                  icon: 'history',
                  title: 'Recent Results',
                  onTap: () {
                    Navigator.pop(context);
                    _showRecentResults(tool);
                  },
                ),
                _buildActionTile(
                  icon: 'share',
                  title: 'Share Tool',
                  onTap: () {
                    Navigator.pop(context);
                    _shareToolInfo(tool);
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  Widget _buildActionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
        size: 6.w,
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _toggleFavorite(Map<String, dynamic> tool) {
    setState(() {
      final index = _allTools.indexWhere((t) => t['id'] == tool['id']);
      if (index != -1) {
        _allTools[index]['isFavorite'] =
            !(tool['isFavorite'] as bool? ?? false);
      }
    });

    final isFavorite =
        _allTools.firstWhere((t) => t['id'] == tool['id'])['isFavorite']
            as bool;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${tool['title']} added to favorites'
              : '${tool['title']} removed from favorites',
        ),
        backgroundColor:
            isFavorite ? AppTheme.successColor : AppTheme.warningColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRecentResults(Map<String, dynamic> tool) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Recent Results'),
            content: Text('No recent results for ${tool['title']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _shareToolInfo(Map<String, dynamic> tool) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${tool['title']}...'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleFilterTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: EdgeInsets.only(bottom: 3.h),
                ),
                Text(
                  'Filter Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Show Tools',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 1.h),
                CheckboxListTile(
                  title: Text('Favorites Only'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: Text('Recently Used'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: Text('Offline Tools'),
                  value: false,
                  onChanged: (value) {},
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  void _handleSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tools',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _handleRefresh,
            icon:
                _isRefreshing
                    ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.grey,
                        ),
                      ),
                    )
                    : CustomIconWidget(
                      iconName: 'refresh',
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey,
                      size: 6.w,
                    ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterTap: _handleFilterTap,
            ),

            // Category Filter
            CategoryFilterWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            // Content
            Expanded(
              child:
                  _searchQuery.isEmpty && _selectedCategory == 'All'
                      ? SingleChildScrollView(
                        child: Column(
                          children: [
                            // Favorites Section
                            FavoritesSectionWidget(
                              favoriteTools: _favoriteTools,
                              onToolTap: _handleToolTap,
                              onToolLongPress: _handleToolLongPress,
                            ),

                            // All Tools Grid
                            Container(
                              height: 60.h,
                              child: ToolsGridWidget(
                                tools: _filteredTools,
                                onToolTap: _handleToolTap,
                                onToolLongPress: _handleToolLongPress,
                              ),
                            ),
                          ],
                        ),
                      )
                      : _filteredTools.isEmpty
                      ? EmptySearchWidget(
                        searchQuery: _searchQuery,
                        suggestions: _searchSuggestions,
                        onSuggestionTap: _handleSuggestionTap,
                      )
                      : ToolsGridWidget(
                        tools: _filteredTools,
                        onToolTap: _handleToolTap,
                        onToolLongPress: _handleToolLongPress,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
