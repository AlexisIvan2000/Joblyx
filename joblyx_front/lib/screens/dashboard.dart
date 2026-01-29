import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:go_router/go_router.dart';

class Dashboard extends StatefulWidget {
  final StatefulNavigationShell shell;
  const Dashboard({super.key, required this.shell});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToIndex(int newIndex) {
    if (_isAnimating) return;

    final goingRight = newIndex > _previousIndex;

    _slideAnimation = Tween<Offset>(
      begin: goingRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    setState(() {
      _isAnimating = true;
      _previousIndex = newIndex;
    });

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _isAnimating = false;
      });
    });

    widget.shell.goBranch(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final currentIndex = widget.shell.currentIndex;

    return Scaffold(
      body: _isAnimating
          ? SlideTransition(
              position: _slideAnimation,
              child: widget.shell,
            )
          : widget.shell,
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.bodySmall,
        ),
        elevation: 0,
        height: 70.h,
        selectedIndex: currentIndex,
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withAlpha(200),
        onDestinationSelected: _animateToIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 25.r),
            selectedIcon: Icon(Icons.home, size: 25.r),
            label: t.t('nav.home')
          ),
          NavigationDestination(
            icon: Icon(Icons.tips_and_updates_outlined, size: 25.r),
            selectedIcon: Icon(Icons.tips_and_updates, size: 25.r),
            label: t.t('nav.advice')
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
