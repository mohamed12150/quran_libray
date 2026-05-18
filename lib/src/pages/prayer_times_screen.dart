part of '/quran.dart';

class PrayerTimesScreen extends StatefulWidget {
  final bool isDark;
  const PrayerTimesScreen({super.key, this.isDark = false});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static const _emerald = Color(0xFF2D6A4F);
  static const _softGold = Color(0xFFD4AF37);

  bool _loading = true;
  String? _error;
  PrayerTimes? _prayerTimes;
  String _locationLabel = '';
  bool _azanEnabled = false;
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    AzanService.instance.initialize();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _error = 'تم رفض إذن الموقع بشكل دائم، يرجى تفعيله من الإعدادات';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final dio = Dio();
      final response = await dio.get(
        'https://api.aladhan.com/v1/timings',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'method': 4,
        },
      );

      final pt = PrayerTimes.fromJson(response.data);
      final label = '${position.latitude.toStringAsFixed(2)}° ، ${position.longitude.toStringAsFixed(2)}°';

      if (!mounted) return;
      setState(() {
        _prayerTimes = pt;
        _locationLabel = label;
        _loading = false;
      });
    } catch (e, s) {
      log('PrayerTimes error: $e', name: 'PrayerTimesScreen', stackTrace: s);
      if (!mounted) return;
      setState(() {
        _error = 'تعذّر جلب مواقيت الصلاة\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(widget.isDark),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 210,
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
          ),
          Positioned(
            top: 0, left: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/corna_screen.png', width: 80,
                  package: 'quran_library', color: _softGold),
            ),
          ),
          Positioned(
            top: 0, right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/corna_right.png', width: 80,
                  package: 'quran_library', color: _softGold),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: _emerald))
                      : _error != null
                          ? _buildError()
                          : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAzan() async {
    if (_prayerTimes == null) return;

    if (_azanEnabled) {
      await AzanService.instance.cancelAll();
      setState(() => _azanEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف الأذان', style: TextStyle(fontFamily: 'cairo', package: 'quran_library')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final granted = await AzanService.instance.requestPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى السماح بالإشعارات لتفعيل الأذان', style: TextStyle(fontFamily: 'cairo', package: 'quran_library')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final pt = _prayerTimes!;
    await AzanService.instance.schedulePrayerAlarms({
      'الفجر': pt.fajr,
      'الشروق': pt.sunrise,
      'الظهر': pt.dhuhr,
      'العصر': pt.asr,
      'المغرب': pt.maghrib,
      'العشاء': pt.isha,
    });

    setState(() => _azanEnabled = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل الأذان لجميع الصلوات ✓', style: TextStyle(fontFamily: 'cairo', package: 'quran_library')),
          backgroundColor: Color(0xFF2D6A4F),
        ),
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Spacer(),
          const Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              fontFamily: 'cairo', color: Colors.white,
              package: 'quran_library',
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadPrayerTimes,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final pt = _prayerTimes!;
    final cardBg = widget.isDark ? const Color(0xFF252525) : Colors.white;
    final textColor = AppColors.getTextColor(widget.isDark);

    final prayers = [
      _PrayerItem(name: 'الفجر',   time: pt.fajr,    emoji: '🌙', color: const Color(0xFF3D5A80)),
      _PrayerItem(name: 'الشروق',  time: pt.sunrise, emoji: '🌅', color: const Color(0xFFE07B39)),
      _PrayerItem(name: 'الظهر',   time: pt.dhuhr,   emoji: '☀️', color: const Color(0xFFB8963E)),
      _PrayerItem(name: 'العصر',   time: pt.asr,     emoji: '🌤', color: const Color(0xFF2D6A4F)),
      _PrayerItem(name: 'المغرب',  time: pt.maghrib, emoji: '🌆', color: const Color(0xFFC0392B)),
      _PrayerItem(name: 'العشاء',  time: pt.isha,    emoji: '🌃', color: const Color(0xFF2C3E6B)),
    ];

    final nextPrayer = _getNextPrayer(prayers);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        children: [
          _buildDateCard(cardBg, textColor),
          const SizedBox(height: 16),
          if (nextPrayer != null) ...[
            _buildNextPrayerCard(nextPrayer),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(prayers.length, (i) {
                return _buildPrayerRow(
                  prayers[i],
                  isNext: nextPrayer?.name == prayers[i].name,
                  isLast: i == prayers.length - 1,
                  textColor: textColor,
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _buildAzanCard(cardBg, textColor),
          const SizedBox(height: 12),
          Text(
            'طريقة الحساب: أم القرى — مكة المكرمة',
            style: TextStyle(
              fontFamily: 'cairo', fontSize: 12,
              color: textColor.withValues(alpha: 0.4),
              package: 'quran_library',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(Color cardBg, Color textColor) {
    final weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final dayName = weekdays[_now.weekday - 1];
    final monthName = months[_now.month - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: _emerald, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _locationLabel,
              style: TextStyle(
                fontFamily: 'cairo', fontSize: 13,
                color: textColor.withValues(alpha: 0.55),
                package: 'quran_library',
              ),
            ),
          ),
          Text(
            '$dayName ${_now.day} $monthName ${_now.year}',
            style: const TextStyle(
              fontFamily: 'cairo', fontSize: 13,
              fontWeight: FontWeight.w600, color: _emerald,
              package: 'quran_library',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(_PrayerItem prayer) {
    final remaining = _timeRemaining(prayer.time);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [prayer.color, prayer.color.withValues(alpha: 0.75)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: prayer.color.withValues(alpha: 0.35),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(prayer.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الصلاة القادمة',
                    style: TextStyle(fontFamily: 'cairo', fontSize: 13, color: Colors.white70, package: 'quran_library')),
                const SizedBox(height: 2),
                Text(prayer.name,
                    style: const TextStyle(fontFamily: 'cairo', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, package: 'quran_library')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(prayer.time,
                  style: const TextStyle(fontFamily: 'cairo', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, package: 'quran_library')),
              const SizedBox(height: 2),
              Text('بعد $remaining',
                  style: const TextStyle(fontFamily: 'cairo', fontSize: 13, color: Colors.white70, package: 'quran_library')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(_PrayerItem p, {required bool isNext, required bool isLast, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext ? p.color.withValues(alpha: 0.07) : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        border: isLast ? null : Border(bottom: BorderSide(color: textColor.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              p.name,
              style: TextStyle(
                fontFamily: 'cairo', fontSize: 16,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                color: isNext ? p.color : textColor,
                package: 'quran_library',
              ),
            ),
          ),
          if (isNext)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('التالية',
                  style: TextStyle(fontFamily: 'cairo', fontSize: 11, color: p.color, fontWeight: FontWeight.w700, package: 'quran_library')),
            ),
          Text(
            p.time,
            style: TextStyle(
              fontFamily: 'cairo', fontSize: 16, fontWeight: FontWeight.w700,
              color: isNext ? p.color : textColor,
              package: 'quran_library',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzanCard(Color cardBg, Color textColor) {
    return GestureDetector(
      onTap: _toggleAzan,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _azanEnabled ? _emerald.withValues(alpha: 0.4) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (_azanEnabled ? _emerald : Colors.grey).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: _azanEnabled ? _emerald : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيه الأذان',
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _azanEnabled ? 'مفعّل لجميع الصلوات' : 'اضغط لتفعيل الأذان',
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 12,
                      color: _azanEnabled ? _emerald : textColor.withValues(alpha: 0.45),
                      package: 'quran_library',
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _azanEnabled,
              onChanged: (_) => _toggleAzan(),
              activeThumbColor: _emerald,
              activeTrackColor: _emerald.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    final textColor = AppColors.getTextColor(widget.isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: _emerald.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.location_off_rounded, size: 44, color: _emerald),
            ),
            const SizedBox(height: 20),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'cairo', fontSize: 16, color: textColor, height: 1.6, package: 'quran_library')),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadPrayerTimes,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة',
                  style: TextStyle(fontFamily: 'cairo', fontSize: 15, package: 'quran_library')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns next prayer or null if all passed today
  _PrayerItem? _getNextPrayer(List<_PrayerItem> prayers) {
    final nowStr = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    for (final p in prayers) {
      // Strip timezone suffix if present e.g. "05:23 (EET)"
      final clean = p.time.split(' ').first;
      if (clean.compareTo(nowStr) > 0) return p;
    }
    return prayers.first;
  }

  String _timeRemaining(String prayerTime) {
    final clean = prayerTime.split(' ').first;
    final parts = clean.split(':');
    if (parts.length < 2) return '';
    final pHour = int.tryParse(parts[0]) ?? 0;
    final pMin = int.tryParse(parts[1]) ?? 0;
    var pDt = DateTime(_now.year, _now.month, _now.day, pHour, pMin);
    if (pDt.isBefore(_now)) pDt = pDt.add(const Duration(days: 1));
    final diff = pDt.difference(_now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return h > 0 ? '${h}س $mد' : '$mد';
  }
}

class _PrayerItem {
  final String name;
  final String time;
  final String emoji;
  final Color color;
  const _PrayerItem({required this.name, required this.time, required this.emoji, required this.color});
}
