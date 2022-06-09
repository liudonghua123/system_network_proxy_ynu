import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_network_proxy/system_network_proxy.dart';
import 'package:system_network_proxy_ynu/main.dart';

class Service {
  late bool proxyEnable;
  late String proxyServer;
  late String configUrl;

  Service._internal();

  static final Service _service = Service._internal();

  factory Service() {
    return _service;
  }

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool initialized = prefs.getBool('initialized') ?? false;
    if (!initialized) {
      await saveProxySettings(
          config.proxyEnable, config.proxyServer, config.configUrl);
    }
    proxyEnable = prefs.getBool('proxyEnable') ?? config.proxyEnable;
    proxyServer = prefs.getString('proxyServer') ?? config.proxyServer;
    configUrl = prefs.getString('configUrl') ?? config.configUrl;
  }

  Future<bool> saveProxySettings(
      bool proxyEnable, String proxyServer, String configUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('initialized', true);
    prefs.setBool('proxyEnable', proxyEnable);
    prefs.setString('proxyServer', proxyServer);
    prefs.setString('configUrl', configUrl);
    return true;
  }

  Future<bool> getProxyEnable() async {
    return SystemNetworkProxy.getProxyEnable();
  }

  Future<bool> setProxyEnable(bool proxyEnable) async {
    return SystemNetworkProxy.setProxyEnable(proxyEnable);
  }

  Future<String> getProxyServer() async {
    return SystemNetworkProxy.getProxyServer();
  }

  Future<bool> setProxyServer(String proxyServer) async {
    return SystemNetworkProxy.setProxyServer(proxyServer);
  }

  Future<List<NetworkInterface>?> getNetworkInterface() async {
    try {
      var interfaces = await NetworkInterface.list(
          includeLoopback: false, type: InternetAddressType.IPv4);
      // var filtedInterfaces =
      //     interfaces.where((item) => item.name.contains('本地连接') || item.name.contains('Ethernet_Realtek')).toList();
      // return filtedInterfaces;
      return interfaces;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
