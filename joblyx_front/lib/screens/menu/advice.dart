import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(t.t('advice.title'), style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        )),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.t('advice.description'),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15.h),
            TextField(
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 20,
              decoration: InputDecoration(
                hintText: t.t('advice.paste'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: cs.onSurface),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42.h,
                    child: OutlinedButton(
                      onPressed: () {}, 
                      child: Text(t.t('advice.choose_cv')),
                    ),
                  )
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 42.h,
                    child: OutlinedButton(
                      onPressed: () {}, 
                      child: Text(t.t('advice.upload_cv')),
                    ),
                  )
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: FilledButton(
                onPressed: () {}, 
                child: Text(t.t('advice.submit'))
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              t.t('advice.disclaimer'),
              style: theme.textTheme.bodySmall!.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),


          ],
        ),
      ),
    );
  }
}
