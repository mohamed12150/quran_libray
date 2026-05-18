part of '../../quran.dart';

class QiblahScreen extends StatefulWidget {
  final bool isDark;
  const QiblahScreen({super.key, this.isDark = false});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();
  bool? hasSensorSupport;

  static const _emerald = Color(0xFF2D6A4F);
  static const _softGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _checkSensorSupport();
    _checkLocationStatus();
  }

  Future<void> _checkSensorSupport() async {
    if (Platform.isAndroid) {
      final support = await FlutterQiblah.androidDeviceSensorSupport();
      if (mounted) setState(() => hasSensorSupport = support);
    } else {
      setState(() => hasSensorSupport = true);
    }
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    log('Checking location status...', name: 'QiblahScreen');
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final locationStatus = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(locationStatus);
    } catch (e, s) {
      log('Error checking location status: $e', name: 'QiblahScreen', stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(widget.isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Header gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
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
          // Corner ornaments
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/corna_screen.png', width: 80, package: 'quran_library', color: _softGold),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/corna_right.png', width: 80, package: 'quran_library', color: _softGold),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: hasSensorSupport == false
                      ? _buildErrorState(
                          context,
                          icon: Icons.sensors_off_rounded,
                          message: 'جهازك لا يدعم مستشعر البوصلة المطلوب لتحديد اتجاه القبلة',
                          buttonLabel: 'العودة',
                          onPressed: () => Navigator.pop(context),
                        )
                      : StreamBuilder<LocationStatus>(
                          stream: _locationStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoading();
                            }
                            if (snapshot.hasData && snapshot.data!.enabled) {
                              switch (snapshot.data!.status) {
                                case LocationPermission.always:
                                case LocationPermission.whileInUse:
                                  return QiblahCompassWidget(isDark: widget.isDark);
                                case LocationPermission.denied:
                                  return _buildErrorState(
                                    context,
                                    icon: Icons.location_off_rounded,
                                    message: 'تم رفض إذن الموقع، يرجى السماح بالوصول',
                                    buttonLabel: 'إعادة المحاولة',
                                    onPressed: _checkLocationStatus,
                                  );
                                case LocationPermission.deniedForever:
                                  return _buildErrorState(
                                    context,
                                    icon: Icons.location_disabled_rounded,
                                    message: 'تم رفض الإذن بشكل دائم، يرجى تفعيله من إعدادات الجهاز',
                                    buttonLabel: null,
                                    onPressed: null,
                                  );
                                default:
                                  return const SizedBox();
                              }
                            }
                            return _buildErrorState(
                              context,
                              icon: Icons.location_searching_rounded,
                              message: 'يرجى تفعيل خدمات الموقع للحصول على اتجاه القبلة',
                              buttonLabel: 'إعادة المحاولة',
                              onPressed: _checkLocationStatus,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            'اتجاه القبلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'cairo',
              color: Colors.white,
              package: 'quran_library',
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: _emerald),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String? buttonLabel,
    required VoidCallback? onPressed,
  }) {
    final textColor = AppColors.getTextColor(widget.isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: _emerald),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'cairo', fontSize: 16, color: textColor, height: 1.6, package: 'quran_library'),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(buttonLabel, style: const TextStyle(fontFamily: 'cairo', fontSize: 15, package: 'quran_library')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QiblahCompassWidget extends StatelessWidget {
  final bool isDark;
  const QiblahCompassWidget({super.key, required this.isDark});

  static const _emerald = Color(0xFF2D6A4F);
  static const _gold = Color(0xFFB8963E);
  static const _softGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(isDark);
    final cardBg = isDark ? const Color(0xFF252525) : Colors.white;

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("خطأ: ${snapshot.error}", style: TextStyle(fontFamily: 'cairo', color: textColor)));
        }
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _emerald));
        }

        final qd = snapshot.data!;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              children: [
                // Info card (degree + direction label)
                _buildInfoCard(qd, textColor, cardBg),
                const SizedBox(height: 28),
                // Compass
                _buildCompass(qd),
                const SizedBox(height: 28),
                // Hint
                _buildHint(cardBg, textColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(QiblahDirection qd, Color textColor, Color cardBg) {
    final deg = qd.direction.toStringAsFixed(1);
    final qiblahDeg = qd.qiblah.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoTile(
              label: 'الاتجاه الحالي',
              value: '$deg°',
              icon: Icons.explore_outlined,
              color: _emerald,
              textColor: textColor,
            ),
          ),
          Container(width: 1, height: 50, color: isDark ? Colors.white12 : Colors.black12),
          Expanded(
            child: _infoTile(
              label: 'اتجاه القبلة',
              value: '$qiblahDeg°',
              icon: Icons.mosque_rounded,
              color: _gold,
              textColor: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String label, required String value, required IconData icon, required Color color, required Color textColor}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, fontFamily: 'cairo', package: 'quran_library'),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, fontFamily: 'cairo', color: textColor.withValues(alpha: 0.55), package: 'quran_library')),
      ],
    );
  }

  Widget _buildCompass(QiblahDirection qd) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost subtle glow ring
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _emerald.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Outer ring
          Container(
            width: 284,
            height: 284,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _emerald.withValues(alpha: 0.15), width: 1.5),
            ),
          ),
          // Compass plate (rotates with phone)
          Transform.rotate(
            angle: qd.direction * (math.pi / 180) * -1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass dial
                Container(
                  width: 264,
                  height: 264,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isDark
                          ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
                          : [const Color(0xFFFDFCFA), const Color(0xFFF0EDE6)],
                    ),
                    border: Border.all(color: _emerald.withValues(alpha: 0.25), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Tick marks
                CustomPaint(
                  size: const Size(264, 264),
                  painter: _CompassDialPainter(isDark: isDark),
                ),
                // Cardinal letters
                ...[
                  _dirLabel('ش', 0.0, Colors.red.shade600),
                  _dirLabel('ق', 90.0, isDark ? Colors.white60 : Colors.black54),
                  _dirLabel('ج', 180.0, isDark ? Colors.white60 : Colors.black54),
                  _dirLabel('غ', 270.0, isDark ? Colors.white60 : Colors.black54),
                ],
              ],
            ),
          ),
          // Qiblah needle (static in screen space, rotates to qiblah)
          Transform.rotate(
            angle: qd.qiblah * (math.pi / 180) * -1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Needle line
                Container(
                  width: 2,
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_softGold, _softGold.withValues(alpha: 0.0)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Kaaba icon at tip
                Transform.translate(
                  offset: const Offset(0, -95),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB8963E), Color(0xFFD4AF37)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          // Center hub
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF40916C), Color(0xFF1B4332)]),
              boxShadow: [BoxShadow(color: _emerald.withValues(alpha: 0.5), blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dirLabel(String text, double degree, Color color) {
    return Transform.rotate(
      angle: degree * (math.pi / 180),
      child: Transform.translate(
        offset: const Offset(0, -104),
        child: Transform.rotate(
          angle: -degree * (math.pi / 180),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              fontFamily: 'cairo',
              package: 'quran_library',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHint(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _emerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded, color: _emerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'للحصول على أدق النتائج، أبقِ الهاتف مستوياً وابتعد عن المواد المعدنية',
              style: TextStyle(
                fontFamily: 'cairo',
                fontSize: 13,
                color: textColor.withValues(alpha: 0.7),
                height: 1.5,
                package: 'quran_library',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  _CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final majorColor = isDark ? Colors.white38 : Colors.black26;
    final minorColor = isDark ? Colors.white12 : Colors.black12;

    for (var i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final isQuarter = i % 90 == 0;
      final tickLen = isQuarter ? 18.0 : isMajor ? 12.0 : 6.0;
      final angle = i * (math.pi / 180) - math.pi / 2;
      final paint = Paint()
        ..color = isMajor ? majorColor : minorColor
        ..strokeWidth = isMajor ? 1.5 : 0.8;

      final start = Offset(center.dx + (radius - tickLen) * math.cos(angle), center.dy + (radius - tickLen) * math.sin(angle));
      final end = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
