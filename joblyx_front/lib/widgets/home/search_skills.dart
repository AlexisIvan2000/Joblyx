import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/data/canada_locations.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class SearchSkills extends StatefulWidget {
  const SearchSkills({super.key});

  @override
  State<SearchSkills> createState() => _SearchSkillsState();
}

class _SearchSkillsState extends State<SearchSkills> {
  final _jobController = TextEditingController();
  String? _selectedProvince;
  // ignore: unused_field
  String? _selectedCity;

  @override
  void dispose() {
    _jobController.dispose();
    super.dispose();
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
                onSelected: (value) => setState(() {
                  _selectedProvince = value;
                  _selectedCity = null;
                }),
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
                onSelected: (value) => setState(() => _selectedCity = value),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Utiliser ma localisation
        GestureDetector(
          onTap: () {
            //  Implémenter
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
        SizedBox(height: 16.h),

        // Bouton rechercher
        FilledButton.icon(
          onPressed: () {
            //  Implémenter
          },
          icon: const Icon(Icons.search),
          label: Text(t.t('home.search')),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
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
  }) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return options;
        return options.where(
          (o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
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
