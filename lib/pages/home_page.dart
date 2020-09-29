import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:system_network_proxy/components/network_interfaces.dart';
import 'package:system_network_proxy/constants.dart';
import 'package:system_network_proxy/service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var proxyEnable = false;
  var proxyServer = '';
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var service = Service();
    proxyEnable = await service.getProxyEnable();
    proxyServer = await service.getProxyServer();
    setState(() {
      _fbKey.currentState.fields['proxyEnable'].currentState.didChange(proxyEnable);
      _fbKey.currentState.fields['proxyServer'].currentState.didChange(proxyServer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(DEFAULT_EDGEINSETS),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                '系统代理',
                style: defaultTitleTextStyle,
              ),
              FormBuilder(
                key: _fbKey,
                initialValue: {
                  'proxyEnable': proxyEnable,
                  'proxyServer': proxyServer,
                },
                child: Column(
                  children: <Widget>[
                    FormBuilderSwitch(
                      label: Text('是否启用'),
                      attribute: "proxyEnable",
                      initialValue: proxyEnable,
                    ),
                    FormBuilderTextField(
                      attribute: "proxyServer",
                      decoration: InputDecoration(labelText: "代理设置"),
                      validators: [
                        FormBuilderValidators.max(64),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '网络信息',
                style: defaultTitleTextStyle,
              ),
              NetworkInterfaces(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_fbKey.currentState.saveAndValidate()) {
            var proxyEnable = _fbKey.currentState.value['proxyEnable'];
            var proxyServer = _fbKey.currentState.value['proxyServer'];
            var service = Service();
            bool proxyEnableSuccess = await service.setProxyEnable(proxyEnable);
            bool proxyServerSuccess = await service.setProxyServer(proxyServer);
            if (!proxyEnableSuccess || !proxyServerSuccess) {
              return showSimpleNotification(
                Text("设置系统代理错误"),
                background: Colors.red,
                position: NotificationPosition.bottom,
              );
            }
            showSimpleNotification(
              Text("成功设置系统代理"),
              background: Colors.green,
              position: NotificationPosition.bottom,
            );
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
