import 'dart:async';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenMailApp {
  static const MethodChannel _channel = const MethodChannel('open_mail_app');

  Future<List<App>> _getIosMailApps() async {
    var installedApps = <App>[];
    for (var app in _IosLaunchSchemes.mailApps) {
      if (await canLaunch(app.iosLaunchScheme)) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }
}

class App {
  final String name;
  final String iosLaunchScheme;

  const App(this.name, this.iosLaunchScheme);
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
    App('Mail', apple),
    App('Gmail', gmail),
    App('Dispatch', dispatch),
    App('Spark', spark),
    App('Airmail', airmail),
    App('Outlook', outlook),
    App('Yahoo', yahoo),
    App('Fastmail', fastmail),
  ];
}
