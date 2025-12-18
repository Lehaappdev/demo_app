import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_model.dart';

/// Сервис для работы с REST Countries API
class CountryApiService {
  // Базовый URL API
  static const String _baseUrl = 'https://restcountries.com/v3.1';
  
  // Таймаут для запросов
  static const Duration _timeout = Duration(seconds: 10);

  /// Поиск страны по названию
  /// 
  /// [name] - название страны (на любом языке, включая русский)
  /// Возвращает объект [Country] или null, если страна не найдена
  /// Бросает исключение в случае ошибки
  Future<Country?> searchCountryByName(String name) async {
    try {
      // Проверка на пустое название
      if (name.trim().isEmpty) {
        throw Exception('Название страны не может быть пустым');
      }

      final searchName = name.trim();
      
      // Определяем язык запроса (русский или нет)
      final isRussianSearch = _containsCyrillic(searchName);
      
      // Формируем URL в зависимости от языка запроса
      Uri url;
      http.Response response;
      
      if (isRussianSearch) {
        // Для русского языка сразу используем эндпоинт translation
        url = Uri.parse('$_baseUrl/translation/$searchName');
        print('Запрос к API (перевод): $url');
        
        response = await http.get(url).timeout(
          _timeout,
          onTimeout: () {
            throw Exception('Превышено время ожидания ответа от сервера');
          },
        );
      } else {
        // Для английского языка используем обычный эндпоинт name
        url = Uri.parse('$_baseUrl/name/$searchName');
        print('Запрос к API: $url');
        
        response = await http.get(url).timeout(
          _timeout,
          onTimeout: () {
            throw Exception('Превышено время ожидания ответа от сервера');
          },
        );
      }

      print('Статус ответа: ${response.statusCode}');

      // Обработка ответа
      switch (response.statusCode) {
        case 200:
          // Успешный ответ
          final List<dynamic> jsonData = json.decode(response.body);
          
          if (jsonData.isEmpty) {
            return null;
          }
          
          // Ищем наиболее подходящую страну
          // Если поиск по русскому названию, ищем страну с русским переводом
          Country? bestMatch;
          for (var countryJson in jsonData) {
            final country = Country.fromJson(
              countryJson as Map<String, dynamic>,
              isRussianSearch: isRussianSearch,
            );
            
            // Проверяем, есть ли совпадение с русским названием
            if (isRussianSearch && countryJson['translations'] != null) {
              final translations = countryJson['translations'] as Map<String, dynamic>;
              if (translations['rus'] != null) {
                final rusTranslation = translations['rus'] as Map<String, dynamic>;
                final rusCommon = rusTranslation['common'] as String?;
                final rusOfficial = rusTranslation['official'] as String?;
                
                if (rusCommon?.toLowerCase() == searchName.toLowerCase() ||
                    rusOfficial?.toLowerCase() == searchName.toLowerCase()) {
                  return country;
                }
              }
            }
            
            // Сохраняем первое совпадение как запасной вариант
            bestMatch ??= country;
          }
          
          return bestMatch ?? Country.fromJson(
            jsonData[0] as Map<String, dynamic>,
            isRussianSearch: isRussianSearch,
          );
          
        case 404:
          // Страна не найдена
          return null;
          
        case 500:
        case 502:
        case 503:
          // Ошибка сервера
          throw Exception('Ошибка сервера. Попробуйте позже');
          
        default:
          // Другие ошибки
          throw Exception('Ошибка при получении данных: ${response.statusCode}');
      }
    } on http.ClientException {
      // Ошибка сети
      throw Exception('Нет подключения к интернету');
    } catch (e) {
      // Прочие ошибки
      if (e.toString().contains('Превышено время ожидания') ||
          e.toString().contains('Название страны не может быть пустым') ||
          e.toString().contains('Ошибка сервера') ||
          e.toString().contains('Нет подключения к интернету')) {
        rethrow;
      }
      throw Exception('Произошла ошибка: ${e.toString()}');
    }
  }

  /// Проверка, содержит ли строка кириллические символы
  bool _containsCyrillic(String text) {
    return RegExp(r'[а-яА-ЯёЁ]').hasMatch(text);
  }

  /// Получить список всех стран (для будущего использования)
  Future<List<Country>> getAllCountries() async {
    try {
      final url = Uri.parse('$_baseUrl/all');
      
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        return jsonData
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Ошибка при получении списка стран');
      }
    } catch (e) {
      throw Exception('Произошла ошибка при загрузке стран: ${e.toString()}');
    }
  }

  /// Поиск стран по региону (для будущего использования)
  Future<List<Country>> searchCountriesByRegion(String region) async {
    try {
      final url = Uri.parse('$_baseUrl/region/$region');
      
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        return jsonData
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Ошибка при поиске стран по региону');
      }
    } catch (e) {
      throw Exception('Произошла ошибка: ${e.toString()}');
    }
  }
}

