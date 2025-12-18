import 'package:flutter/foundation.dart';
import '../models/country_model.dart';
import '../services/country_api_service.dart';

/// Возможные состояния при поиске страны
enum CountrySearchState {
  /// Начальное состояние (до первого поиска)
  initial,
  
  /// Идет загрузка данных
  loading,
  
  /// Данные успешно загружены
  loaded,
  
  /// Произошла ошибка
  error,
}

/// Provider для управления состоянием поиска стран
class CountryProvider extends ChangeNotifier {
  final CountryApiService _apiService = CountryApiService();
  
  // Текущее состояние
  CountrySearchState _state = CountrySearchState.initial;
  CountrySearchState get state => _state;
  
  // Найденная страна
  Country? _country;
  Country? get country => _country;
  
  // Сообщение об ошибке
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Последний поисковый запрос
  String? _lastQuery;
  String? get lastQuery => _lastQuery;

  /// Поиск страны по названию
  Future<void> searchCountry(String name) async {
    // Сохраняем запрос
    _lastQuery = name;
    
    // Устанавливаем состояние загрузки
    _state = CountrySearchState.loading;
    _errorMessage = null;
    _country = null;
    notifyListeners();
    
    try {
      // Выполняем поиск через API
      final result = await _apiService.searchCountryByName(name);
      
      if (result == null) {
        // Страна не найдена
        _state = CountrySearchState.error;
        _errorMessage = 'Страна "$name" не найдена.\nПроверьте правильность написания.';
        _country = null;
      } else {
        // Страна найдена
        _state = CountrySearchState.loaded;
        _country = result;
        _errorMessage = null;
      }
    } catch (e) {
      // Произошла ошибка
      _state = CountrySearchState.error;
      _errorMessage = _extractErrorMessage(e.toString());
      _country = null;
    }
    
    notifyListeners();
  }

  /// Извлечение понятного сообщения об ошибке
  String _extractErrorMessage(String error) {
    if (error.contains('Нет подключения к интернету')) {
      return '🌐 Нет подключения к интернету.\nПроверьте соединение и попробуйте снова.';
    } else if (error.contains('Превышено время ожидания')) {
      return '⏱️ Превышено время ожидания.\nПопробуйте еще раз.';
    } else if (error.contains('Ошибка сервера')) {
      return '🔧 Ошибка на сервере.\nПопробуйте позже.';
    } else if (error.contains('Название страны не может быть пустым')) {
      return '✏️ Введите название страны';
    } else {
      return '❌ Произошла ошибка.\nПопробуйте еще раз.';
    }
  }

  /// Сброс состояния к начальному
  void reset() {
    _state = CountrySearchState.initial;
    _country = null;
    _errorMessage = null;
    _lastQuery = null;
    notifyListeners();
  }

  /// Очистить только ошибку (для повторного поиска)
  void clearError() {
    if (_state == CountrySearchState.error) {
      _state = CountrySearchState.initial;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Проверка, идет ли сейчас загрузка
  bool get isLoading => _state == CountrySearchState.loading;

  /// Проверка, есть ли загруженные данные
  bool get hasData => _state == CountrySearchState.loaded && _country != null;

  /// Проверка, есть ли ошибка
  bool get hasError => _state == CountrySearchState.error;

  /// Проверка, начальное ли состояние
  bool get isInitial => _state == CountrySearchState.initial;
}

