import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Resmi Web Sitesi'),
            subtitle: const Text('Uygulama tanıtım sayfası'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            onTap: () async {
              final url = Uri.parse('https://taliandre.github.io/Unutma-Ha-/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Açık Kaynak Kodları'),
            subtitle: const Text('GitHub üzerinden projeyi incele'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            onTap: () async {
              final url = Uri.parse('https://github.com/taliandre/Unutma-Ha-');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Geliştiriciye Destek Ol',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Uygulama hoşuna gittiyse ve gelişimine destek olmak istersen, ByNoGame üzerinden bir kahve ısmarlayabilirsin ☕'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        // ByNoGame Bağış Linki
                        final url = Uri.parse('https://donate.bynogame.com/taliapps');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.videogame_asset_rounded),
                      label: const Text('ByNoGame ile Destek Ol'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
