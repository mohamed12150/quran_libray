part of '/quran.dart';

class DhikrReminderScreen extends StatefulWidget {
  final bool isDark;
  const DhikrReminderScreen({super.key, this.isDark = false});

  @override
  State<DhikrReminderScreen> createState() => _DhikrReminderScreenState();
}

class _DhikrReminderScreenState extends State<DhikrReminderScreen> {
  static const _orange = Color(0xFFE07B39);

  late bool _dhikr;
  late bool _morning;
  late bool _evening;

  @override
  void initState() {
    super.initState();
    _dhikr   = DhikrReminderService.instance.isDhikrEnabled;
    _morning = DhikrReminderService.instance.isMorningEnabled;
    _evening = DhikrReminderService.instance.isEveningEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final bg        = AppColors.getBackgroundColor(widget.isDark);
    final textColor = AppColors.getTextColor(widget.isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _CornerDecorations(color: _orange),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(textColor),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      _buildCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'أذكار عشوائية',
                        subtitle: 'تذكيرات عشوائية طوال اليوم',
                        detail: 'من ٨ صباحاً حتى ١٠ مساءً',
                        value: _dhikr,
                        textColor: textColor,
                        onChanged: (v) async {
                          await DhikrReminderService.instance.setDhikr(v);
                          setState(() => _dhikr = v);
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildCard(
                        icon: Icons.wb_sunny_rounded,
                        title: 'آية الصباح',
                        subtitle: 'آية قرآنية كل صباح',
                        detail: 'الساعة ٧:٠٠ صباحاً',
                        value: _morning,
                        textColor: textColor,
                        onChanged: (v) async {
                          await DhikrReminderService.instance.setMorning(v);
                          setState(() => _morning = v);
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildCard(
                        icon: Icons.nightlight_round,
                        title: 'آية المساء',
                        subtitle: 'آية قرآنية كل مساء',
                        detail: 'الساعة ٧:٠٠ مساءً',
                        value: _evening,
                        textColor: textColor,
                        onChanged: (v) async {
                          await DhikrReminderService.instance.setEvening(v);
                          setState(() => _evening = v);
                        },
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

  Widget _buildAppBar(Color textColor) {
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
              'الأذكار والتذكيرات',
              textAlign: TextAlign.center,
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    final cardColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? _orange.withValues(alpha: 0.4)
              : _orange.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
              color: _orange.withValues(alpha: value ? 0.15 : 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _orange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                    color: textColor,
                    package: 'quran_library',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'cairo',
                    color: textColor.withValues(alpha: 0.55),
                    package: 'quran_library',
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _orange),
        ],
      ),
    );
  }

}
