import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:robo/api.dart';
import 'package:robo/fire.dart';
import 'package:robo/joypad.dart';

class Remote extends StatefulWidget {
  @override
  _RemoteState createState() =>     _RemoteState();
}

class _RemoteState extends State<Remote> {
  TextEditingController _logController = TextEditingController();

  int upDownPassState = 0, leftRightPassState = 0;
  int lastSent = DateTime.now().millisecondsSinceEpoch;
  bool isShooting = false;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _logController.text =
        '${now.hour}:${now.minute}:${now.second}:打开遥控器'; // 设置初始值
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('遥控器'),
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xff27ae60),
          ),
          // 摇杆层
          Container(
            child: Column(
              children: [
                Spacer(),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Column(
                      children: [
                        Text("舵机控制",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 45),
                        Joypad(
                          JoypadType: 1,
                          onChange: (Offset delta) async {
                            if (DateTime.now().millisecondsSinceEpoch -
                                    lastSent >
                                80) {
                              lastSent = DateTime.now().millisecondsSinceEpoch;
                              DioUtil.setServo(
                                delta.dy * 100 / 60,
                                delta.dx * 100 / 60,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("日志信息",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 20),
                        Container(
                          width: 400.0,
                          child: TextField(
                            controller: _logController,
                            readOnly: true,
                            maxLines: 8,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), //带有边框的输入框
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              child: Text("Tag确认"),
                              onPressed: () async {
                                int num = await DioUtil.checkTagNum();
                                BotToast.showText(text: "当前检测到的TAG：$num");
                              },
                            ),
                            SizedBox(width: 16),
                            RaisedButton(
                              child: Text("打靶"),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Fire();
                                })).then((object) async {
                                  while (!await DioUtil.ceaseFire()) {}
                                });
                              },
                            ),
                            SizedBox(width: 16),
                            RaisedButton(
                              child: Text("清空日志"),
                              onPressed: () {
                                setState(() {
                                  _logController.clear();
                                });
                              },
                            ),
                            SizedBox(width: 16),
                            RaisedButton(
                              color: isShooting ? Colors.red : null,
                              child: Text(isShooting ? "取消射击" : "射击"),
                              onPressed: () async {
                                if (isShooting) {
                                  if (await DioUtil.setShooting(0)) {
                                    setState(() {
                                      isShooting = false;
                                    });
                                  }
                                } else {
                                  if (await DioUtil.setShooting(1)) {
                                    setState(() {
                                      isShooting = true;
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("电机控制",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 45),
                        Joypad(
                          JoypadType: 0,
                          onChange: (Offset delta) async {
                            if (DateTime.now().millisecondsSinceEpoch -
                                    lastSent >
                                80) {
                              lastSent = DateTime.now().millisecondsSinceEpoch;
                              double dy = -delta.dy * 70 / 30;
                              double dx = delta.dx * 45 / 30;
                              DioUtil.setSpeed(
                                  0.5 * dy - 0.5 * dx, 0.5 * dy + 0.5 * dx);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                  ],
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 010213
