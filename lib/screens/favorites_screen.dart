import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Dismissible, ValueKey;
import '../models/weather_model.dart';
import '../services/firestore_service.dart';
import 'weather_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isCelsius;

  const FavoritesScreen({
    super.key,
    required this.isCelsius,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _deleteFavorite(String cityName) async {
    try {
      await _firestoreService.deleteFavorite(cityName);
      // Cupertino'da SnackBar yerine alert veya küçük bir bildirim tercih edilebilir.
      // Ancak listeyi anında güncellemek yeterlidir.
    } catch (e) {
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
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
            largeTitle: Text('Favoriler'),
          ),
          StreamBuilder<List<WeatherModel>>(
            stream: _firestoreService.getFavoritesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator(radius: 12)),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            color: CupertinoColors.systemRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Veriler yüklenirken bir hata oluştu.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(fontSize: 14, color: CupertinoColors.systemRed),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final favorites = snapshot.data ?? [];

              if (favorites.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.heart_slash,
                            size: 64,
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Henüz favori şehir eklemediniz!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hava durumu arama sekmesinden istediğiniz şehirleri aratıp detay sayfasından favorilerinize kaydedebilirsiniz.',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final weather = favorites[index];
                    final iconUrl = weather.iconCode.isNotEmpty
                        ? 'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png'
                        : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Dismissible(
                        key: ValueKey(weather.cityName),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteFavorite(weather.cityName),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => WeatherDetailScreen(
                                  weather: weather,
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
                                if (!isDark)
                                  BoxShadow(
                                    color: CupertinoColors.systemGrey4.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                if (iconUrl != null)
                                  Image.network(
                                    iconUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(CupertinoIcons.cloud, size: 36),
                                  )
                                else
                                  const Icon(CupertinoIcons.cloud, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weather.cityName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _capitalize(weather.description),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.secondaryLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _formatTemp(weather.temperature),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.activeBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      CupertinoIcons.chevron_forward,
                                      color: CupertinoColors.systemGrey3,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: favorites.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
