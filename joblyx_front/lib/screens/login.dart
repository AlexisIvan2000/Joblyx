import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/widgets/login_form.dart';
// import 'package:joblyx_front/services/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //  final cs = Theme.of(context).colorScheme;
    //  final t = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 75.r,
                  backgroundImage: const AssetImage('assets/images/logo.png'),
                ),
              ),
              const SizedBox(height: 5),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
