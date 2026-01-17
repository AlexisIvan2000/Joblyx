import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/services/app_localizations.dart';
// import 'package:go_router/go_router.dart';
import 'package:joblyx_front/widgets/profil/get_picture.dart';
import 'package:joblyx_front/widgets/profil/personal_details.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.t('profil.your_profile'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                context.push('/settings');
              }, 
              icon: Icon(Icons.settings, size: 25.r),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            const GetPicture(),
            const SizedBox(height: 10),
            const PersonalDetails(),
          ],
        ),
      ),
    );
  }
}
