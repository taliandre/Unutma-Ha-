import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:threshold/core/services/safe_zone_service.dart';

class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  final MapController _mapController = MapController();

  LatLng? _homeLocation;
  double _radius = 30.0;
  bool _isEnabled = false;
  bool _isLoadingLocation = false;

  // İstanbul merkezi — kayıtlı konum yoksa varsayılan
  static const _defaultCenter = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    final lat = SafeZoneService.homeLat;
    final lng = SafeZoneService.homeLng;
    if (lat != null && lng != null) {
      setState(() {
        _homeLocation = LatLng(lat, lng);
        _radius = SafeZoneService.radiusMeters;
        _isEnabled = SafeZoneService.isEnabled;
      });
    }
  }

  // ─── Konum Al ─────────────────────────────────────────────────────────────

  Future<LatLng?> _getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum izni kalıcı olarak reddedildi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await _getCurrentPosition();
      if (loc != null) {
        _mapController.move(loc, 18);
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _useCurrentLocationAsHome() async {
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await _getCurrentPosition();
      if (loc != null) {
        setState(() => _homeLocation = loc);
        _mapController.move(loc, 18);
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onMapTap(TapPosition _, LatLng location) {
    setState(() => _homeLocation = location);
  }

  Future<void> _saveHomeLocation() async {
    if (_homeLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Haritaya dokun ya da mevcut konumunu kullan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await SafeZoneService.saveHomeLocation(
      _homeLocation!.latitude,
      _homeLocation!.longitude,
    );
    await SafeZoneService.setRadius(_radius);
    setState(() => _isEnabled = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ev konumu kaydedildi! Güvenli bölge aktif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Daire noktaları (manuel çizim) ───────────────────────────────────────

  List<LatLng> _buildCirclePoints(LatLng center, double radiusMeters) {
    const steps = 64;
    const earthRadius = 6371000.0;
    final lat = center.latitude * pi / 180;
    final lng = center.longitude * pi / 180;
    final d = radiusMeters / earthRadius;

    return List.generate(steps + 1, (i) {
      final bearing = 2 * pi * i / steps;
      final lat2 = asin(
        sin(lat) * cos(d) + cos(lat) * sin(d) * cos(bearing),
      );
      final lng2 = lng +
          atan2(
            sin(bearing) * sin(d) * cos(lat),
            cos(d) - sin(lat) * sin(lat2),
          );
      return LatLng(lat2 * 180 / pi, lng2 * 180 / pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final center = _homeLocation ?? _defaultCenter;
    final initialZoom = _homeLocation != null ? 17.5 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenli Bölge'),
        actions: [
          if (_isEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('Aktif'),
                avatar: const Icon(Icons.shield_rounded, size: 16),
                backgroundColor: Colors.green.withValues(alpha: 0.15),
                labelStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Harita ──────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: initialZoom,
                    onTap: _onMapTap,
                  ),
                  children: [
                    // OpenStreetMap katmanı — ücretsiz, API key yok
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.threshold',
                      maxZoom: 19,
                    ),

                    // Güvenli bölge çemberi
                    if (_homeLocation != null)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _buildCirclePoints(
                              _homeLocation!,
                              _radius,
                            ),
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderColor:
                                colorScheme.primary.withValues(alpha: 0.6),
                            borderStrokeWidth: 2.5,
                          ),
                        ],
                      ),

                    // Ev markeri
                    if (_homeLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _homeLocation!,
                            width: 48,
                            height: 56,
                            child: Column(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                // Küçük üçgen (ibre)
                                CustomPaint(
                                  size: const Size(12, 8),
                                  painter: _TrianglePainter(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    // OpenStreetMap attribution (ToS gereği)
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),

                // İpucu banner
                if (_homeLocation == null)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Haritaya dokun — ev konumunu seç'),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Konuma git butonu
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'locate',
                    onPressed:
                        _isLoadingLocation ? null : _goToCurrentLocation,
                    child: _isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),

          // ── Alt Panel ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mevcut konumu kullan
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingLocation
                        ? null
                        : _useCurrentLocationAsHome,
                    icon: const Icon(Icons.home_rounded),
                    label:
                        const Text('Mevcut Konumumu Ev Olarak Ayarla'),
                  ),
                ),
                const SizedBox(height: 12),

                // Yarıçap slider
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Yarıçap: ${_radius.round()} m',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                      child: Slider(
                        value: _radius,
                        min: 10,
                        max: 300,
                        divisions: 58,
                        onChanged: (val) =>
                            setState(() => _radius = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Kaydet butonu
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveHomeLocation,
                    icon: const Icon(Icons.shield_rounded),
                    label: const Text(
                        'Güvenli Bölgeyi Kaydet & Aktifleştir'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                if (_isEnabled && _homeLocation != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await SafeZoneService.clear();
                      setState(() {
                        _homeLocation = null;
                        _isEnabled = false;
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                    label: const Text(
                      'Güvenli Bölgeyi Kaldır',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
