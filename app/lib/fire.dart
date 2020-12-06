import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:robo/api.dart';

class Fire extends StatefulWidget {
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('遥控器'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "请输入tag，用（.）分割",
                ),
                keyboardType: TextInputType.number,
              ),

              RaisedButton(
                child: Text("开火"),
                onPressed: (){
                  var text = _controller.text.split(".");
                  if(text.length < 3) {
                    BotToast.showText(text: "请输入3个tag");
                    return;
                  }
                  String url = "?tag1=${text[0]}&tag2=${text[1]}&tag3=${text[2]}";
                  print(url);
                  DioUtil.openFire(url);
                  BotToast.showText(text: "开火中，请勿退出该页面");
                },
              ),
              RaisedButton(
                child: Text("取消开火并返回"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
