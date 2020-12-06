import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:robo/api.dart';
import 'package:robo/remote.dart';

class InputIp extends StatefulWidget {
  @override
  _InputIpState createState() => new _InputIpState();
}

class _InputIpState extends State<InputIp> {
  TextEditingController _ipController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _ipController.text = "192.168.1.2";
    return Scaffold(
      appBar: AppBar(
        title: Text('连接树莓派'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: LoginForm(context),
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Form LoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "请输入树莓派IP",
            style: Theme.of(context).textTheme.headline4,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 38),
            child: TextFormField(
                autofocus: false,
                keyboardType: TextInputType.number,
                controller: _ipController,
                decoration: InputDecoration(
                    labelText: "请输入树莓派IP",
                    prefixIcon: Icon(Icons.speaker_phone)),
                validator: (v) {
                  return checkIp(v.trim());
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(58.0),
            child: RaisedButton(
              padding: EdgeInsets.all(15.0),
              child: Text("连接"),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                if ((_formKey.currentState as FormState).validate()) {
                  BotToast.showText(text: "测试连通性中，请稍等");
                  DioUtil.IP = _ipController.text;
                  DioUtil.dio.options.baseUrl = "http://${_ipController.text}";
                  bool isConn = await DioUtil.tsetConn();
                  if (!isConn) {
                    BotToast.showText(text: "连接失败，检测一下ip吧");
                    return;
                  }
                  WidgetsFlutterBinding.ensureInitialized();

                  // 设置屏幕方向(设置屏幕方向为横向)
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);


                  // 禁止所有UI层(设置全屏)
                  SystemChrome.setEnabledSystemUIOverlays([]);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Remote();
                  })).then((object) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown
                    ]);
                  });
                } else {
                  BotToast.showText(text: "好兄弟，你的ip格式不正确呀！");
                }
              },
            ),
          )
        ],
      ),
    );
  }

  String checkIp(String ip) {
    if (ip.length == 0) return "IP不能为空";
    RegExp regex = new RegExp(
      r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$",
      caseSensitive: false,
      multiLine: false,
    );
    if (!regex.hasMatch(ip)) {
      return "IP格式不正确(仅支持IPv4)";
    }
    return null;
  }
}
