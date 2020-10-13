import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_network_proxy/main.dart';

class Service {
  bool proxyEnable;
  String proxyServer;
  String configUrl;

  Service._internal();

  static final Service _service = Service._internal();

  factory Service() {
    return _service;
  }

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool initialized = prefs.getBool('initialized') ?? false;
    if (!initialized) {
      await saveProxySettings(config.proxyEnable, config.proxyServer, config.configUrl);
    }
    proxyEnable = prefs.getBool('proxyEnable') ?? config.proxyEnable;
    proxyServer = prefs.getString('proxyServer') ?? config.proxyServer;
    configUrl = prefs.getString('configUrl') ?? config.configUrl;
  }

  Future<bool> saveProxySettings(bool proxyEnable, String proxyServer, String configUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('initialized', true);
    prefs.setBool('proxyEnable', proxyEnable);
    prefs.setString('proxyServer', proxyServer);
    prefs.setString('configUrl', configUrl);
    return true;
  }

  Future<bool> getProxyEnable() async {
    var results = await Process.run('reg', [
      'query',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
      '/v',
      'ProxyEnable',
    ]);
    print('get proxyEnable, exitCode: ${results.exitCode}, stdout: ${results.stdout}');
    var proxyEnableLine = (results.stdout as String).split('\r\n').where((item) => item.contains('ProxyEnable')).first;
    return proxyEnableLine.substring(proxyEnableLine.length - 1) == '1';
  }

  Future<bool> setProxyEnable(bool proxyEnable) async {
    var results = await Process.run('reg', [
      'add',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
      '/v',
      'ProxyEnable',
      '/t',
      'REG_DWORD',
      '/f',
      '/d',
      proxyEnable ? '1' : '0',
    ]);
    print('set proxyEnable, exitCode: ${results.exitCode}, stdout: ${results.stdout}');
    return results.exitCode == 0;
  }

  Future<String> getProxyServer() async {
    var results = await Process.run('reg', [
      'query',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
      '/v',
      'ProxyServer',
    ]);
    print('get proxyServer, exitCode: ${results.exitCode}, stdout: ${results.stdout}');
    var proxyServerLine = (results.stdout as String).split('\r\n').where((item) => item.contains('ProxyServer')).first;
    var proxyServerLineSplits = proxyServerLine.split(RegExp(r"\s+"));
    return proxyServerLineSplits[proxyServerLineSplits.length - 1];
  }

  Future<bool> setProxyServer(String proxyServer) async {
    var results = await Process.run('reg', [
      'add',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
      '/v',
      'ProxyServer',
      '/f',
      '/d',
      proxyServer,
    ]);
    print('set proxyServer, exitCode: ${results.exitCode}, stdout: ${results.stdout}');
    return results.exitCode == 0;
  }

  Future<List<NetworkInterface>> getNetworkInterface() async {
    var interfaces = await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.IPv4);
    // var filtedInterfaces =
    //     interfaces.where((item) => item.name.contains('本地连接') || item.name.contains('Ethernet_Realtek')).toList();
    // return filtedInterfaces;
    return interfaces;
  }
}
