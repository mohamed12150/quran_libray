part of '../../quran.dart';

/// خدمة الأذان — تجدول إشعارات بصوت الأذان عند كل وقت صلاة
class AzanService {
  AzanService._();
  static final AzanService instance = AzanService._();

  final _plugin = fln.FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _prayerIds = {
    'الفجر': 1,
    'الشروق': 2,
    'الظهر': 3,
    'العصر': 4,
    'المغرب': 5,
    'العشاء': 6,
  };

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = fln.AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const fln.InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(fln.NotificationResponse response) {}

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    final result = await _plugin
        .resolvePlatformSpecificImplementation<fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  Future<void> schedulePrayerAlarms(Map<String, String> prayerTimes) async {
    await initialize();
    await cancelAll();

    final now = DateTime.now();
    final logoPath = await _copyLogoToFile();

    for (final entry in prayerTimes.entries) {
      final id = _prayerIds[entry.key];
      if (id == null) continue;

      final timeParts = entry.value.split(' ').first.split(':');
      if (timeParts.length < 2) continue;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      var scheduleDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduleDate.isBefore(now)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      final tzDate = tz.TZDateTime.from(scheduleDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        'حان وقت ${entry.key}',
        'الله أكبر الله أكبر، أشهد أن لا إله إلا الله',
        tzDate,
        fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'azan_channel',
            'أوقات الصلاة',
            channelDescription: 'إشعارات أذان الصلاة',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
            sound: const fln.RawResourceAndroidNotificationSound('azan'),
            playSound: true,
            enableVibration: true,
            color: const Color(0xFF1B4332),
            colorized: true,
            subText: 'المكتبة القرآنية',
            largeIcon: logoPath != null
                ? fln.FilePathAndroidBitmap(logoPath)
                : const fln.DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: const fln.BigTextStyleInformation(
              'الله أكبر الله أكبر، أشهد أن لا إله إلا الله، أشهد أن محمداً رسول الله',
              htmlFormatBigText: false,
            ),
          ),
          iOS: const fln.DarwinNotificationDetails(
            sound: 'azan.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: fln.DateTimeComponents.time,
      );

      log('Azan scheduled: ${entry.key} at $tzDate', name: 'AzanService');
    }
  }

  /// اختبار الأذان — يُشغّل الإشعار بعد 10 ثواني
  Future<void> testAzan() async {
    await initialize();
    final granted = await requestPermission();
    if (!granted) return;

    final scheduleDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    final logoPath = await _copyLogoToFile();

    await _plugin.zonedSchedule(
      99,
      'اختبار الأذان',
      'الله أكبر الله أكبر، أشهد أن لا إله إلا الله',
      scheduleDate,
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'azan_channel',
          'أوقات الصلاة',
          channelDescription: 'إشعارات أذان الصلاة',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          sound: const fln.RawResourceAndroidNotificationSound('azan'),
          playSound: true,
          enableVibration: true,
          color: const Color(0xFF1B4332),
          colorized: true,
          subText: 'المكتبة القرآنية',
          largeIcon: logoPath != null
              ? fln.FilePathAndroidBitmap(logoPath)
              : const fln.DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: const fln.BigTextStyleInformation(
            'الله أكبر الله أكبر، أشهد أن لا إله إلا الله، أشهد أن محمداً رسول الله',
          ),
        ),
        iOS: const fln.DarwinNotificationDetails(
          sound: 'azan.mp3',
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );

    log('Test azan scheduled at $scheduleDate', name: 'AzanService');
  }

  Future<String?> _copyLogoToFile() async {
    try {
      final byteData = await rootBundle.load('packages/quran_library/assets/images/logo_gran.png');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/logo_gran.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> cancelPrayer(String prayerName) async {
    final id = _prayerIds[prayerName];
    if (id != null) await _plugin.cancel(id);
  }

  Future<List<fln.PendingNotificationRequest>> getPending() async {
    return _plugin.pendingNotificationRequests();
  }
}
