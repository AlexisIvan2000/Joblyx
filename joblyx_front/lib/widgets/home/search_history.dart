import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/models/search_history_model.dart';
import 'package:joblyx_front/providers/history_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class SearchHistory extends ConsumerWidget {
  final Function(SearchHistoryItem item)? onHistoryTap;

  const SearchHistory({super.key, this.onHistoryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final historyAsync = ref.watch(historyProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                t.t('history.empty'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.outline,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec boutons refresh et clear all
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.t('history.recent_searches'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Bouton clear all
                    IconButton(
                      onPressed: () => _showClearAllDialog(context, ref),
                      icon: Icon(Icons.delete_sweep, size: 20.sp),
                      visualDensity: VisualDensity.compact,
                      tooltip: t.t('history.clear_all'),
                    ),
                    // Bouton refresh
                    IconButton(
                      onPressed: () {
                        ref.read(historyProvider.notifier).refresh();
                      },
                      icon: Icon(Icons.refresh, size: 20.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Liste des recherches
            ...history.take(5).map((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _showDeleteConfirmDialog(context),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.w),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: cs.onError,
                    ),
                  ),
                  onDismissed: (_) {
                    ref.read(historyProvider.notifier).deleteSearch(item.id);
                  },
                  child: InkWell(
                    onTap: () {
                      onHistoryTap?.call(item);
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withAlpha(60),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.query,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.location,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.totalJobs} jobs',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDate(context, item.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.outline,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.chevron_right,
                            size: 20.sp,
                            color: cs.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            t.t('err.network_error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.error,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('history.delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.t('settings.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.t('settings.confirm')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('history.clear_all')),
        content: Text(t.t('history.clear_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('settings.cancel')),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: Text(
              t.t('settings.confirm'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return t.t('history.today');
    } else if (diff.inDays == 1) {
      return t.t('history.yesterday');
    } else if (diff.inDays < 7) {
      return t.t('history.days_ago').replaceAll('{days}', '${diff.inDays}');
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
