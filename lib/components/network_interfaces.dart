import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_network_proxy_ynu/service.dart';

class NetworkInterfaces extends StatefulWidget {
  const NetworkInterfaces({Key? key}) : super(key: key);

  @override
  State<NetworkInterfaces> createState() => _NetworkInterfacesState();
}

class _NetworkInterfacesState extends State<NetworkInterfaces> {
  List<NetworkInterface> interfaces = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    setState(() {
      loading = true;
    });
    interfaces = await Service().getNetworkInterface() ?? [];
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CircularProgressIndicator()
        : Column(
            children: interfaces
                .map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.addresses[0].address),
                    ))
                .toList(),
          );
  }
}
