import 'package:flutter/material.dart';
import 'package:robo/ip.dart';
import 'package:bot_toast/bot_toast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      title: 'robo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InputIp(),
    );
  }
}
