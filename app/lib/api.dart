import 'dart:io';

import 'package:dio/dio.dart';
import 'package:robo/fire.dart';

class DioUtil {
  static DioUtil _instance;

  static String IP;
  static final String port = "8080";
  static final String test = "/test";
  static final String speed = "/setSpeed";
  static final String fire = "/fire";
  static final String check = "/checkTagNum";
  static final String servo = "/servo";
  static final String cease = "/ceasefire";
  static final String shooting = "/shooting";

  static void init() {
    dio.options.connectTimeout = 1000;
    dio.options.receiveTimeout = 1000;
  }

  static DioUtil get instance => _instance ??= DioUtil();
  static Dio dio = Dio();

  static Future<Response> get(String path) async {
    try {
      var response = await dio.get(path);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print("${"\n" * 5}${"/" * 10} DIO ERROR ${"/" * 10}");
        print("RESPONSE_DATA: \n${e.response.data}");
        print("RESPONSE_HEADERS: \n${e.response.headers}");
        print("RESPONSE_REQUEST: \n${e.response.request}");
        print("REQUEST: ${e.request}");
        print("MESSAGE: ${e.message}");
        print("${"/" * 10} ERROR END ${"/" * 10}${"\n" * 6}");
      }
      return e.response;
    }
  }

  static Future<bool> tsetConn() async {
    var response = await get(test);
    if (response != null && response.data["success"] != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> checkTagNum() async {
    var response = await get(check);
    if (response == null) {
      return 0;
    } else {
      return response.data["tagNum"];
    }
  }

  static Future<int> openFire(String query) async {
    var response = await get("$fire$query");
    if (response == null) {
      return 0;
    } else {
      return response.data["tagNum"];
    }
  }

  static Future<bool> ceaseFire() async {
    var response = await get(cease);
    if (response != null && response.data["success"] != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> setSpeed(double m1, m2) async {
    if(m1 < 0) m1 *= 1.15;
    if(m2 < 0) m2 *= 1.15;
    if(m1 > 110) m1 = 110;
    if(m2 > 110) m2 = 110;
    print("$speed?motor1=${m1.ceil()}&motor2=${m2.ceil()}");
    var response = await get("$speed?motor1=${m1.ceil()}&motor2=${m2.ceil()}");
    if (response != null && response.data["success"] != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> setShooting(int flag) async {
    var response = await get("$shooting?flag=$flag");
    if (response != null && response.data["success"] != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> setServo(double s1, s2) async {
    s1 += 100;
    s1 /= 2;
    s2 += 100;
    s2 /= 2;
    print("$servo?servo1=${s1.ceil()}&servo2=${s2.ceil()}");
    var response = await get("$servo?servo1=${s1.ceil()}&servo2=${s2.ceil()}");
    if (response != null && response.data["success"] != null) {
      return true;
    } else {
      return false;
    }
  }
}
