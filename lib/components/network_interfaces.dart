import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_network_proxy/service.dart';

class NetworkInterfaces extends StatefulWidget {
  NetworkInterfaces({Key key}) : super(key: key);

  @override
  _NetworkInterfacesState createState() => _NetworkInterfacesState();
}

class _NetworkInterfacesState extends State<NetworkInterfaces> {
  List<NetworkInterface> interfaces = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    interfaces = await Service().getNetworkInterface();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: interfaces
          .map((item) => ListTile(
                title: Text(item.name),
                subtitle: Text('${item.addresses[0]?.address}'),
              ))
          .toList(),
    );
  }
}
