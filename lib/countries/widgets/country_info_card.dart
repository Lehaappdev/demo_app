import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country_model.dart';

/// Виджет карточки с информацией о стране
class CountryInfoCard extends StatelessWidget {
  final Country country;

  const CountryInfoCard({
    super.key,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Флаг и название
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // Основная информация
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Название страны на соответствующем языке
  Widget _buildCountryName(BuildContext context) {
    // Если искали на русском и есть русское название
    if (country.isRussianSearch && country.russianCommonName != null) {
      return Column(
        children: [
          Text(
            country.russianCommonName!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            country.commonName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // Если искали на английском или нет русского названия
    return Column(
      children: [
        Text(
          country.commonName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (country.isRussianSearch && country.russianCommonName != null) ...[
          const SizedBox(height: 4),
          Text(
            country.russianCommonName!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ] else if (country.officialName != country.commonName) ...[
          const SizedBox(height: 4),
          Text(
            country.officialName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Заголовок с флагом и названием
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Флаг
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: country.flagUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Не удалось загрузить флаг',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Показываем название на языке запроса
        _buildCountryName(context),
      ],
    );
  }

  /// Секция с основной информацией
  Widget _buildInfoSection(BuildContext context) {
    // Определяем язык интерфейса
    final isRussian = country.isRussianSearch;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Столица
        if (country.capital != null)
          _buildInfoRow(
            icon: Icons.location_city,
            label: isRussian ? 'Столица' : 'Capital',
            value: country.capital!,
            iconColor: Colors.blue,
          ),
        
        const SizedBox(height: 12),
        
        // Регион
        _buildInfoRow(
          icon: Icons.public,
          label: isRussian ? 'Регион' : 'Region',
          value: '${country.region} • ${country.subregion}',
          iconColor: Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Население
        _buildInfoRow(
          icon: Icons.people,
          label: isRussian ? 'Население' : 'Population',
          value: country.formattedPopulation,
          iconColor: Colors.orange,
        ),
        
        const SizedBox(height: 12),
        
        // Площадь
        _buildInfoRow(
          icon: Icons.map,
          label: isRussian ? 'Площадь' : 'Area',
          value: country.formattedArea,
          iconColor: Colors.purple,
        ),
        
        const SizedBox(height: 12),
        
        // Языки
        _buildInfoRow(
          icon: Icons.language,
          label: isRussian ? 'Языки' : 'Languages',
          value: country.languagesString,
          iconColor: Colors.teal,
        ),
        
        const SizedBox(height: 12),
        
        // Валюта
        _buildInfoRow(
          icon: Icons.attach_money,
          label: isRussian ? 'Валюта' : 'Currency',
          value: country.currenciesString,
          iconColor: Colors.amber,
        ),
        
        const SizedBox(height: 12),
        
        // Часовой пояс
        _buildInfoRow(
          icon: Icons.access_time,
          label: isRussian ? 'Часовой пояс' : 'Timezone',
          value: country.mainTimezone,
          iconColor: Colors.red,
        ),
      ],
    );
  }

  /// Строка с информацией
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Иконка
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Текст
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

