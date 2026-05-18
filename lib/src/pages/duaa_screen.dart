part of '/quran.dart';

class DuaaScreen extends StatefulWidget {
  final bool isDark;
  const DuaaScreen({super.key, this.isDark = false});

  @override
  State<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends State<DuaaScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await QuranApiService.instance.fetchHisnMuslimCategories();
    if (mounted) {
      setState(() {
        categories = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.getBackgroundColor(widget.isDark);
    final textColor = AppColors.getTextColor(widget.isDark);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Corner Decorations
          Positioned(
            top: -10,
            left: -10,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/corna_screen.png',
                width: 120,
                package: 'quran_library',
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/corna_right.png',
                width: 120,
                package: 'quran_library',
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: RotatedBox(
              quarterTurns: 2,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/corna_screen.png',
                  width: 120,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            child: RotatedBox(
              quarterTurns: 2,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/corna_right.png',
                  width: 120,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor, 'حصن المسلم'),
                Image.asset(
                  'assets/images/duaa.png',
                  height: 100,
                  package: 'quran_library',
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : categories.isEmpty
                          ? Center(
                              child: Text(
                                'تعذر جلب البيانات. تحقق من الاتصال.',
                                style: TextStyle(fontFamily: 'cairo', color: textColor),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return _buildCategoryCard(context, category, primaryColor, textColor);
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

  Widget _buildAppBar(BuildContext context, Color textColor, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'cairo',
              color: textColor,
              package: 'quran_library',
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, Color primaryColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/under_screen.png',
                  height: 30,
                  fit: BoxFit.fill,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              title: Text(
                category['TITLE'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  color: textColor,
                  package: 'quran_library',
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: primaryColor.withOpacity(0.5)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuaaDetailsScreen(
                      title: category['TITLE'],
                      url: category['TEXT'],
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DuaaDetailsScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isDark;

  const DuaaDetailsScreen({
    super.key,
    required this.title,
    required this.url,
    required this.isDark,
  });

  @override
  State<DuaaDetailsScreen> createState() => _DuaaDetailsScreenState();
}

class _DuaaDetailsScreenState extends State<DuaaDetailsScreen> {
  List<Map<String, dynamic>> duaas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final data = await QuranApiService.instance.fetchHisnMuslimDetails(widget.url);
    if (mounted) {
      setState(() {
        duaas = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.getBackgroundColor(widget.isDark);
    final textColor = AppColors.getTextColor(widget.isDark);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Corner Decorations
          Positioned(
            top: -10,
            left: -10,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/corna_screen.png',
                width: 100,
                package: 'quran_library',
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/corna_right.png',
                width: 100,
                package: 'quran_library',
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: RotatedBox(
              quarterTurns: 2,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/corna_screen.png',
                  width: 100,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            child: RotatedBox(
              quarterTurns: 2,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/corna_right.png',
                  width: 100,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor, widget.title),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : duaas.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد بيانات متاحة.',
                                style: TextStyle(fontFamily: 'cairo', color: textColor),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: duaas.length,
                              itemBuilder: (context, index) {
                                return _buildDuaaItem(context, duaas[index], primaryColor, textColor);
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

  Widget _buildAppBar(BuildContext context, Color textColor, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              style: TextStyle(
                fontSize: 18,
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

  Widget _buildDuaaItem(BuildContext context, Map<String, dynamic> duaa, Color primaryColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/under_screen.png',
                  height: 40,
                  fit: BoxFit.fill,
                  package: 'quran_library',
                  color: primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    duaa['ARABIC_TEXT'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      fontFamily: 'kufi',
                      color: textColor,
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (duaa['REPEAT'] != null && duaa['REPEAT'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'التكرار: ${duaa['REPEAT']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'cairo',
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          package: 'quran_library',
                        ),
                      ),
                    ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
