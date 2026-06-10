import 'package:flutter/cupertino.dart';
import '../models/weather_model.dart';
import '../services/firestore_service.dart';

class WeatherDetailScreen extends StatefulWidget {
  final WeatherModel weather;
  final bool isCelsius;

  const WeatherDetailScreen({
    super.key,
    required this.weather,
    required this.isCelsius,
  });

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isFavorite = false;
  bool _isChecking = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _firestoreService.isFavorite(widget.weather.cityName);
    if (mounted) {
      setState(() {
        _isFavorite = status;
        _isChecking = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (_isFavorite) {
        await _firestoreService.deleteFavorite(widget.weather.cityName);
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
        }
      } else {
        await _firestoreService.addFavorite(widget.weather);
        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
        }
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hata'),
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
    final unit = widget.isCelsius ? '°' : '°';
    return '${value.toStringAsFixed(1)}$unit';
  }

  String _formatTempWithUnit(double celsius) {
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

    final tempString = _formatTemp(widget.weather.temperature);
    final descString = _capitalize(widget.weather.description);
    final iconUrl = widget.weather.iconCode.isNotEmpty
        ? 'https://openweathermap.org/img/wn/${widget.weather.iconCode}@4x.png'
        : null;

    final Color cardBackground = isDark
        ? CupertinoColors.systemGrey6.darkColor
        : CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? CupertinoColors.systemBackground.resolveFrom(context)
          : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.weather.cityName),
        trailing: _isChecking
            ? const CupertinoActivityIndicator(radius: 8)
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isSaving ? null : _toggleFavorite,
                child: _isSaving
                    ? const CupertinoActivityIndicator(radius: 8)
                    : Icon(
                        _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: _isFavorite ? CupertinoColors.systemRed : CupertinoColors.activeBlue,
                      ),
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Hava Durumu Kartı (iOS Tarzı Gradient Panel)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F3C75), Color(0xFF3B6CB8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F3C75).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (iconUrl != null)
                      Image.network(
                        iconUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          CupertinoIcons.cloud,
                          size: 64,
                          color: CupertinoColors.white,
                        ),
                      ),
                    Text(
                      tempString,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w200,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descString,
                      style: const TextStyle(
                        fontSize: 20,
                        color: CupertinoColors.extraLightBackgroundGray,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detaylar Tablosu / Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildDetailCard(
                      title: 'Nem',
                      value: '%${widget.weather.humidity}',
                      icon: CupertinoIcons.drop_fill,
                      color: CupertinoColors.systemBlue,
                      cardBackground: cardBackground,
                    ),
                    _buildDetailCard(
                      title: 'Rüzgar',
                      value: '${widget.weather.windSpeed} m/s',
                      icon: CupertinoIcons.wind,
                      color: CupertinoColors.systemTeal,
                      cardBackground: cardBackground,
                    ),
                    _buildDetailCard(
                      title: 'En Yüksek',
                      value: _formatTempWithUnit(widget.weather.tempMax),
                      icon: CupertinoIcons.thermometer_sun,
                      color: CupertinoColors.systemOrange,
                      cardBackground: cardBackground,
                    ),
                    _buildDetailCard(
                      title: 'En Düşük',
                      value: _formatTempWithUnit(widget.weather.tempMin),
                      icon: CupertinoIcons.thermometer_snowflake,
                      color: CupertinoColors.systemBlue,
                      cardBackground: cardBackground,
                    ),
                  ],
                ),
              ),

              // Favori Ekleme/Çıkarma Alt Buton
              if (!_isChecking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CupertinoButton(
                    color: _isFavorite
                        ? CupertinoColors.systemRed.withOpacity(0.1)
                        : CupertinoColors.activeBlue,
                    onPressed: _isSaving ? null : _toggleFavorite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(12),
                    child: _isSaving
                        ? const CupertinoActivityIndicator()
                        : Text(
                            _isFavorite ? 'Favorilerden Kaldır' : 'Favorilere Ekle',
                            style: TextStyle(
                              color: _isFavorite ? CupertinoColors.systemRed : CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBackground,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                title,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
