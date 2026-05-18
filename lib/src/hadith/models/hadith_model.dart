part of '/quran.dart';

enum HadithBook { bukhari, muslim }

class HadithSection {
  final int id;
  final String nameAr;

  const HadithSection({required this.id, required this.nameAr});
}

class HadithModel {
  final int hadithNumber;
  final String text;
  final int bookId;

  const HadithModel({
    required this.hadithNumber,
    required this.text,
    required this.bookId,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final ref = json['reference'] as Map<String, dynamic>?;
    final rawBook = ref?['book'];
    final rawNumber = json['hadithnumber'];
    return HadithModel(
      hadithNumber: (rawNumber is int) ? rawNumber : int.tryParse(rawNumber?.toString() ?? '') ?? 0,
      text: (json['text'] as String?) ?? '',
      bookId: (rawBook is int) ? rawBook : int.tryParse(rawBook?.toString() ?? '') ?? 0,
    );
  }
}
