import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

class YamlConfig {
  late YamlMap _data;

  static Future<YamlConfig> fromFile(File file) {
    return file.readAsString().then((text) => YamlConfig(text));
  }

  YamlConfig(String text) {
    _data = loadYaml(text);
    init();
  }

  /// This helps to initialize object's properties
  ///
  /// For example, you can get rid of getter methods by initializing
  /// your own properties when configuration is loaded
  void init() {}

  dynamic get(String key) => _data[key];
  String getString(String key) => _data[key].toString();
  double getDouble(String key) => double.parse(getString(key));
  int getInt(String key) => int.parse(getString(key));
  bool getBool(String key) {
    var value = get(key);
    return value == 1 || value == true || value == "1" || value == "true";
  }
}

class FlutterConfiguration extends YamlConfig {
  late bool proxyEnable;
  late String proxyServer;
  late String configUrl;

  @override
  void init() {
    var environment = 'debug';
    if (kReleaseMode) {
      environment = 'production';
    }
    var environmentConfigs = get(environment);
    proxyEnable = environmentConfigs['proxyEnable'];
    proxyServer = environmentConfigs['proxyServer'];
    configUrl = environmentConfigs['configUrl'];
    if (kDebugMode) {
      print('proxyEnable: $proxyEnable');
      print('proxyServer: $proxyServer');
      print('configUrl: $configUrl');
    }
  }

  FlutterConfiguration(String text) : super(text);

  static Future<FlutterConfiguration> fromAsset(String asset) async {
    var text = await rootBundle.loadString(asset);
    return FlutterConfiguration(text);
  }

  static Future<FlutterConfiguration> fromAssetUrl(String assetUrl) async {
    var response = await http.get(Uri.parse(assetUrl));
    return FlutterConfiguration(response.body);
  }

  @override
  String toString() {
    return 'FlutterConfiguration{proxyEnable: $proxyEnable, proxyServer: $proxyServer, configUrl: $configUrl}';
  }
}
