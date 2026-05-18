part of '/quran.dart';

class HadithService {
  HadithService._();
  static final HadithService instance = HadithService._();

  static const String _bukhariAsset =
      'packages/quran_library/assets/jsons/bukhari.json.gz';
  static const String _muslimAsset =
      'packages/quran_library/assets/jsons/muslim.json.gz';

  static const _assetService = GzipJsonAssetService(diskCacheNamespace: 'hadith_v1');

  List<HadithModel>? _bukhariCache;
  List<HadithModel>? _muslimCache;
  List<HadithSection>? _bukhariSectionsCache;
  List<HadithSection>? _muslimSectionsCache;

  // ─── Arabic section names ────────────────────────────────────────────────

  static const Map<int, String> _bukhariSections = {
    1: 'كتاب بدء الوحي',
    2: 'كتاب الإيمان',
    3: 'كتاب العلم',
    4: 'كتاب الوضوء',
    5: 'كتاب الغسل',
    6: 'كتاب الحيض',
    7: 'كتاب التيمم',
    8: 'كتاب الصلاة',
    9: 'كتاب مواقيت الصلاة',
    10: 'كتاب الأذان',
    11: 'كتاب الجمعة',
    12: 'كتاب صلاة الخوف',
    13: 'كتاب العيدين',
    14: 'كتاب الوتر',
    15: 'كتاب الاستسقاء',
    16: 'كتاب الكسوف',
    17: 'كتاب سجود القرآن',
    18: 'كتاب تقصير الصلاة',
    19: 'كتاب التهجد',
    20: 'كتاب فضل الصلاة في مسجد مكة والمدينة',
    21: 'كتاب العمل في الصلاة',
    22: 'كتاب السهو',
    23: 'كتاب الجنائز',
    24: 'كتاب الزكاة',
    25: 'كتاب الحج',
    26: 'كتاب العمرة',
    27: 'كتاب المحصر',
    28: 'كتاب جزاء الصيد',
    29: 'كتاب فضائل المدينة',
    30: 'كتاب الصوم',
    31: 'كتاب صلاة التراويح',
    32: 'كتاب فضل ليلة القدر',
    33: 'كتاب الاعتكاف',
    34: 'كتاب البيوع',
    35: 'كتاب السلم',
    36: 'كتاب الشفعة',
    37: 'كتاب الإجارة',
    38: 'كتاب الحوالة',
    39: 'كتاب الكفالة',
    40: 'كتاب الوكالة',
    41: 'كتاب المزارعة',
    42: 'كتاب المساقاة',
    43: 'كتاب الاستقراض',
    44: 'كتاب الخصومات',
    45: 'كتاب اللقطة',
    46: 'كتاب المظالم',
    47: 'كتاب الشركة',
    48: 'كتاب الرهن',
    49: 'كتاب العتق',
    50: 'كتاب المكاتب',
    51: 'كتاب الهبة',
    52: 'كتاب الشهادات',
    53: 'كتاب الصلح',
    54: 'كتاب الشروط',
    55: 'كتاب الوصايا',
    56: 'كتاب الجهاد والسير',
    57: 'كتاب الخمس',
    58: 'كتاب الجزية',
    59: 'كتاب بدء الخلق',
    60: 'كتاب أحاديث الأنبياء',
    61: 'كتاب المناقب',
    62: 'كتاب أصحاب النبي ﷺ',
    63: 'كتاب مناقب الأنصار',
    64: 'كتاب المغازي',
    65: 'كتاب تفسير القرآن',
    66: 'كتاب فضائل القرآن',
    67: 'كتاب النكاح',
    68: 'كتاب الطلاق',
    69: 'كتاب النفقات',
    70: 'كتاب الأطعمة',
    71: 'كتاب العقيقة',
    72: 'كتاب الذبائح والصيد',
    73: 'كتاب الأضاحي',
    74: 'كتاب الأشربة',
    75: 'كتاب المرضى',
    76: 'كتاب الطب',
    77: 'كتاب اللباس',
    78: 'كتاب الأدب',
    79: 'كتاب الاستئذان',
    80: 'كتاب الدعوات',
    81: 'كتاب الرقاق',
    82: 'كتاب القدر',
    83: 'كتاب الأيمان والنذور',
    84: 'كتاب كفارات الأيمان',
    85: 'كتاب الفرائض',
    86: 'كتاب الحدود',
    87: 'كتاب الديات',
    88: 'كتاب استتابة المرتدين',
    89: 'كتاب الإكراه',
    90: 'كتاب الحيل',
    91: 'كتاب تعبير الرؤيا',
    92: 'كتاب الفتن',
    93: 'كتاب الأحكام',
    94: 'كتاب التمني',
    95: 'كتاب أخبار الآحاد',
    96: 'كتاب الاعتصام بالكتاب والسنة',
    97: 'كتاب التوحيد',
  };

  static const Map<int, String> _muslimSections = {
    0: 'المقدمة',
    1: 'كتاب الإيمان',
    2: 'كتاب الطهارة',
    3: 'كتاب الحيض',
    4: 'كتاب الصلاة',
    5: 'كتاب المساجد ومواضع الصلاة',
    6: 'كتاب صلاة المسافرين وقصرها',
    7: 'كتاب الجمعة',
    8: 'كتاب صلاة العيدين',
    9: 'كتاب صلاة الاستسقاء',
    10: 'كتاب صلاة الكسوف',
    11: 'كتاب الجنائز',
    12: 'كتاب الزكاة',
    13: 'كتاب الصيام',
    14: 'كتاب الاعتكاف',
    15: 'كتاب الحج',
    16: 'كتاب النكاح',
    17: 'كتاب الرضاع',
    18: 'كتاب الطلاق',
    19: 'كتاب اللعان',
    20: 'كتاب العتق',
    21: 'كتاب البيوع',
    22: 'كتاب المساقاة',
    23: 'كتاب الفرائض',
    24: 'كتاب الهبات',
    25: 'كتاب الوصية',
    26: 'كتاب النذر',
    27: 'كتاب الأيمان',
    28: 'كتاب القسامة والمحاربين والقصاص والديات',
    29: 'كتاب الحدود',
    30: 'كتاب الصيد والذبائح',
    31: 'كتاب الأضاحي',
    32: 'كتاب الأشربة',
    33: 'كتاب اللباس والزينة',
    34: 'كتاب الآداب',
    35: 'كتاب السلام',
    36: 'كتاب الألفاظ من الأدب وغيرها',
    37: 'كتاب الشعر',
    38: 'كتاب الرؤيا',
    39: 'كتاب الفضائل',
    40: 'كتاب فضائل الصحابة',
    41: 'كتاب البر والصلة والآداب',
    42: 'كتاب القدر',
    43: 'كتاب العلم',
    44: 'كتاب الذكر والدعاء والتوبة والاستغفار',
    45: 'كتاب التوبة',
    46: 'كتاب صفات المنافقين وأحكامهم',
    47: 'كتاب الجنة وصفة نعيمها وأهلها',
    48: 'كتاب الفتن وأشراط الساعة',
    49: 'كتاب الزهد والرقائق',
    50: 'كتاب التفسير',
  };

  // ─── Public API ──────────────────────────────────────────────────────────

  Future<List<HadithSection>> getSections(HadithBook book) async {
    if (book == HadithBook.bukhari) {
      _bukhariSectionsCache ??= _buildSections(_bukhariSections);
      return _bukhariSectionsCache!;
    } else {
      _muslimSectionsCache ??= _buildSections(_muslimSections);
      return _muslimSectionsCache!;
    }
  }

  Future<List<HadithModel>> getBook(HadithBook book) async {
    if (book == HadithBook.bukhari) {
      _bukhariCache ??= await _loadBook(_bukhariAsset);
      return _bukhariCache!;
    } else {
      _muslimCache ??= await _loadBook(_muslimAsset);
      return _muslimCache!;
    }
  }

  Future<List<HadithModel>> getSection(HadithBook book, int sectionId) async {
    final hadiths = await getBook(book);
    return hadiths.where((h) => h.bookId == sectionId).toList();
  }

  String getSectionName(HadithBook book, int sectionId) {
    final map = book == HadithBook.bukhari ? _bukhariSections : _muslimSections;
    return map[sectionId] ?? 'الكتاب $sectionId';
  }

  Future<List<HadithModel>> search(HadithBook book, String query) async {
    if (query.trim().isEmpty) return [];
    final hadiths = await getBook(book);
    return hadiths.where((h) => h.text.contains(query.trim())).toList();
  }

  void clearCache() {
    _bukhariCache = null;
    _muslimCache = null;
    _bukhariSectionsCache = null;
    _muslimSectionsCache = null;
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  List<HadithSection> _buildSections(Map<int, String> map) => map.entries
      .map((e) => HadithSection(id: e.key, nameAr: e.value))
      .toList();

  Future<List<HadithModel>> _loadBook(String assetPath) async {
    final data = await _assetService.loadJsonMap(assetPath);
    final list = data['hadiths'] as List<dynamic>;
    return list
        .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
        .where((h) => h.text.isNotEmpty)
        .toList();
  }
}
