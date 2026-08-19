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
                  const Text('Uygulama hoşuna gittiyse ve gelişimine destek olmak istersen, Paycell üzerinden bir kahve ısmarlayabilirsin ☕'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alıcı: TALHA UBEYDE BEŞİR',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TR35 0086 9000 0000 0406 7908 20',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary),
                          tooltip: 'IBAN\'ı Kopyala',
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: 'TR35 0086 9000 0000 0406 7908 20'),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('IBAN kopyalandı! Desteğin için çok teşekkürler 💖'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
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
