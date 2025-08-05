import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const EmptySearchWidget({
    Key? key,
    required this.searchQuery,
    required this.suggestions,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4) ??
                Colors.grey,
            size: 15.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No tools found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
          Text(
            searchQuery.isNotEmpty
                ? 'No results for "$searchQuery"'
                : 'Try searching for a specific tool or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (suggestions.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              'Try these suggestions:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children:
                  suggestions.map((suggestion) {
                    return GestureDetector(
                      onTap: () => onSuggestionTap(suggestion),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.lightTheme.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
