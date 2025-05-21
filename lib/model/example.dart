class Example {
  final String en; // İngilizce örnek cümle
  final String tr; // Türkçe örneği

  Example({required this.en, required this.tr});

  factory Example.fromJson(Map<String, dynamic> json) => Example(
        en: json['en'] as String,
        tr: json['tr'] as String,
      );

  Map<String, dynamic> toJson() => {
        'en': en,
        'tr': tr,
      };
}
