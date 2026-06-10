import 'package:flutter/cupertino.dart';
import 'weather_search_tab.dart';
import 'favorites_screen.dart';
import 'compare_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isCelsius;
  final ValueChanged<bool> onUnitChanged;
  final String defaultCity;
  final ValueChanged<String> onDefaultCityChanged;

  const HomeScreen({
    super.key,
    required this.isCelsius,
    required this.onUnitChanged,
    required this.defaultCity,
    required this.onDefaultCityChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search_circle_fill),
            label: 'Hava Durumu',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            activeIcon: Icon(CupertinoIcons.heart_fill),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_left_right),
            activeIcon: Icon(CupertinoIcons.arrow_left_right_circle_fill),
            label: 'Karşılaştır',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Ayarlar',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return WeatherSearchTab(
                  isCelsius: widget.isCelsius,
                  defaultCity: widget.defaultCity,
                );
              case 1:
                return FavoritesScreen(
                  isCelsius: widget.isCelsius,
                );
              case 2:
                return CompareScreen(
                  isCelsius: widget.isCelsius,
                );
              case 3:
                return SettingsScreen(
                  isCelsius: widget.isCelsius,
                  onUnitChanged: widget.onUnitChanged,
                  defaultCity: widget.defaultCity,
                  onDefaultCityChanged: widget.onDefaultCityChanged,
                );
              default:
                return WeatherSearchTab(
                  isCelsius: widget.isCelsius,
                  defaultCity: widget.defaultCity,
                );
            }
          },
        );
      },
    );
  }
}
