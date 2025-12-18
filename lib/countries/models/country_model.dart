import '../utils/capital_translations.dart';

/// Модель данных страны
class Country {
  final String officialName;
  final String commonName;
  final String? capital;
  final String? russianCapital; // Русское название столицы
  final int population;
  final double area;
  final String region;
  final String subregion;
  final List<String> languages;
  final Map<String, String> currencies;
  final String flagUrl;
  final String flagEmoji;
  final List<String> timezones;
  final String? coatOfArms;
  
  // Русские названия
  final String? russianCommonName;
  final String? russianOfficialName;
  
  // Язык запроса пользователя (для правильного отображения)
  final bool isRussianSearch;

  Country({
    required this.officialName,
    required this.commonName,
    this.capital,
    this.russianCapital,
    required this.population,
    required this.area,
    required this.region,
    required this.subregion,
    required this.languages,
    required this.currencies,
    required this.flagUrl,
    required this.flagEmoji,
    required this.timezones,
    this.coatOfArms,
    this.russianCommonName,
    this.russianOfficialName,
    this.isRussianSearch = false,
  });

  /// Создание объекта Country из JSON
  factory Country.fromJson(Map<String, dynamic> json, {bool isRussianSearch = false}) {
    // Парсинг официального названия
    final officialName = json['name']?['official'] as String? ?? 'Unknown';
    final commonName = json['name']?['common'] as String? ?? 'Unknown';

    // Парсинг столицы (может быть массивом)
    String? capital;
    if (json['capital'] != null && json['capital'] is List && (json['capital'] as List).isNotEmpty) {
      capital = json['capital'][0] as String?;
    }

    // Парсинг населения
    final population = json['population'] as int? ?? 0;

    // Парсинг площади
    final area = (json['area'] as num?)?.toDouble() ?? 0.0;

    // Парсинг региона и субрегиона
    final region = json['region'] as String? ?? 'Unknown';
    final subregion = json['subregion'] as String? ?? 'Unknown';

    // Парсинг языков
    List<String> languages = [];
    if (json['languages'] != null && json['languages'] is Map) {
      final langMap = json['languages'] as Map<String, dynamic>;
      languages = langMap.values.map((lang) => lang.toString()).toList();
    }

    // Парсинг валют
    Map<String, String> currencies = {};
    if (json['currencies'] != null && json['currencies'] is Map) {
      final currMap = json['currencies'] as Map<String, dynamic>;
      currMap.forEach((key, value) {
        if (value is Map && value['name'] != null) {
          final name = value['name'] as String;
          final symbol = value['symbol'] as String? ?? '';
          currencies[key] = '$name ${symbol.isNotEmpty ? "($symbol)" : ""}';
        }
      });
    }

    // Парсинг флага
    final flagUrl = json['flags']?['png'] as String? ?? '';
    final flagEmoji = json['flag'] as String? ?? '🏳️';

    // Парсинг часовых поясов
    List<String> timezones = [];
    if (json['timezones'] != null && json['timezones'] is List) {
      timezones = (json['timezones'] as List)
          .map((tz) => tz.toString())
          .toList();
    }

    // Парсинг герба
    final coatOfArms = json['coatOfArms']?['png'] as String?;

    // Парсинг русских названий
    String? russianCommonName;
    String? russianOfficialName;
    if (json['translations'] != null && json['translations']['rus'] != null) {
      final rusTranslation = json['translations']['rus'] as Map<String, dynamic>;
      russianCommonName = rusTranslation['common'] as String?;
      russianOfficialName = rusTranslation['official'] as String?;
    }

    // Перевод столицы на русский
    String? russianCapital;
    if (capital != null && isRussianSearch) {
      russianCapital = CapitalTranslations.translate(capital);
    }

    return Country(
      officialName: officialName,
      commonName: commonName,
      capital: capital,
      russianCapital: russianCapital,
      population: population,
      area: area,
      region: region,
      subregion: subregion,
      languages: languages,
      currencies: currencies,
      flagUrl: flagUrl,
      flagEmoji: flagEmoji,
      timezones: timezones,
      coatOfArms: coatOfArms,
      russianCommonName: russianCommonName,
      russianOfficialName: russianOfficialName,
      isRussianSearch: isRussianSearch,
    );
  }
  
  /// Проверка, содержит ли строка кириллические символы
  static bool _containsCyrillic(String text) {
    return RegExp(r'[а-яА-ЯёЁ]').hasMatch(text);
  }

  /// Форматирование населения (например: 146,000,000)
  String get formattedPopulation {
    return population.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Форматирование площади (например: 17,098,242 км²)
  String get formattedArea {
    return '${area.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} км²';
  }

  /// Список языков в виде строки
  String get languagesString {
    if (languages.isEmpty) return 'Не указаны';
    return languages.join(', ');
  }

  /// Список валют в виде строки
  String get currenciesString {
    if (currencies.isEmpty) return 'Не указаны';
    return currencies.values.join(', ');
  }

  /// Основной часовой пояс
  String get mainTimezone {
    if (timezones.isEmpty) return 'UTC';
    return timezones.first;
  }
}

