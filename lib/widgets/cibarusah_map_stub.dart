// lib/widgets/cibarusah_map_stub.dart
// Dicompile di mobile (dart.library.io) — implementasi WebView asli

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildWebMapView(double height) => const SizedBox.shrink();

void initMobileWebView({
  required Function(dynamic) onController,
  required Function(bool) onLoading,
  required Function() onError,
  required String html,
}) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(
      onPageStarted: (_) => onLoading(true),
      onPageFinished: (_) => onLoading(false),
      onWebResourceError: (_) => onError(),
    ))
    ..loadHtmlString(html);

  onController(controller);
}

Widget buildMobileWebView(dynamic controller) {
  if (controller == null) return const SizedBox.shrink();
  return WebViewWidget(controller: controller as WebViewController);
}

void retryWebView(dynamic controller) {
  if (controller != null) {
    (controller as WebViewController).reload();
  }
}