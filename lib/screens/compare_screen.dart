import 'package:flutter/cupertino.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class CompareScreen extends StatefulWidget {
  final bool isCelsius;

  const CompareScreen({
    super.key,
    required this.isCelsius,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _city1Controller = TextEditingController();
  final TextEditingController _city2Controller = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  WeatherModel? _weather1;
  WeatherModel? _weather2;

  @override
  void dispose() {
    _city1Controller.dispose();
    _city2Controller.dispose();
    super.dispose();
  }

  Future<void> _compareWeather() async {
    final city1 = _city1Controller.text.trim();
    final city2 = _city2Controller.text.trim();

    if (city1.isEmpty || city2.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen her iki şehir alanını da doldurun.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _weatherService.fetchWeather(city1),
        _weatherService.fetchWeather(city2),
      ]);

      setState(() {
        _weather1 = results[0];
        _weather2 = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
        _weather1 = null;
        _weather2 = null;
      });
    }
  }

  double _convertTemp(double celsius) {
    if (widget.isCelsius) return celsius;
    return celsius * 1.8 + 32;
  }

  String _formatTemp(double celsius) {
    final value = _convertTemp(celsius);
    final unit = widget.isCelsius ? '°C' : '°F';
    return '${value.toStringAsFixed(1)}$unit';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = brightness == Brightness.dark;
    
    final Color sectionColor = isDark
        ? CupertinoColors.systemGrey6.darkColor
        : CupertinoColors.secondarySystemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? CupertinoColors.systemBackground.resolveFrom(context)
          : const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Karşılaştır'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Arama Alanları Grubu
              Container(
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'İki Şehrin Hava Durumunu Karşılaştırın',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: _city1Controller,
                      placeholder: '1. Şehir (Örn: Ankara)',
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(CupertinoIcons.location, color: CupertinoColors.systemGrey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? CupertinoColors.black : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: _city2Controller,
                      placeholder: '2. Şehir (Örn: İzmir)',
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(CupertinoIcons.location, color: CupertinoColors.systemGrey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? CupertinoColors.black : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CupertinoActivityIndicator(radius: 12)
                        : SizedBox(
                            width: double.infinity,
                            child: CupertinoButton.filled(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              borderRadius: BorderRadius.circular(8),
                              onPressed: _compareWeather,
                              child: const Text(
                                'Karşılaştır',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              if (_weather1 != null && _weather2 != null) ...[
                const SizedBox(height: 24),
                // Karşılaştırma Tablosu
                Container(
                  decoration: BoxDecoration(
                    color: sectionColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Başlık Satırı (Şehir Adları)
                      Container(
                        color: CupertinoColors.activeBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _weather1!.cityName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: CupertinoColors.lightBackgroundGray,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _weather2!.cityName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // İkonlar ve Ana Durum
                      _buildComparisonRow(
                        child1: _buildWeatherHeader(_weather1!),
                        title: 'Durum',
                        child2: _buildWeatherHeader(_weather2!),
                      ),

                      // Sıcaklık
                      _buildComparisonRow(
                        child1: Text(
                          _formatTemp(_weather1!.temperature),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        title: 'Sıcaklık',
                        child2: Text(
                          _formatTemp(_weather2!.temperature),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // En Yüksek / En Düşük
                      _buildComparisonRow(
                        child1: Text(
                          '${_formatTemp(_weather1!.tempMax)} / ${_formatTemp(_weather1!.tempMin)}',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        title: 'En Yüksek/Düşük',
                        child2: Text(
                          '${_formatTemp(_weather2!.tempMax)} / ${_formatTemp(_weather2!.tempMin)}',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Nem
                      _buildComparisonRow(
                        child1: Text(
                          '%${_weather1!.humidity}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        title: 'Nem',
                        child2: Text(
                          '%${_weather2!.humidity}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Rüzgar
                      _buildComparisonRow(
                        child1: Text(
                          '${_weather1!.windSpeed} m/s',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        title: 'Rüzgar',
                        child2: Text(
                          '${_weather2!.windSpeed} m/s',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherHeader(WeatherModel weather) {
    final iconUrl = weather.iconCode.isNotEmpty
        ? 'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png'
        : null;

    return Column(
      children: [
        if (iconUrl != null)
          Image.network(
            iconUrl,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) => const Icon(
              CupertinoIcons.cloud,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
          )
        else
          const Icon(CupertinoIcons.cloud, size: 32, color: CupertinoColors.systemGrey),
        Text(
          _capitalize(weather.description),
          style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildComparisonRow({
    required Widget child1,
    required String title,
    required Widget child2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: child1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.inactiveGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: child2,
            ),
          ),
        ],
      ),
    );
  }
}
