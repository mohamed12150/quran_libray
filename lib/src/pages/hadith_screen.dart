part of '/quran.dart';

// ══════════════════════════════════════════════════════════════════════════════
// HadithScreen — قائمة الكتب مع تبويبين بخاري / مسلم
// ══════════════════════════════════════════════════════════════════════════════

class HadithScreen extends StatefulWidget {
  final bool isDark;
  const HadithScreen({super.key, this.isDark = false});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen>
    with SingleTickerProviderStateMixin {
  static const _purple = Color(0xFF7B5EA7);

  late final TabController _tabController;
  List<HadithSection> _bukhariSections = [];
  List<HadithSection> _muslimSections = [];
  bool _bukhariLoaded = false;
  bool _muslimLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadSections(HadithBook.bukhari);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_muslimLoaded) {
      _loadSections(HadithBook.muslim);
    }
  }

  Future<void> _loadSections(HadithBook book) async {
    final sections = await HadithService.instance.getSections(book);
    // preload hadiths in background
    HadithService.instance.getBook(book);
    if (!mounted) return;
    setState(() {
      if (book == HadithBook.bukhari) {
        _bukhariSections = sections;
        _bukhariLoaded = true;
      } else {
        _muslimSections = sections;
        _muslimLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(widget.isDark);
    final textColor = AppColors.getTextColor(widget.isDark);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _CornerDecorations(color: _purple),
          SafeArea(
            child: Column(
              children: [
                _HadithAppBar(
                  title: 'الأحاديث النبوية',
                  isDark: widget.isDark,
                  textColor: textColor,
                ),
                _buildTabBar(primaryColor, textColor),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SectionListView(
                        sections: _bukhariSections,
                        isLoaded: _bukhariLoaded,
                        book: HadithBook.bukhari,
                        isDark: widget.isDark,
                        primaryColor: _purple,
                        textColor: textColor,
                      ),
                      _SectionListView(
                        sections: _muslimSections,
                        isLoaded: _muslimLoaded,
                        book: HadithBook.muslim,
                        isDark: widget.isDark,
                        primaryColor: _purple,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color primaryColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: textColor.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
          fontFamily: 'cairo',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          package: 'quran_library',
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'cairo',
          fontSize: 15,
          package: 'quran_library',
        ),
        tabs: const [Tab(text: 'صحيح البخاري'), Tab(text: 'صحيح مسلم')],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _SectionListView — قائمة الكتب
// ══════════════════════════════════════════════════════════════════════════════

class _SectionListView extends StatelessWidget {
  final List<HadithSection> sections;
  final bool isLoaded;
  final HadithBook book;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;

  const _SectionListView({
    required this.sections,
    required this.isLoaded,
    required this.book,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return _SectionCard(
          section: section,
          index: index,
          isDark: isDark,
          primaryColor: primaryColor,
          textColor: textColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithSectionScreen(
                book: book,
                section: section,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final HadithSection section;
  final int index;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SectionCard({
    required this.section,
    required this.index,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/under_screen.png',
                  height: 28,
                  fit: BoxFit.fill,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'cairo',
                    package: 'quran_library',
                  ),
                ),
              ),
              title: Text(
                section.nameAr,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'cairo',
                  color: textColor,
                  package: 'quran_library',
                ),
              ),
              trailing:
                  Icon(Icons.arrow_back_ios_rounded, size: 14, color: primaryColor.withValues(alpha: 0.5)),
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HadithSectionScreen — أحاديث كتاب معين
// ══════════════════════════════════════════════════════════════════════════════

class HadithSectionScreen extends StatefulWidget {
  final HadithBook book;
  final HadithSection section;
  final bool isDark;

  const HadithSectionScreen({
    super.key,
    required this.book,
    required this.section,
    required this.isDark,
  });

  @override
  State<HadithSectionScreen> createState() => _HadithSectionScreenState();
}

class _HadithSectionScreenState extends State<HadithSectionScreen> {
  static const _purple = Color(0xFF7B5EA7);

  List<HadithModel> _hadiths = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HadithService.instance
        .getSection(widget.book, widget.section.id);
    if (!mounted) return;
    setState(() {
      _hadiths = list;
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(widget.isDark);
    final textColor = AppColors.getTextColor(widget.isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _CornerDecorations(color: _purple),
          SafeArea(
            child: Column(
              children: [
                _HadithAppBar(
                  title: widget.section.nameAr,
                  isDark: widget.isDark,
                  textColor: textColor,
                ),
                Expanded(
                  child: !_isLoaded
                      ? Center(
                          child: CircularProgressIndicator(color: _purple))
                      : _hadiths.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد أحاديث في هذا الكتاب',
                                style: TextStyle(
                                  fontFamily: 'cairo',
                                  color: textColor,
                                  package: 'quran_library',
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _hadiths.length,
                              itemBuilder: (context, index) => _HadithCard(
                                hadith: _hadiths[index],
                                isDark: widget.isDark,
                                primaryColor: _purple,
                                textColor: textColor,
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _HadithAppBar extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color textColor;

  const _HadithAppBar({
    required this.title,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
                color: textColor,
                package: 'quran_library',
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;

  const _HadithCard({
    required this.hadith,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
        border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/under_screen.png',
                  height: 35,
                  fit: BoxFit.fill,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'حديث ${hadith.hadithNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'cairo',
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        package: 'quran_library',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hadith.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.9,
                      fontFamily: 'naskh',
                      color: textColor,
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerDecorations extends StatelessWidget {
  final Color color;
  const _CornerDecorations({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: -10, left: -10,
        child: Opacity(opacity: 0.12, child: Image.asset('assets/images/corna_screen.png', width: 120, package: 'quran_library', color: color)),
      ),
      Positioned(
        top: -10, right: -10,
        child: Opacity(opacity: 0.12, child: Image.asset('assets/images/corna_right.png', width: 120, package: 'quran_library', color: color)),
      ),
      Positioned(
        bottom: -10, right: -10,
        child: RotatedBox(quarterTurns: 2, child: Opacity(opacity: 0.12, child: Image.asset('assets/images/corna_screen.png', width: 120, package: 'quran_library', color: color))),
      ),
      Positioned(
        bottom: -10, left: -10,
        child: RotatedBox(quarterTurns: 2, child: Opacity(opacity: 0.12, child: Image.asset('assets/images/corna_right.png', width: 120, package: 'quran_library', color: color))),
      ),
    ]);
  }
}
