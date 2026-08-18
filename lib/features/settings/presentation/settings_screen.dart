import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const ListTile(
            leading: Icon(Icons.wifi_tethering_rounded),
            title: Text('Ev Wi-Fi ağı'),
            subtitle: Text('HomeNet-5G'),
          ),
          const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Geofencing'),
            subtitle: Text('Arka plan yerel tetikleyici aktif'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Bildirimler'),
            subtitle: Text('Sesli, titreşimli ve butonlu'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            subtitle: const Text('Uygulama veri ve gizlilik ilkeleri'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            onTap: () async {
              final url = Uri.parse('https://github.com/taliandre/Unutma-Ha-/blob/main/PRIVACY_POLICY.md');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}
