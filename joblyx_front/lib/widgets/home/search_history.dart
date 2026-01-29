import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class SearchHistory extends StatefulWidget {
  const SearchHistory({super.key});

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  final List<String> _history = [
    'Software Engineer',
    'Data Scientist',
    'Product Manager',
    'UX Designer',
    'DevOps Engineer',
  ];

  @override
  Widget build(BuildContext context) {
    // final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _history.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              item,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }).toList(),
    );
  }
}