import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/widgets/screen_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late AppLocalizations t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context);
  }

  void _next() {
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pages = [
      _OnboardingPageData(
        title: 'Joblyx',
        description: t.t('intro.first_introduction'),
        image: 'assets/images/rocket.png',
      ),
      _OnboardingPageData(
        title: null,
        description: t.t('intro.second_introduction'),
        image: 'assets/images/location.png',
      ),
      _OnboardingPageData(
        title: null,
        description: t.t('intro.third_introduction'),
        image: 'assets/images/document.png',
      ),
      _OnboardingPageData(
        title: null,
        description: t.t('intro.fourth_introduction'),
        image: 'assets/images/discuss.png',
        isLast: true,
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  t.t('intro.skip'),
                  style: TextStyle(color: cs.primary, fontSize: 16.sp),
                ),
              ),
            ),

           
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) =>
                    _OnboardingPage(data: pages[i]),
              ),
            ),

            
            Padding(
              padding:  EdgeInsets.symmetric(vertical: 16.h),
              child: ScreenIndicator(
                currentPage: _currentPage,
                pageCount: pages.length,
              ),
            ),

           
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == pages.length - 1
                        ? t.t('intro.get_started')
                        : t.t('intro.next'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String? title;
  final String description;
  final String? image;
  final bool isLast;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
    this.isLast = false,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding:  EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.image != null)
            Image.asset(
              data.image!,
              height: MediaQuery.of(context).size.height * 0.30,
            ),

          if (data.image != null)  SizedBox(height: 24.h),

          if (data.title != null)
            Text(
              data.title!,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    
                  ),
            ),
           SizedBox(height: 16.h),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4.h,
                  fontSize: 18.sp,
                  
                ),
          ),
        ],
      ),
    );
  }
}
