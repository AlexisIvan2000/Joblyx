import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/data/canada_locations.dart';
import 'package:joblyx_front/models/market_analysis_model.dart';
import 'package:joblyx_front/providers/history_provider.dart';
import 'package:joblyx_front/providers/market_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/market/market_exception.dart';

class SearchSkills extends ConsumerStatefulWidget {
  const SearchSkills({super.key});

  @override
  ConsumerState<SearchSkills> createState() => SearchSkillsState();
}

class SearchSkillsState extends ConsumerState<SearchSkills> {
  final _jobController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedProvince;

  /// Remplit les champs avec les valeurs de l'historique
  void fillFields({required String job, required String city, required String province}) {
    _jobController.text = job;
    _provinceController.text = province;
    _cityController.text = city;
    setState(() {
      _selectedProvince = province;
    });
  }

  @override
  void dispose() {
    _jobController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _onSearch() async {
    final job = _jobController.text.trim();
    final province = _provinceController.text.trim();
    final city = _cityController.text.trim();

    if (job.isEmpty || province.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('home.fill_all_fields')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(marketAnalysisProvider.notifier)
          .analyze(job: job, city: city, province: province);

      if (!mounted) return;

      final state = ref.read(marketAnalysisProvider);
      state.when(
        data: (result) {
          if (result != null) {
            // Rafraîchir l'historique et le quota après une recherche réussie
            ref.read(historyProvider.notifier).refresh();
            ref.read(quotaProvider.notifier).refresh();
            _showResultsBottomSheet(result);
          }
        },
        loading: () {},
        error: (error, __) {
          String errorKey = 'err.network_error';
          if (error is MarketFailure) {
            if (error.code == 'quota_exceeded') {
              errorKey = 'err.quota_exceeded';
            } else if (error.code == 'api_error') {
              errorKey = 'err.api_error';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).t(errorKey),
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                color: cs.outline.withValues(alpha: 0.3),
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
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
            // Skills list grouped by category
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                children: _buildSkillsByCategory(result.topSkills),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkillsByCategory(List<SkillInfo> skills) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
        widgets.add(_buildSkillTile(skill, globalRank));
        globalRank++;
      }
    }

    return widgets;
  }

  String _formatCategory(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Widget _buildSkillTile(SkillInfo skill, int rank) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Champ titre du job
        TextField(
          controller: _jobController,
          decoration: InputDecoration(
            hintText: t.t('home.enter_job'),
            prefixIcon: const Icon(Icons.work_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Province et Ville
        Row(
          children: [
            // Province
            Expanded(
              child: _buildAutocomplete(
                hint: t.t('home.province'),
                icon: Icons.map_outlined,
                options: canadaProvinces,
                controller: _provinceController,
                onSelected: (value) {
                  _provinceController.text = value;
                  setState(() {
                    _selectedProvince = value;
                  });
                  _cityController.clear();
                },
              ),
            ),
            SizedBox(width: 10.w),

            // Ville (key force rebuild quand province change)
            Expanded(
              key: ValueKey(_selectedProvince),
              child: _buildAutocomplete(
                hint: t.t('home.city'),
                icon: Icons.location_city,
                options: getCitiesForProvince(_selectedProvince),
                controller: _cityController,
                onSelected: (value) {
                  _cityController.text = value;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Utiliser ma localisation
        GestureDetector(
          onTap: () {
            //  Implémenter
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.my_location, color: cs.primary, size: 18.sp),
              SizedBox(width: 4.w),
              Text(
                t.t('home.use_location'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Bouton rechercher
        FilledButton.icon(
          onPressed: _isLoading ? null : _onSearch,
          icon: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : const Icon(Icons.search),
          label: Text(_isLoading ? t.t('home.searching') : t.t('home.search')),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
        SizedBox(height: 12.h),

        // Disclaimer
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 14.sp, color: cs.outline),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                t.t('home.disclaimer'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.outline,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutocomplete({
    required String hint,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String> onSelected,
    TextEditingController? controller,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return options;
        return options.where(
          (o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        // Sync external controller with autocomplete's internal controller
        if (controller != null &&
            controller.text.isNotEmpty &&
            textController.text.isEmpty) {
          textController.text = controller.text;
        }
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, opts) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.h),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opts.length,
                itemBuilder: (context, index) {
                  final option = opts.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
