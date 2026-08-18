import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          ListTile(
            leading: Icon(Icons.wifi_tethering_rounded),
            title: Text('Ev Wi-Fi ağı'),
            subtitle: Text('HomeNet-5G'),
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Geofencing'),
            subtitle: Text('Arka plan yerel tetikleyici aktif'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Bildirimler'),
            subtitle: Text('Sesli, titreşimli ve butonlu'),
          ),
        ],
      ),
    );
  }
}
