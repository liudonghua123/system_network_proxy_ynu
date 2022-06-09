// import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:system_network_proxy_ynu/app.dart';
import 'package:system_network_proxy_ynu/flutter_configuration.dart';
import 'package:system_network_proxy_ynu/service.dart';
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart' as window_size;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:system_network_proxy/system_network_proxy.dart';

/// global configuration from yaml
late FlutterConfiguration config;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemNetworkProxy.init();
  await configWindowSizeIfNecessary();
  config = await FlutterConfiguration.fromAsset('assets/config.yaml');
  await Service().init();
  runApp(const App());
}

configWindowSizeIfNecessary() async {
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    // await DesktopWindow.setWindowSize(Size(500, 300));
    var window = await window_size.getWindowInfo();
    if (window.screen != null) {
      final screenFrame = window.screen!.visibleFrame;
      const width = 600.0;
      const height = 500.0;
      final left = ((screenFrame.width - width) / 2).roundToDouble();
      final top = ((screenFrame.height - height) / 3).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      window_size.setWindowFrame(frame);
      window_size.setWindowMinSize(const Size(1.0 * width, 1.0 * height));
      window_size.setWindowMaxSize(const Size(2.0 * width, 2.0 * height));
      window_size
          .setWindowTitle('System Network Proxy (${Platform.operatingSystem})');
    }
  }
}
