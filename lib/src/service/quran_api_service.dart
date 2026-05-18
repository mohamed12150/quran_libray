import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../audio/audio.dart';

class QuranApiService extends GetxService {
  static QuranApiService get instance => Get.isRegistered<QuranApiService>()
      ? Get.find<QuranApiService>()
      : Get.put<QuranApiService>(QuranApiService());

  final Dio _dio = Dio();

  Future<void> updateReadersFromApi() async {
    try {
      final response = await _dio.get('${ReadersConstants.reciters}?language=ar');

      if (response.statusCode == 200) {
        List reciters = response.data['reciters'];

        List<ReaderInfo> apiReaders = reciters
            .where((r) => (r['moshaf'] as List).isNotEmpty)
            .map((r) {
          var moshaf = r['moshaf'][0];
          var serverUrl = moshaf['server'] as String;

          // استخراج اسم المجلد من الرابط لضمان تفرد المسار المحلي والبعيد
          // مثال: https://server6.mp3quran.net/akdr/ -> baseUrl: https://server6.mp3quran.net/, folder: akdr/
          String baseUrl = serverUrl;
          String folder = '';

          try {
            Uri uri = Uri.parse(serverUrl);
            List<String> segments =
                uri.pathSegments.where((s) => s.isNotEmpty).toList();
            if (segments.isNotEmpty) {
              folder = '${segments.last}/';
              baseUrl = serverUrl.substring(0, serverUrl.lastIndexOf(folder));
            }
          } catch (_) {
            // fallback if URL parsing fails
            baseUrl = serverUrl;
            folder = '';
          }

          return ReaderInfo(
            index: r['id'],
            name: r['name'],
            url: baseUrl,
            readerNamePath: folder,
          );
        }).toList();

        // دمج القراء من الـ API مع القراء الافتراضيين
        ReadersConstants.customSurahReaders = [
          ...ReadersConstants.surahReaderInfo,
          ...apiReaders,
        ];
        
        // تحديث واجهة اختيار القراء إذا كانت مفتوحة
        if (Get.isRegistered<AudioCtrl>()) {
          AudioCtrl.instance.update(['change_surah_reader']);
        }
        
        log('Successfully fetched ${apiReaders.length} readers from API', name: 'QuranApiService');
      }
    } catch (e, s) {
      log('Error fetching readers from mp3quran: $e', name: 'QuranApiService', stackTrace: s);
    }
  }

  Future<List<Map<String, dynamic>>> fetchAsmaAlHusna() async {
    try {
      final response = await _dio.get('https://api.aladhan.com/v1/asmaAlHusna');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e, s) {
      log('Error fetching Asma al-Husna: $e', name: 'QuranApiService', stackTrace: s);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchHisnMuslimCategories() async {
    try {
      final response = await _dio.get('https://hisnmuslim.com/api/ar/husn_ar.json');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['العربية']);
      }
    } catch (e, s) {
      log('Error fetching Hisn Muslim categories: $e', name: 'QuranApiService', stackTrace: s);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchHisnMuslimDetails(String url) async {
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        // الـ API يرجع كائن مفتاحه هو اسم الفئة، والقيمة هي قائمة الأدعية
        final Map<String, dynamic> data = response.data;
        if (data.isNotEmpty) {
          return List<Map<String, dynamic>>.from(data.values.first);
        }
      }
    } catch (e, s) {
      log('Error fetching Hisn Muslim details: $e', name: 'QuranApiService', stackTrace: s);
    }
    return [];
  }
}
