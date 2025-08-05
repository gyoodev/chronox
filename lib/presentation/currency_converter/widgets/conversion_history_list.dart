import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConversionHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> historyList;
  final Function(int) onDelete;
  final Function(String) onCopy;

  const ConversionHistoryList({
    Key? key,
    required this.historyList,
    required this.onDelete,
    required this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (historyList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.5),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No conversion history yet',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your recent conversions will appear here',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Text(
            'Recent Conversions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyList.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final history = historyList[index];
            return Dismissible(
              key: Key('history_${history['id']}'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 4.w),
                child: CustomIconWidget(
                  iconName: 'delete',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onDismissed: (direction) => onDelete(index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.1,
                    ),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    final conversionText =
                        '${history['fromSymbol']}${history['fromAmount']} = ${history['toSymbol']}${history['toAmount']}';
                    Clipboard.setData(ClipboardData(text: conversionText));
                    onCopy(conversionText);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // From currency
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CustomImageWidget(
                                      imageUrl: history['fromFlag'] as String,
                                      width: 8.w,
                                      height: 8.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${history['fromSymbol']}${history['fromAmount']}',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        history['fromCode'] as String,
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                          ),

                          // To currency
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CustomImageWidget(
                                      imageUrl: history['toFlag'] as String,
                                      width: 8.w,
                                      height: 8.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${history['toSymbol']}${history['toAmount']}',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .primary,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        history['toCode'] as String,
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rate: ${history['rate']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                          Text(
                            history['timestamp'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
