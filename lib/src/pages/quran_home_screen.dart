part of '/quran.dart';

class QuranHomeScreen extends StatelessWidget {
  final bool isDark;
  const QuranHomeScreen({super.key, this.isDark = false});

  static const _emerald = Color(0xFF2D6A4F);
  static const _softGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(isDark);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(size),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildQuranFeaturedCard(context),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          _buildSectionLabel('العبادات والأذكار'),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          _buildSecondaryGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(Size size) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: 330,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          // Decorative dots pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: CustomPaint(painter: _IslamicPatternPainter()),
            ),
          ),
          // Corner ornaments
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/corna_screen.png',
                width: 90,
                package: 'quran_library',
                color: _softGold,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/corna_right.png',
                width: 90,
                package: 'quran_library',
                color: _softGold,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bismillah ornament
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: _softGold.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'uthmanic',
                        fontSize: 16,
                        color: Color(0xFFE8D5A3),
                        package: 'quran_library',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'المكتبة القرآنية',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'cairo',
                      color: Colors.white,
                      letterSpacing: 0.5,
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'زاد المسلم اليومي من القرآن والسنة',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'cairo',
                      color: Colors.white.withValues(alpha: 0.70),
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة الصلاة القادمة داخل الهيدر
                  _PrayerBannerCard(isDark: isDark, insideHeader: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionLabel(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: _emerald, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'cairo',
                color: AppColors.getTextColor(isDark),
                package: 'quran_library',
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuranFeaturedCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranLibraryScreen(
                  parentContext: context,
                  isDark: isDark,
                  topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context)
                      .copyWith(showBackButton: true),
                ),
              ),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              QuranCtrl.instance.isShowControl.value = true;
              QuranCtrl.instance.update(['isShowControl']);
            });
          },
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF1B4332), Color(0xFF40916C)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _emerald.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/images/koran.png',
                      width: 120,
                      package: 'quran_library',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/koran.png',
                        package: 'quran_library',
                        width: 64,
                        height: 64,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'القرآن الكريم',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'cairo',
                                color: Colors.white,
                                package: 'quran_library',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اقرأ وتدبر واستمع',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'cairo',
                                color: Colors.white.withValues(alpha: 0.8),
                                package: 'quran_library',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildSecondaryGrid(BuildContext context) {
    final items = [
      _CardItem(title: 'الأحاديث النبوية', subtitle: 'صحيح البخاري ومسلم', imagePath: 'assets/images/azkar.png', gradient: [const Color(0xFF7B5EA7), const Color(0xFF5E4391)], onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HadithScreen(isDark: isDark)));
      }),
      _CardItem(title: 'الأذكار', subtitle: 'أذكار الصباح والمساء', imagePath: 'assets/images/azkar.png', gradient: [const Color(0xFFE07B39), const Color(0xFFC5602A)], onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DhikrReminderScreen(isDark: isDark)));
      }),
      _CardItem(title: 'الأدعية', subtitle: 'أدعية مأثورة', imagePath: 'assets/images/duaa.png', gradient: [const Color(0xFF2980B9), const Color(0xFF1A6091)], onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DuaaScreen(isDark: isDark)));
      }),
      _CardItem(title: 'مواقيت الصلاة', subtitle: 'توقيت دقيق يومياً', imagePath: 'assets/images/time.png', gradient: [const Color(0xFF1A7A9A), const Color(0xFF125970)], onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PrayerTimesScreen(isDark: isDark)));
      }),
      _CardItem(title: 'اتجاه القبلة', subtitle: 'بوصلة ذكية', imagePath: 'assets/images/gibla.png', gradient: [const Color(0xFF8B6914), const Color(0xFFB8963E)], onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QiblahScreen(isDark: isDark)));
      }),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSecondaryCard(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(_CardItem item) {
    final cardBg = isDark ? const Color(0xFF252525) : Colors.white;
    final textColor = AppColors.getTextColor(isDark);
    final subColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                item.imagePath,
                package: 'quran_library',
                width: 50,
                height: 50,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'cairo',
                      color: textColor,
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'cairo',
                      color: subColor,
                      package: 'quran_library',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _CardItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _CardItem({required this.title, required this.subtitle, required this.imagePath, required this.gradient, required this.onTap});
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// _PrayerBannerCard — بطاقة الصلاة القادمة في الصفحة الرئيسية
// ══════════════════════════════════════════════════════════════════════════════

class _PrayerBannerCard extends StatefulWidget {
  final bool isDark;
  final bool insideHeader;
  const _PrayerBannerCard({required this.isDark, this.insideHeader = false});

  @override
  State<_PrayerBannerCard> createState() => _PrayerBannerCardState();
}

class _PrayerBannerCardState extends State<_PrayerBannerCard> {
  static const _emerald = Color(0xFF2D6A4F);

  static const _prayers = [
    {'name': 'الفجر',  'emoji': '🌙'},
    {'name': 'الشروق', 'emoji': '🌅'},
    {'name': 'الظهر',  'emoji': '☀️'},
    {'name': 'العصر',  'emoji': '🌤'},
    {'name': 'المغرب', 'emoji': '🌆'},
    {'name': 'العشاء', 'emoji': '🌃'},
  ];

  bool _loading = true;
  String _city = '';
  String _nextPrayerName = '';
  String _nextPrayerEmoji = '';
  String _nextPrayerTime = '';
  String _remaining = '';
  String _remainingHours = '';
  double _arcProgress = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      // جلب أوقات الصلاة واسم المدينة بطلب واحد
      final dio = Dio();
      final results = await Future.wait([
        dio.get('https://api.aladhan.com/v1/timings', queryParameters: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'method': 4,
        }),
        dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'lat': pos.latitude,
            'lon': pos.longitude,
            'format': 'json',
          },
          options: Options(headers: {'User-Agent': 'quran_library_app'}),
        ),
      ]);

      final timings = results[0].data['data']['timings'] as Map<String, dynamic>;
      final address = results[1].data['address'] as Map<String, dynamic>?;
      final city = address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String? ??
          address?['state'] as String? ??
          '';

      final now = DateTime.now();
      final nowStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final orderedKeys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      final orderedNames = _prayers;

      String nextName = '', nextEmoji = '', nextTime = '';
      for (int i = 0; i < orderedKeys.length; i++) {
        final raw = (timings[orderedKeys[i]] as String).split(' ').first;
        if (raw.compareTo(nowStr) > 0) {
          nextName  = orderedNames[i]['name']!;
          nextEmoji = orderedNames[i]['emoji']!;
          nextTime  = raw;
          break;
        }
      }
      if (nextName.isEmpty) {
        nextName  = orderedNames[0]['name']!;
        nextEmoji = orderedNames[0]['emoji']!;
        nextTime  = (timings['Fajr'] as String).split(' ').first;
      }

      if (!mounted) return;
      setState(() {
        _city = city;
        _nextPrayerName  = nextName;
        _nextPrayerEmoji = nextEmoji;
        _nextPrayerTime  = nextTime;
        _loading = false;
      });
      _updateRemaining();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateRemaining() {
    if (_nextPrayerTime.isEmpty) return;
    final parts = _nextPrayerTime.split(':');
    final pHour = int.tryParse(parts[0]) ?? 0;
    final pMin  = int.tryParse(parts[1]) ?? 0;
    final now   = DateTime.now();
    var pDt = DateTime(now.year, now.month, now.day, pHour, pMin);
    if (pDt.isBefore(now)) pDt = pDt.add(const Duration(days: 1));
    final diff = pDt.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    final label = h > 0 ? '${h}س ${m}د ${s}ث' : '${m}د ${s}ث';
    final short = h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final totalSecs = diff.inSeconds.clamp(0, 21600);
    final arc = 1.0 - (totalSecs / 21600.0);
    if (mounted) setState(() {
      _remaining = label;
      _remainingHours = short;
      _arcProgress = arc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? const Color(0xFF1E3A2F) : const Color(0xFFEDF7F2);

    if (_loading) {
      return Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: widget.insideHeader ? 0.1 : 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38)),
        ),
      );
    }

    if (_nextPrayerName.isEmpty) return const SizedBox.shrink();

    final BoxDecoration decoration = widget.insideHeader
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF0A3D2E)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A3D2E).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PrayerTimesScreen(isDark: widget.isDark)),
      ),
      child: Container(
        decoration: decoration,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── يسار: اسم الصلاة والمدينة ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_nextPrayerEmoji  الصلاة القادمة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'cairo', fontSize: 11,
                          color: Colors.white38,
                          package: 'quran_library',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _nextPrayerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'cairo', fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          package: 'quran_library',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _city.isNotEmpty ? '📍 $_city' : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'cairo', fontSize: 11,
                          color: Colors.white38,
                          package: 'quran_library',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── يمين: القوس الدائري مع العداد ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(82, 82),
                        painter: _ArcProgressPainter(progress: _arcProgress),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _remainingHours,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'cairo',
                              package: 'quran_library',
                            ),
                          ),
                          Text(
                            _nextPrayerTime,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white38,
                              fontFamily: 'cairo',
                              package: 'quran_library',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  const _ArcProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 6;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // خط الخلفية
    canvas.drawArc(
      rect,
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // القوس الملون
    canvas.drawArc(
      rect,
      -math.pi * 0.75,
      math.pi * 1.5 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF40916C), Color(0xFFD4AF37)],
        ).createShader(rect)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcProgressPainter old) => old.progress != progress;
}
