import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenMailApp {
  OpenMailApp._();

  static const MethodChannel _channel = const MethodChannel('open_mail_app');

  static Future<bool> openMailApp() async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>('openMailApp');
      return result;
    } else if (Platform.isIOS) {
      throw Exception('Platform not supported');
    } else {
      throw Exception('Platform not supported');
    }
  }

  static Future<List<App>> getMailApps() async {
    if (Platform.isAndroid) {
      var appsJson = await _channel.invokeMethod<String>('getMainApps');
      var apps = (jsonDecode(appsJson) as Iterable)
          .map((x) => App.fromJson(x))
          .toList();
      return apps;
    } else if (Platform.isIOS) {
      return await _getIosMailApps();
    } else {
      throw Exception('Platform not supported');
    }
  }

  static Future<List<App>> _getIosMailApps() async {
    var installedApps = <_IosApp>[];
    for (var app in _IosLaunchSchemes.mailApps) {
      if (await canLaunch(app.iosLaunchScheme)) {
        installedApps.add(app);
      }
    }
    return installedApps.map((x) => App(name: x.name)).toList();
  }
}

class App {
  String name;

  App({
    this.name,
  });

  factory App.fromJson(Map<String, dynamic> json) => App(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class _IosApp {
  final String name;
  final String iosLaunchScheme;

  const _IosApp(this.name, this.iosLaunchScheme);
}

class _IosLaunchSchemes {
  static const apple = 'message://';
  static const gmail = 'googlegmail://';
  static const dispatch = 'x-dispatch://';
  static const spark = 'readdle-spark://';
  static const airmail = 'airmail://';
  static const outlook = 'ms-outlook://';
  static const yahoo = 'ymail://';
  static const fastmail = 'fastmail://';

  static const mailApps = [
    _IosApp('Mail', apple),
    _IosApp('Gmail', gmail),
    _IosApp('Dispatch', dispatch),
    _IosApp('Spark', spark),
    _IosApp('Airmail', airmail),
    _IosApp('Outlook', outlook),
    _IosApp('Yahoo', yahoo),
    _IosApp('Fastmail', fastmail),
  ];
}
