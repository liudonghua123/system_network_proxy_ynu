import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:system_network_proxy_ynu/components/network_interfaces.dart';
import 'package:system_network_proxy_ynu/constants.dart';
import 'package:system_network_proxy_ynu/flutter_configuration.dart';
import 'package:system_network_proxy_ynu/main.dart';
import 'package:system_network_proxy_ynu/service.dart';
import 'package:system_network_proxy_ynu/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class ExpandedItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  ExpandedItem(this.isExpanded, this.header, this.body, this.iconpic);
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var proxyEnable = Service().proxyEnable;
  var proxyServer = Service().proxyServer;
  var configUrl = Service().configUrl;

  List<ExpandedItem> items = <ExpandedItem>[
    ExpandedItem(
      false,
      '系统代理',
      Container(),
      const Icon(FontAwesome5Solid.network_wired),
    ),
    ExpandedItem(
      false,
      '网卡信息',
      Container(),
      const Icon(MaterialCommunityIcons.check_network_outline),
    ),
  ];
  TextEditingController proxyServerController =
      TextEditingController(text: Service().proxyServer);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  _normalizeProxy(String proxyServer) {
    var match = RegExp(r"^(?:http://)?(?<host>.+):(?<port>\d+)$")
        .firstMatch(proxyServer);
    if (match == null) {
      if (kDebugMode) {
        print('proxyServer is invalid');
      }
      return '';
    }
    var host = match.namedGroup('host');
    var port = match.namedGroup('port');
    return '$host:$port';
  }

  void loadData() async {
    var acturalProxyEnable = await Service().getProxyEnable();
    var acturalProxyServer = await Service().getProxyServer();
    if (_normalizeProxy(acturalProxyServer) != _normalizeProxy(proxyServer)) {
      await Service().setProxyServer(acturalProxyServer);
    }
    if (acturalProxyEnable != proxyEnable) {
      await Service().setProxyEnable(proxyEnable);
    }
    // https://stackoverflow.com/questions/72505027/do-not-use-buildcontexts-across-async-gaps-after-update-pub-yaml-to-the-major-v
    if (mounted) {
      showMessageDialog(
          context, '系统代理', '已 ${proxyEnable ? "开启" : "关闭"} 代理 $proxyServer');
    }
    setState(() {
      items = <ExpandedItem>[
        ExpandedItem(
          true, // isExpanded ?
          '系统代理', // header
          Padding(
            padding: const EdgeInsets.all(defaultEdgeinsets),
            child: FormBuilder(
              key: _fbKey,
              initialValue: {
                'proxyEnable': proxyEnable,
              },
              child: Column(
                children: <Widget>[
                  FormBuilderSwitch(
                    title: Text('是否启用代理 ( $proxyServer )'),
                    name: "proxyEnable",
                    initialValue: proxyEnable,
                    onChanged: (value) async {
                      await configProxySettings(value, proxyServer, configUrl);
                    },
                  ),
                ],
              ),
            ),
          ), // body
          const Icon(FontAwesome5Solid.network_wired),
        ),
        ExpandedItem(
          false, // isExpanded ?
          '网卡信息', // header
          const Padding(
            padding: EdgeInsets.all(defaultEdgeinsets),
            child: NetworkInterfaces(),
          ), // body
          const Icon(MaterialCommunityIcons.check_network_outline),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                var url = Uri.parse(
                    'https://github.com/liudonghua123/system_network_proxy_ynu');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(defaultEdgeinsets),
                child: Lottie.asset(
                  'assets/35785-preloader-wifiish-by-fendah-cyberbryte.json',
                  height: appBarHeight - 2 * defaultEdgeinsets,
                ),
              ),
            ),
            const Text(
              '系统代理设置',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultEdgeinsets),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  var url = Uri.parse(
                      'https://github.com/liudonghua123/system_network_proxy_ynu/issues');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Lottie.asset(
                  'assets/28189-github-octocat.json',
                  height: appBarHeight,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                items[index].isExpanded = !items[index].isExpanded;
              });
            },
            children: items
                .map(
                  (ExpandedItem item) => ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        leading: item.iconpic,
                        title: Text(
                          item.header,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTap: () => setState(() {
                          item.isExpanded = !isExpanded;
                        }),
                        onLongPress: () async => {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('配置代理',
                                    style: TextStyle(color: Colors.blueAccent)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: proxyServerController,
                                      textAlign: TextAlign.left,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '输入代理地址',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("取消"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("更新"),
                                    onPressed: () async {
                                      var progressDialog =
                                          ProgressDialog(context: context);
                                      await progressDialog.show(
                                          max: 100, msg: 'Loading...');
                                      var remoteConfig =
                                          await FlutterConfiguration
                                              .fromAssetUrl(config.configUrl);
                                      progressDialog.close();
                                      proxyServerController.text =
                                          remoteConfig.proxyServer;
                                      configProxySettings(
                                          proxyEnable,
                                          remoteConfig.proxyServer,
                                          remoteConfig.configUrl);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("确定"),
                                    onPressed: () {
                                      configProxySettings(
                                          proxyEnable,
                                          proxyServerController.text,
                                          configUrl);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          )
                        },
                      );
                    },
                    isExpanded: item.isExpanded,
                    body: item.body,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     if (_fbKey.currentState.saveAndValidate()) {
      //       var proxyEnable = _fbKey.currentState.value['proxyEnable'];
      //       await configProxySettings(proxyEnable, proxyServer, configUrl);
      //     }
      //   },
      //   child: Icon(Icons.save),
      // ),
    );
  }

  configProxySettings(proxyEnable, proxyServer, configUrl) async {
    var service = Service();
    bool proxyServerSuccess = await service.setProxyServer(proxyServer);
    bool proxyEnableSuccess = await service.setProxyEnable(proxyEnable);
    if (!proxyEnableSuccess || !proxyServerSuccess) {
      return showSimpleNotification(
        const Text("设置系统代理错误"),
        background: Colors.red,
        position: NotificationPosition.bottom,
      );
    }
    setState(() {
      this.proxyEnable = proxyEnable;
      this.proxyServer = proxyServer;
      this.configUrl = configUrl;
      loadData();
    });
    service.saveProxySettings(proxyEnable, proxyServer, configUrl);
    showSimpleNotification(
      const Text("成功设置系统代理"),
      background: Colors.green,
      position: NotificationPosition.bottom,
    );
  }
}
