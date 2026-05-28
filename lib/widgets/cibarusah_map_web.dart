// lib/widgets/cibarusah_map_web.dart
// Hanya dicompile di platform web (dart.library.html)

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

// Koordinat Cibarusah
const double _lat  = -6.3822;
const double _lng  = 107.0647;
const int    _zoom = 13;

bool _registered = false;

Widget buildWebMapView(double height) {
  const viewType = 'cibarusah-map-iframe';

  if (!_registered) {
    _registered = true;
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = _buildLeafletHtml();
      return iframe;
    });
  }

  return SizedBox(
    height: height,
    child: const HtmlElementView(viewType: 'cibarusah-map-iframe'),
  );
}

String _buildLeafletHtml() => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; }
    #map { width: 100%; height: 100%; }
    .leaflet-popup-content-wrapper {
      border-radius: 14px !important;
      box-shadow: 0 8px 24px rgba(10,31,68,0.2) !important;
    }
    .leaflet-popup-content { margin: 14px !important; font-family: sans-serif; }
    .leaflet-popup-tip-container { display: none; }
    .leaflet-control-zoom {
      border: none !important;
      box-shadow: 0 4px 12px rgba(10,31,68,0.15) !important;
    }
    .leaflet-control-zoom a {
      background: white !important; color: #1440A0 !important;
      border-radius: 8px !important; border: none !important;
      font-weight: 600 !important;
    }
    .leaflet-control-attribution { font-size: 9px !important; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    const map = L.map('map', {
      center: [$_lat, $_lng], zoom: $_zoom, zoomControl: true
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors', maxZoom: 18
    }).addTo(map);

    // Radius wilayah
    L.circle([$_lat, $_lng], {
      radius: 3000, color: '#1440A0', fillColor: '#2563EB',
      fillOpacity: 0.10, weight: 2, dashArray: '6, 4'
    }).addTo(map);

    // Marker utama
    const markerIcon = L.divIcon({
      className: '',
      html: \`<div style="width:36px;height:36px;
        background:linear-gradient(135deg,#1440A0,#2563EB);
        border:3px solid white;border-radius:50% 50% 50% 0;
        transform:rotate(-45deg);
        box-shadow:0 4px 14px rgba(20,64,160,0.45);
        position:relative;">
        <div style="position:absolute;top:50%;left:50%;
          transform:translate(-50%,-50%) rotate(45deg);
          width:10px;height:10px;background:white;border-radius:50%;">
        </div></div>\`,
      iconSize: [36, 36], iconAnchor: [18, 36], popupAnchor: [0, -40]
    });

    const marker = L.marker([$_lat, $_lng], { icon: markerIcon }).addTo(map);
    marker.bindPopup(\`
      <div style="font-family:sans-serif">
        <div style="font-size:15px;font-weight:700;color:#0A1F44">
          📍 Kecamatan Cibarusah
        </div>
        <div style="font-size:12px;color:#64748B;margin-top:4px">
          Kabupaten Bekasi, Jawa Barat
        </div>
        <div style="margin-top:6px;font-size:11px;color:#94A3B8">
          Perbukitan · Persawahan · Aliran Sungai
        </div>
      </div>\`, { maxWidth: 220, closeButton: true });
    setTimeout(() => marker.openPopup(), 800);

    // Marker wisata
    const wisataData = [
      { lat: -6.374, lng: 107.058, name: 'Taman Wisata Ridho Galih', icon: '🌿' },
      { lat: -6.391, lng: 107.071, name: 'Situ Cibening',            icon: '💧' },
      { lat: -6.378, lng: 107.065, name: 'Hamparan Sawah Cibarusah', icon: '🌾' },
    ];
    wisataData.forEach(w => {
      const wIcon = L.divIcon({
        className: '',
        html: \`<div style="width:32px;height:32px;background:white;
          border:2px solid #2563EB;border-radius:50%;
          display:flex;align-items:center;justify-content:center;
          font-size:14px;box-shadow:0 3px 8px rgba(37,99,235,0.25);">
          \${w.icon}</div>\`,
        iconSize: [32, 32], iconAnchor: [16, 16], popupAnchor: [0, -18]
      });
      L.marker([w.lat, w.lng], { icon: wIcon }).addTo(map)
        .bindPopup(\`<div style="font-family:sans-serif;font-size:13px;
          font-weight:700;color:#0A1F44">\${w.icon} \${w.name}</div>\`,
          { maxWidth: 200, closeButton: false });
    });

    // Legend
    const legend = L.control({ position: 'bottomleft' });
    legend.onAdd = () => {
      const div = L.DomUtil.create('div');
      div.innerHTML = \`
        <div style="background:white;border-radius:10px;padding:10px 12px;
          font-family:sans-serif;font-size:11px;
          box-shadow:0 3px 10px rgba(10,31,68,0.12);min-width:140px;">
          <div style="font-weight:700;color:#0A1F44;margin-bottom:6px">Legenda</div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px">
            <div style="width:14px;height:14px;border-radius:50%;
              background:linear-gradient(135deg,#1440A0,#2563EB);border:2px solid white;"></div>
            <span style="color:#334155">Pusat Cibarusah</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px">
            <div style="width:14px;height:3px;background:#1440A0;
              border-radius:2px;border:1px dashed #1440A0;"></div>
            <span style="color:#334155">Radius Wilayah</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px">
            <div style="width:14px;height:14px;border-radius:50%;
              background:white;border:2px solid #2563EB;
              display:flex;align-items:center;justify-content:center;font-size:9px">🌿</div>
            <span style="color:#334155">Destinasi Wisata</span>
          </div>
        </div>\`;
      return div;
    };
    legend.addTo(map);
  </script>
</body>
</html>
''';

// Stub functions untuk mobile (tidak dipakai di web)
void initMobileWebView({
  required Function(dynamic) onController,
  required Function(bool) onLoading,
  required Function() onError,
  required String html,
}) {}

Widget buildMobileWebView(dynamic controller) => const SizedBox.shrink();

void retryWebView(dynamic controller) {}