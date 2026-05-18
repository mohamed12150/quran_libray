part of '/quran.dart';

class QuranSplashScreen extends StatefulWidget {
  final bool isDark;
  const QuranSplashScreen({super.key, this.isDark = false});

  @override
  State<QuranSplashScreen> createState() => _QuranSplashScreenState();
}

class _QuranSplashScreenState extends State<QuranSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      Permission.notification.request(),
      DhikrReminderService.instance.rescheduleIfEnabled(),
    ]);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuranHomeScreen(isDark: widget.isDark),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(widget.isDark),
      body: Center(
        child: Lottie.asset(
          'assets/images/splash.json',
          package: 'quran_library',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
