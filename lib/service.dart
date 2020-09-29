import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_network_proxy/main.dart';

class Service {
  String proxyServer;

  Service._internal();

  static final Service _service = Service._internal();

  factory Service() {
    return _service;
  }

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool initialized = prefs.getBool('initialized') ?? false;
    if (!initialized) {
      prefs.setBool('initialized', true);
      prefs.setString('proxyServer', config.proxyServer);
    }
    proxyServer = prefs.getString('proxyServer') ?? config.proxyServer;
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

  Future<bool> setProxyEnable(bool enable) async {
    var results = await Process.run('reg', [
      'add',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
      '/v',
      'ProxyEnable',
      '/t',
      'REG_DWORD',
      '/f',
      '/d',
      enable ? '1' : '0',
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
    var filtedInterfaces =
        interfaces.where((item) => item.name.contains('本地连接') || item.name.contains('Ethernet_Realtek')).toList();
    return filtedInterfaces;
  }
}
