// lib/widgets/cibarusah_map_widget.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════════
// CIBARUSAH MAP WIDGET
// Embed Google Maps via WebView — pin lokasi + radius wilayah kecamatan
// ════════════════════════════════════════════════════════════════════════════════
class CibarusahMapWidget extends StatefulWidget {
  final double height;
  final bool showFullscreenButton;

  const CibarusahMapWidget({
    super.key,
    this.height = 300,
    this.showFullscreenButton = true,
  });

  @override
  State<CibarusahMapWidget> createState() => _CibarusahMapWidgetState();
}

class _CibarusahMapWidgetState extends State<CibarusahMapWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // Koordinat pusat Cibarusah
  static const double _lat  = -6.3822;
  static const double _lng  = 107.0647;
  static const int    _zoom = 13;

  // Radius wilayah kecamatan ~3km
  static const double _radiusKm = 3.0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.blueGhost)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (_) => setState(() {
          _isLoading = false;
          _hasError = true;
        }),
      ))
      ..loadHtmlString(_buildMapHtml());
  }

  // HTML dengan Leaflet.js (OpenStreetMap tiles) — no API key needed
  String _buildMapHtml() {
    final radiusMeters = (_radiusKm * 1000).toInt();

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; }
    #map { width: 100%; height: 100%; }

    /* Custom marker */
    .custom-marker {
      background: #1440A0;
      border: 3px solid white;
      border-radius: 50% 50% 50% 0;
      transform: rotate(-45deg);
      box-shadow: 0 4px 12px rgba(20, 64, 160, 0.4);
    }
    .custom-marker::after {
      content: '';
      position: absolute;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%) rotate(45deg);
      width: 8px; height: 8px;
      background: white;
      border-radius: 50%;
    }

    /* Info popup styling */
    .leaflet-popup-content-wrapper {
      border-radius: 14px !important;
      box-shadow: 0 8px 24px rgba(10, 31, 68, 0.2) !important;
      border: none !important;
    }
    .leaflet-popup-content {
      margin: 16px !important;
      font-family: 'Segoe UI', sans-serif;
    }
    .popup-title {
      font-size: 15px;
      font-weight: 700;
      color: #0A1F44;
      margin-bottom: 4px;
    }
    .popup-sub {
      font-size: 12px;
      color: #64748B;
      margin-bottom: 8px;
    }
    .popup-badge {
      display: inline-block;
      background: #EFF6FF;
      color: #1440A0;
      font-size: 11px;
      font-weight: 600;
      padding: 3px 10px;
      border-radius: 20px;
      margin-top: 2px;
    }
    .leaflet-popup-tip-container { display: none; }

    /* Zoom controls */
    .leaflet-control-zoom {
      border: none !important;
      box-shadow: 0 4px 12px rgba(10, 31, 68, 0.15) !important;
    }
    .leaflet-control-zoom a {
      background: white !important;
      color: #1440A0 !important;
      border-radius: 8px !important;
      border: none !important;
      font-weight: 600 !important;
    }
    .leaflet-control-zoom a:first-child {
      border-radius: 8px 8px 0 0 !important;
      border-bottom: 1px solid #EFF6FF !important;
    }
    .leaflet-control-zoom a:last-child {
      border-radius: 0 0 8px 8px !important;
    }

    /* Attribution kecil */
    .leaflet-control-attribution {
      font-size: 9px !important;
      background: rgba(255,255,255,0.7) !important;
      border-radius: 6px 0 0 0 !important;
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    // Init map
    const map = L.map('map', {
      center: [$_lat, $_lng],
      zoom: $_zoom,
      zoomControl: true,
      attributionControl: true,
    });

    // Tile layer — OpenStreetMap (gratis, no API key)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 18,
    }).addTo(map);

    // ── Radius wilayah kecamatan ──────────────────────────────────────────────
    const circle = L.circle([$_lat, $_lng], {
      radius: $radiusMeters,
      color: '#1440A0',
      fillColor: '#2563EB',
      fillOpacity: 0.10,
      weight: 2,
      dashArray: '6, 4',
    }).addTo(map);

    // Glow effect — lingkaran kedua lebih besar & transparan
    L.circle([$_lat, $_lng], {
      radius: ${(radiusMeters * 1.15).toInt()},
      color: '#60A5FA',
      fillColor: '#BFDBFE',
      fillOpacity: 0.05,
      weight: 1,
      dashArray: '3, 6',
    }).addTo(map);

    // ── Custom marker ──────────────────────────────────────────────────────────
    const markerIcon = L.divIcon({
      className: '',
      html: \`<div style="
        width: 36px; height: 36px;
        background: linear-gradient(135deg, #1440A0, #2563EB);
        border: 3px solid white;
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        box-shadow: 0 4px 14px rgba(20, 64, 160, 0.45);
        position: relative;
      "><div style="
        position: absolute;
        top: 50%; left: 50%;
        transform: translate(-50%, -50%) rotate(45deg);
        width: 10px; height: 10px;
        background: white;
        border-radius: 50%;
      "></div></div>\`,
      iconSize: [36, 36],
      iconAnchor: [18, 36],
      popupAnchor: [0, -40],
    });

    const marker = L.marker([$_lat, $_lng], { icon: markerIcon }).addTo(map);

    // ── Popup info ─────────────────────────────────────────────────────────────
    marker.bindPopup(\`
      <div class="popup-title">📍 Kecamatan Cibarusah</div>
      <div class="popup-sub">Kabupaten Bekasi, Jawa Barat</div>
      <div class="popup-badge">🌾 Luas ~${_radiusKm.toStringAsFixed(0)} km radius</div>
      <div style="margin-top:6px; font-size:11px; color:#94A3B8;">
        Perbukitan · Persawahan · Aliran Sungai
      </div>
    \`, {
      maxWidth: 220,
      closeButton: true,
    });

    // Auto-open popup
    setTimeout(() => marker.openPopup(), 800);

    // ── Marker wisata ──────────────────────────────────────────────────────────
    const wisataData = [
      { lat: -6.374, lng: 107.058, name: 'Taman Wisata Ridho Galih', icon: '🌿' },
      { lat: -6.391, lng: 107.071, name: 'Situ Cibening',            icon: '💧' },
      { lat: -6.378, lng: 107.065, name: 'Hamparan Sawah Cibarusah', icon: '🌾' },
    ];

    wisataData.forEach(w => {
      const wisataIcon = L.divIcon({
        className: '',
        html: \`<div style="
          width: 32px; height: 32px;
          background: white;
          border: 2px solid #2563EB;
          border-radius: 50%;
          display: flex; align-items: center; justify-content: center;
          font-size: 14px;
          box-shadow: 0 3px 8px rgba(37, 99, 235, 0.25);
          cursor: pointer;
        ">\${w.icon}</div>\`,
        iconSize: [32, 32],
        iconAnchor: [16, 16],
        popupAnchor: [0, -18],
      });

      L.marker([w.lat, w.lng], { icon: wisataIcon })
        .addTo(map)
        .bindPopup(\`
          <div style="font-family: 'Segoe UI', sans-serif; padding: 4px;">
            <div style="font-size:13px; font-weight:700; color:#0A1F44;">
              \${w.icon} \${w.name}
            </div>
            <div style="font-size:11px; color:#64748B; margin-top:3px;">
              Wisata Cibarusah
            </div>
          </div>
        \`, { maxWidth: 200, closeButton: false });
    });

    // ── Legend ─────────────────────────────────────────────────────────────────
    const legend = L.control({ position: 'bottomleft' });
    legend.onAdd = () => {
      const div = L.DomUtil.create('div');
      div.innerHTML = \`
        <div style="
          background: white;
          border-radius: 10px;
          padding: 10px 12px;
          font-family: 'Segoe UI', sans-serif;
          font-size: 11px;
          box-shadow: 0 3px 10px rgba(10,31,68,0.12);
          min-width: 140px;
        ">
          <div style="font-weight:700; color:#0A1F44; margin-bottom:6px;">
            Legenda
          </div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px;">
            <div style="width:14px;height:14px;border-radius:50%;background:linear-gradient(135deg,#1440A0,#2563EB);border:2px solid white;"></div>
            <span style="color:#334155;">Pusat Cibarusah</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px;">
            <div style="width:14px;height:3px;background:#1440A0;border-radius:2px;border: 1px dashed #1440A0;"></div>
            <span style="color:#334155;">Radius Wilayah</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px;">
            <div style="width:14px;height:14px;border-radius:50%;background:white;border:2px solid #2563EB;display:flex;align-items:center;justify-content:center;font-size:9px;">🌿</div>
            <span style="color:#334155;">Destinasi Wisata</span>
          </div>
        </div>
      \`;
      return div;
    };
    legend.addTo(map);
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // WebView peta
            if (!_hasError)
              WebViewWidget(controller: _controller)
            else
              _ErrorPlaceholder(onRetry: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              }),

            // Loading indicator
            if (_isLoading && !_hasError)
              Container(
                color: AppColors.blueGhost,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32, height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.blueDeep,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Memuat peta...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey500,
                            fontFamily: 'Poppins',
                          )),
                    ],
                  ),
                ),
              ),

            // Fullscreen button
            if (widget.showFullscreenButton && !_isLoading && !_hasError)
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _FullscreenMapScreen(),
                    ),
                  ),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueDark.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.fullscreen_rounded,
                        color: AppColors.blueDeep, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Placeholder ────────────────────────────────────────────────────────
class _ErrorPlaceholder extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorPlaceholder({required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.blueGhost,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined,
                  size: 48, color: AppColors.bluePastel),
              const SizedBox(height: 12),
              Text('Gagal memuat peta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
                  )),
              const SizedBox(height: 6),
              Text('Periksa koneksi internet kamu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey400,
                  )),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.blueDeep,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Coba Lagi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Fullscreen Map Screen ────────────────────────────────────────────────────
class _FullscreenMapScreen extends StatefulWidget {
  const _FullscreenMapScreen();

  @override
  State<_FullscreenMapScreen> createState() =>
      _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends State<_FullscreenMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueDark,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: const Text('Peta Cibarusah',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded,
                color: Colors.white, size: 20),
            onPressed: () {},
            tooltip: 'Lokasiku',
          ),
        ],
      ),
      body: CibarusahMapWidget(
        height: MediaQuery.of(context).size.height,
        showFullscreenButton: false,
      ),
    );
  }
}