import 'package:flutter/material.dart';
import 'package:system_network_proxy/app.dart';
import 'package:system_network_proxy/flutter_configuration.dart';
import 'package:system_network_proxy/service.dart';

/// global configuration from yaml
FlutterConfiguration config;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  config = await FlutterConfiguration.fromAsset('assets/config.yaml');
  await Service().init();
  runApp(App());
}
