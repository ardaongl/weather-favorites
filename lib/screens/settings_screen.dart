import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';

class SettingsScreen extends StatefulWidget {
  final bool isCelsius;
  final ValueChanged<bool> onUnitChanged;
  final String defaultCity;
  final ValueChanged<String> onDefaultCityChanged;

  const SettingsScreen({
    super.key,
    required this.isCelsius,
    required this.onUnitChanged,
    required this.defaultCity,
    required this.onDefaultCityChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _cityController;
  bool _isEditingCity = false;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.defaultCity);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  bool get _isFirebaseConnected => Firebase.apps.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? CupertinoColors.systemBackground.resolveFrom(context)
        : const Color(0xFFF2F2F7);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ayarlar'),
      ),
      child: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            
            // Profil veya Logo Tasarımı
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.cloud_sun_fill,
                      color: CupertinoColors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hava Durumu Favorileri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Apple UI v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Birim Ayarları
            CupertinoListSection.insetGrouped(
              header: const Text('TERCİHLER'),
              children: [
                _buildSettingRow(
                  icon: CupertinoIcons.thermometer,
                  iconColor: CupertinoColors.systemRed,
                  title: 'Sıcaklık Birimi',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                        style: const TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: widget.isCelsius,
                        activeColor: CupertinoColors.activeBlue,
                        onChanged: widget.onUnitChanged,
                      ),
                    ],
                  ),
                ),
                _buildSettingRow(
                  icon: CupertinoIcons.location_solid,
                  iconColor: CupertinoColors.systemGreen,
                  title: 'Varsayılan Şehir',
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingCity = !_isEditingCity;
                      });
                    },
                    child: Text(
                      widget.defaultCity.isEmpty ? 'Girilmedi' : widget.defaultCity,
                      style: TextStyle(
                        color: widget.defaultCity.isEmpty
                            ? CupertinoColors.placeholderText
                            : CupertinoColors.activeBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isEditingCity)
              CupertinoListSection.insetGrouped(
                header: const Text('VARSAYILAN ŞEHİR AYARLA'),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _cityController,
                            placeholder: 'Örn: İstanbul',
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? CupertinoColors.systemGrey6.darkColor
                                  : CupertinoColors.extraLightBackgroundGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onSubmitted: (value) {
                              widget.onDefaultCityChanged(value.trim());
                              setState(() {
                                _isEditingCity = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Text('Kaydet'),
                          onPressed: () {
                            widget.onDefaultCityChanged(_cityController.text.trim());
                            setState(() {
                              _isEditingCity = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // Servis Durumu Ayarları
            CupertinoListSection.insetGrouped(
              header: const Text('SERVİS VE BAĞLANTI DURUMLARI'),
              children: [
                _buildSettingRow(
                  icon: CupertinoIcons.refresh_bold,
                  iconColor: CupertinoColors.systemOrange,
                  title: 'Firebase Firestore',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isFirebaseConnected
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isFirebaseConnected ? 'Bağlandı' : 'Bağlı Değil',
                        style: const TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSettingRow(
                  icon: CupertinoIcons.cloud_fill,
                  iconColor: CupertinoColors.systemBlue,
                  title: 'OpenWeather API',
                  trailing: const Text(
                    'Aktif (v2.5)',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            // Hakkında Ayarları
            CupertinoListSection.insetGrouped(
              header: const Text('BİLGİ'),
              children: [
                _buildSettingRow(
                  icon: CupertinoIcons.info_circle_fill,
                  iconColor: CupertinoColors.systemGrey,
                  title: 'Uygulama Hakkında',
                  trailing: const Text(
                    'Sürüm 1.0.0 (Cupertino UI)',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 15,
                    ),
                  ),
                ),
                _buildSettingRow(
                  icon: CupertinoIcons.person_2_fill,
                  iconColor: CupertinoColors.systemPurple,
                  title: 'Geliştirici',
                  trailing: const Text(
                    'Antigravity AI',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
