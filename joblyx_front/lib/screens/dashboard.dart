import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:go_router/go_router.dart';

class Dashboard extends StatelessWidget {
  final StatefulNavigationShell shell;
  const Dashboard({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: shell, 
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.bodySmall,
        ),
        elevation: 0,
        height: 70.h,
        selectedIndex: shell.currentIndex, 
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withAlpha(200),
        onDestinationSelected: shell.goBranch, 
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 25.r),
            selectedIcon: Icon(Icons.home, size: 25.r),
            label: t.t('nav.home')
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, size: 25.r),
            selectedIcon: Icon(Icons.analytics, size: 25.r),
            label: t.t('nav.analysis')
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined, size: 25.r),
            selectedIcon: Icon(Icons.description, size: 25.r),
            label: t.t('nav.cv')
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 25.r),
            selectedIcon: Icon(Icons.person, size: 25.r),
            label: t.t('nav.profile')
          ),
        ],
      ),
    );
  }
}
