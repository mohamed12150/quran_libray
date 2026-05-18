part of '../../quran.dart';

class DhikrReminderService {
  DhikrReminderService._();
  static final DhikrReminderService instance = DhikrReminderService._();

  final _plugin = fln.FlutterLocalNotificationsPlugin();
  final _storage = GetStorage();
  bool _initialized = false;

  static const _kDhikrEnabled  = 'dhikr_enabled';
  static const _kMorningEnabled = 'dhikr_morning_enabled';
  static const _kEveningEnabled = 'dhikr_evening_enabled';

  // IDs: 200–209 أذكار عشوائية، 210 صباح، 211 مساء
  static const _morningId = 210;
  static const _eveningId = 211;

  // ─── أذكار قصيرة ──────────────────────────────────────────────────────────
  static const List<String> _dhikrTitles = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'استغفر الله',
    'لا إله إلا الله',
    'سبحان الله وبحمده',
    'لا حول ولا قوة إلا بالله',
    'الحمد لله رب العالمين',
    'سبحان الله العظيم',
    'أستغفر الله العظيم',
  ];

  static const List<String> _dhikrBodies = [
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'اللَّهُ أَكْبَرُ كَبِيرًا، وَالْحَمْدُ لِلَّهِ كَثِيرًا',
    'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    'الْحَمْدُ لِلَّهِ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
    'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ، إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ',
  ];

  // ─── آيات الصباح والمساء ─────────────────────────────────────────────────
  static const List<Map<String, String>> _morningAyahs = [
    {'surah': 'البقرة', 'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ'},
    {'surah': 'آل عمران', 'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ'},
    {'surah': 'الطلاق', 'text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ'},
    {'surah': 'الرعد', 'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ'},
    {'surah': 'الإسراء', 'text': 'وَقُل رَّبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا'},
    {'surah': 'الزمر', 'text': 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ'},
    {'surah': 'الشرح', 'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا'},
    {'surah': 'الضحى', 'text': 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ'},
    {'surah': 'البقرة', 'text': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ'},
    {'surah': 'الطلاق', 'text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مِنْ أَمْرِهِ يُسْرًا'},
  ];

  static const List<Map<String, String>> _eveningAyahs = [
    {'surah': 'البقرة', 'text': 'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ'},
    {'surah': 'آل عمران', 'text': 'إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ وَاخْتِلَافِ اللَّيْلِ وَالنَّهَارِ لَآيَاتٍ لِّأُولِي الْأَلْبَابِ'},
    {'surah': 'الإسراء', 'text': 'وَقُل رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا'},
    {'surah': 'النور', 'text': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ'},
    {'surah': 'الفرقان', 'text': 'وَعِبَادُ الرَّحْمَٰنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا'},
    {'surah': 'الحجرات', 'text': 'إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ'},
    {'surah': 'الحديد', 'text': 'مَا أَصَابَ مِن مُّصِيبَةٍ إِلَّا بِإِذْنِ اللَّهِ ۗ وَمَن يُؤْمِن بِاللَّهِ يَهْدِ قَلْبَهُ'},
    {'surah': 'الملك', 'text': 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ'},
    {'surah': 'الإنسان', 'text': 'إِنَّ هَٰذِهِ تَذْكِرَةٌ ۖ فَمَن شَاءَ اتَّخَذَ إِلَىٰ رَبِّهِ سَبِيلًا'},
    {'surah': 'الليل', 'text': 'وَمَا يُغْنِي عَنْهُ مَالُهُ إِذَا تَرَدَّىٰ'},
  ];

  // ─── Getters ──────────────────────────────────────────────────────────────
  bool get isDhikrEnabled  => _storage.read<bool>(_kDhikrEnabled)  ?? false;
  bool get isMorningEnabled => _storage.read<bool>(_kMorningEnabled) ?? false;
  bool get isEveningEnabled => _storage.read<bool>(_kEveningEnabled) ?? false;

  // ─── Public API ───────────────────────────────────────────────────────────
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    final result = await _plugin
        .resolvePlatformSpecificImplementation<fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  Future<void> setDhikr(bool enable) async {
    await _init();
    if (enable) {
      final granted = await _requestPermission();
      if (!granted) return;
    }
    await _storage.write(_kDhikrEnabled, enable);
    enable ? await _scheduleDhikr() : await _cancelDhikr();
  }

  Future<void> setMorning(bool enable) async {
    await _init();
    if (enable) {
      final granted = await _requestPermission();
      if (!granted) return;
    }
    await _storage.write(_kMorningEnabled, enable);
    enable ? await _scheduleAyah(morning: true) : await _plugin.cancel(_morningId);
  }

  Future<void> setEvening(bool enable) async {
    await _init();
    if (enable) {
      final granted = await _requestPermission();
      if (!granted) return;
    }
    await _storage.write(_kEveningEnabled, enable);
    enable ? await _scheduleAyah(morning: false) : await _plugin.cancel(_eveningId);
  }

  Future<void> rescheduleIfEnabled() async {
    if (!isDhikrEnabled && !isMorningEnabled && !isEveningEnabled) return;
    await _init();
    if (isDhikrEnabled)  await _scheduleDhikr();
    if (isMorningEnabled) await _scheduleAyah(morning: true);
    if (isEveningEnabled) await _scheduleAyah(morning: false);
  }

  // ─── Private ──────────────────────────────────────────────────────────────
  Future<void> _init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const android = fln.AndroidInitializationSettings('@drawable/ic_notification');
    const ios = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(const fln.InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  Future<void> _scheduleDhikr() async {
    await _cancelDhikr();
    final rng = math.Random();
    final now = DateTime.now();

    // 6 أوقات عشوائية بين 8 صباحاً و10 مساءً
    const startHour = 8;
    const endHour = 22;
    const totalMinutes = (endHour - startHour) * 60;
    final intervals = List.generate(6, (_) => rng.nextInt(totalMinutes))..sort();

    for (int i = 0; i < intervals.length; i++) {
      final minutesFromStart = intervals[i];
      final hour = startHour + minutesFromStart ~/ 60;
      final minute = minutesFromStart % 60;

      var scheduleDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduleDate.isBefore(now)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      final idx = rng.nextInt(_dhikrTitles.length);
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final m = minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'م' : 'ص';

      final logoPath = await _copyAssetToFile('assets/images/logo_gran.png', 'logo_gran.png');
      await _plugin.zonedSchedule(
        200 + i,
        '${_dhikrTitles[idx]}  •  $h:$m $period',
        _dhikrBodies[idx],
        tz.TZDateTime.from(scheduleDate, tz.local),
        _dhikrDetails(_dhikrBodies[idx], logoPath),
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: fln.DateTimeComponents.time,
      );
    }
  }

  Future<void> _scheduleAyah({required bool morning}) async {
    final rng = math.Random();
    final id = morning ? _morningId : _eveningId;
    final hour = morning ? 7 : 19;
    final list = morning ? _morningAyahs : _eveningAyahs;
    final ayah = list[rng.nextInt(list.length)];

    final now = DateTime.now();
    var scheduleDate = DateTime(now.year, now.month, now.day, hour, 0);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    final assetName = morning ? 'morning' : 'night';
    final imagePath = await _copyAssetToFile('assets/images/$assetName.png', '$assetName.png');

    await _plugin.zonedSchedule(
      id,
      morning ? '🌅 آية الصباح — ${ayah['surah']}' : '🌙 آية المساء — ${ayah['surah']}',
      ayah['text']!,
      tz.TZDateTime.from(scheduleDate, tz.local),
      _ayahDetails(ayah['text']!, imagePath),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.time,
    );
  }

  Future<String?> _copyAssetToFile(String assetPath, String fileName) async {
    try {
      final byteData = await rootBundle.load('packages/quran_library/$assetPath');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cancelDhikr() async {
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(200 + i);
    }
  }

  fln.NotificationDetails _dhikrDetails(String body, [String? imagePath]) {
    return fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'dhikr_channel',
        'أذكار يومية',
        channelDescription: 'تذكيرات بالأذكار والأدعية',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
        enableVibration: false,
        color: const Color(0xFF3D2264),
        colorized: true,
        subText: 'المكتبة القرآنية',
        largeIcon: imagePath != null
            ? fln.FilePathAndroidBitmap(imagePath)
            : null,
        styleInformation: fln.BigTextStyleInformation(
          body,
          htmlFormatBigText: false,
        ),
      ),
      iOS: const fln.DarwinNotificationDetails(presentAlert: true, presentBadge: false),
    );
  }

  fln.NotificationDetails _ayahDetails(String text, String? imagePath) {
    return fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'ayah_channel',
        'آية اليوم',
        channelDescription: 'آية قرآنية صباحاً ومساءً',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
        enableVibration: false,
        color: const Color(0xFF1B4332),
        colorized: true,
        subText: 'المكتبة القرآنية',
        largeIcon: imagePath != null
            ? fln.FilePathAndroidBitmap(imagePath)
            : null,
        styleInformation: fln.BigTextStyleInformation(
          text,
          htmlFormatBigText: false,
        ),
      ),
      iOS: const fln.DarwinNotificationDetails(presentAlert: true, presentBadge: false),
    );
  }
}
