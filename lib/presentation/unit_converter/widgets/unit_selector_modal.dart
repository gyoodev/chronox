import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UnitSelectorModal extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> units;
  final String selectedUnit;
  final ValueChanged<String> onUnitSelected;

  const UnitSelectorModal({
    super.key,
    required this.category,
    required this.units,
    required this.selectedUnit,
    required this.onUnitSelected,
  });

  @override
  State<UnitSelectorModal> createState() => _UnitSelectorModalState();
}

class _UnitSelectorModalState extends State<UnitSelectorModal> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredUnits = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredUnits = widget.units;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUnits(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUnits = widget.units;
      } else {
        _filteredUnits =
            widget.units.where((unit) {
              final name = (unit['name'] as String).toLowerCase();
              final symbol = (unit['symbol'] as String).toLowerCase();
              final searchQuery = query.toLowerCase();
              return name.contains(searchQuery) || symbol.contains(searchQuery);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select ${widget.category} Unit',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search units...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _filterUnits,
            ),
          ),

          SizedBox(height: 2.h),

          // Units list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _filteredUnits.length,
              separatorBuilder:
                  (context, index) => Divider(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.1,
                    ),
                    height: 1,
                  ),
              itemBuilder: (context, index) {
                final unit = _filteredUnits[index];
                final isSelected = unit['name'] == widget.selectedUnit;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  title: Text(
                    unit['name'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    unit['symbol'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  trailing:
                      isSelected
                          ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          )
                          : null,
                  onTap: () {
                    widget.onUnitSelected(unit['name'] as String);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
