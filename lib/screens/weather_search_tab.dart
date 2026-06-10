import 'package:flutter/cupertino.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'weather_detail_screen.dart';

class WeatherSearchTab extends StatefulWidget {
  final bool isCelsius;
  final String defaultCity;

  const WeatherSearchTab({
    super.key,
    required this.isCelsius,
    required this.defaultCity,
  });

  @override
  State<WeatherSearchTab> createState() => _WeatherSearchTabState();
}

class _WeatherSearchTabState extends State<WeatherSearchTab> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  WeatherModel? _defaultWeather;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    if (widget.defaultCity.isNotEmpty) {
      _fetchDefaultCityWeather();
    }
  }

  @override
  void didUpdateWidget(covariant WeatherSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultCity != oldWidget.defaultCity && widget.defaultCity.isNotEmpty) {
      _fetchDefaultCityWeather();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchDefaultCityWeather() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _defaultWeather = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(widget.defaultCity);
      setState(() {
        _defaultWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _getWeather() async {
    final cityName = _cityController.text.trim();
    if (cityName.isEmpty) {
      _showAlertDialog('Hata', 'Lütfen bir şehir adı girin!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.fetchWeather(cityName);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _cityController.clear();
        });
        // Navigate to details screen using Cupertino transition
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => WeatherDetailScreen(
              weather: weather,
              isCelsius: widget.isCelsius,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showAlertDialog('Hata', e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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

    final Color cardBackground = isDark
        ? CupertinoColors.systemGrey6.darkColor
        : CupertinoColors.secondarySystemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? CupertinoColors.systemBackground.resolveFrom(context)
          : const Color(0xFFF2F2F7),
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Hava Durumu'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arama Çubuğu (iOS Search Bar style)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: CupertinoColors.systemGrey4.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _cityController,
                            placeholder: 'Şehir ara (Örn: İstanbul, Paris)',
                            decoration: const BoxDecoration(color: CupertinoColors.transparent),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _getWeather(),
                          ),
                        ),
                        if (_isLoading)
                          const CupertinoActivityIndicator()
                        else if (_cityController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _cityController.clear();
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.clear_thick_circled,
                              color: CupertinoColors.secondaryLabel,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Arama Butonu
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _isLoading ? null : _getWeather,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.cloud),
                        SizedBox(width: 8),
                        Text(
                          'Hava Durumu Getir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Varsayılan Şehir Hava Durumu
                  if (widget.defaultCity.isNotEmpty) ...[
                    Text(
                      'Varsayılan Şehir: ${widget.defaultCity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoading && _defaultWeather == null
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CupertinoActivityIndicator(radius: 12),
                            ),
                          )
                        : _errorMsg != null
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Varsayılan şehir yüklenemedi: $_errorMsg',
                                  style: const TextStyle(color: CupertinoColors.systemRed),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : _defaultWeather != null
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => WeatherDetailScreen(
                                            weather: _defaultWeather!,
                                            isCelsius: widget.isCelsius,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardBackground,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.systemGrey4.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _defaultWeather!.cityName,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _capitalize(_defaultWeather!.description),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: CupertinoColors.secondaryLabel,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (_defaultWeather!.iconCode.isNotEmpty)
                                                Image.network(
                                                  'https://openweathermap.org/img/wn/${_defaultWeather!.iconCode}@2x.png',
                                                  width: 50,
                                                  height: 50,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(CupertinoIcons.cloud_fill),
                                                ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTemp(_defaultWeather!.temperature),
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.activeBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                  ] else ...[
                    // Giriş Bilgisi Görsel Alanı
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            CupertinoIcons.sun_haze_fill,
                            size: 64,
                            color: CupertinoColors.systemOrange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Şehirleri Arayın',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Anlık hava durumu verilerini incelemek ve karşılaştırma yapmak için şehir adı yazıp arama butonuna basın.',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
