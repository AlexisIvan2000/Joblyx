import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/models/market_analysis_model.dart';
import 'package:joblyx_front/models/search_history_model.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/providers/location_provider.dart';
import 'package:joblyx_front/providers/market_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/home/search_history.dart';
import 'package:joblyx_front/widgets/home/search_skills.dart';
import 'package:joblyx_front/widgets/profile_avatar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchSkillsKey = GlobalKey<SearchSkillsState>();

  void _onHistoryTap(SearchHistoryItem item) {
    // Si on a les résultats, les afficher directement
    if (item.results != null) {
      final result = MarketAnalysisResult.fromMap(item.results!);
      _showResultsBottomSheet(result);
    }
  }

  void _showResultsBottomSheet(MarketAnalysisResult result) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: cs.outline.withAlpha(77),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('analysis.results_title'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${result.query} - ${result.location}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${result.totalJobsAnalyzed} ${t.t('analysis.jobs_analyzed')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: cs.outline.withAlpha(51)),
            // Skills list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                children: _buildSkillsList(result.topSkills, theme, cs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkillsList(List<SkillInfo> skills, ThemeData theme, ColorScheme cs) {
    // Group skills by category
    final Map<String, List<SkillInfo>> grouped = {};
    for (final skill in skills) {
      grouped.putIfAbsent(skill.category, () => []).add(skill);
    }

    final widgets = <Widget>[];
    int globalRank = 1;

    for (final entry in grouped.entries) {
      // Category header
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
          child: Text(
            _formatCategory(entry.key),
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Skills in category
      for (final skill in entry.value) {
        widgets.add(_buildSkillTile(skill, globalRank, theme, cs));
        globalRank++;
      }
    }

    return widgets;
  }

  String _formatCategory(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  Widget _buildSkillTile(SkillInfo skill, int rank, ThemeData theme, ColorScheme cs) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Skill info
          Expanded(
            child: Text(
              skill.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${skill.percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${skill.count} jobs',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final userDataAsync = ref.watch(userHomeDataProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: userDataAsync.when(
          loading: () => SizedBox(
            height: 24.h,
            width: 24.w,
            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          ),
          error: (_, __) => Text(t.t('err.error')),
          data: (userData) {
            if (userData.firstName == null) {
              return Text(t.t('home.welcome'));
            }
            return _WelcomeHeader(
              firstName: userData.firstName!,
              profilePicture: userData.profilePicture,
              welcomeText: t.t('home.welcome'),
              location: location,
              textTheme: textTheme,
              colorScheme: cs,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.t('home.search_skills'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _QuotaIndicator(),
              ],
            ),
            SizedBox(height: 10.h),
            SearchSkills(key: _searchSkillsKey),
            SizedBox(height: 25.h),
            Text(
              t.t('home.history'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            SearchHistory(onHistoryTap: _onHistoryTap),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _QuotaIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final quotaAsync = ref.watch(quotaProvider);

    return quotaAsync.when(
      data: (quota) {
        if (quota == null) return const SizedBox.shrink();

        final remaining = quota['searches_remaining'] ?? 0;
        final max = quota['max_searches'] ?? 5;

        // Si unlimited (premium)
        if (max == -1) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.all_inclusive, size: 14.sp, color: cs.primary),
                SizedBox(width: 4.w),
                Text(
                  t.t('quota.unlimited'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final isLow = remaining <= 1;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isLow ? cs.errorContainer : cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 14.sp,
                color: isLow ? cs.error : cs.secondary,
              ),
              SizedBox(width: 4.w),
              Text(
                '$remaining/$max',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLow ? cs.error : cs.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        width: 16.w,
        height: 16.w,
        child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String firstName;
  final String? profilePicture;
  final String welcomeText;
  final String? location;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _WelcomeHeader({
    required this.firstName,
    required this.profilePicture,
    required this.welcomeText,
    required this.location,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          imageUrl: profilePicture,
          radius: 24.r,
          backgroundColor: colorScheme.surface,
        ),
        SizedBox(width: 12.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$welcomeText $firstName',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (location != null) ...[
              SizedBox(height: 3.h),
              Text(
                location!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
