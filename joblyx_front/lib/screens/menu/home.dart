import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/providers/location_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/profile_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: const Center(child: Text('Home Screen')),
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
