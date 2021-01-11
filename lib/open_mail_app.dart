import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provides ability to query device for installed email apps and open those
/// apps
class OpenMailApp {
  OpenMailApp._();

  static const MethodChannel _channel = const MethodChannel('open_mail_app');

  /// Attempts to open an email app installed on the device.
  ///
  /// Android: Will open mail app or show native picker if multiple.
  ///
  /// iOS: Will open mail app if single installed mail app is found. If multiple
  /// are found will return a [OpenMailAppResult] that contains list of
  /// [MailApp]s. This can be used along with [MailAppPickerDialog] to allow
  /// the user to pick the mail app they want to open.
  ///
  /// Also see [openSpecificMailApp] and [getMailApps] for other use cases.
  ///
  /// Android: [nativePickerTitle] will set the title of the native picker.
  static Future<OpenMailAppResult> openMailApp(
      {String nativePickerTitle = ''}) async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
        'openMailApp',
        <String, dynamic>{'nativePickerTitle': nativePickerTitle},
      );
      return OpenMailAppResult(didOpen: result);
    } else if (Platform.isIOS) {
      var apps = await _getIosMailApps();
      if (apps.length == 1) {
        var result = await launch(apps.first.iosLaunchScheme);
        return OpenMailAppResult(didOpen: result);
      } else {
        return OpenMailAppResult(didOpen: false, options: apps);
      }
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<bool> openSpecificMailApp(MailApp mailApp) async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
        'openSpecificMailApp',
        <String, dynamic>{'name': mailApp.name},
      );
      return result;
    } else if (Platform.isIOS) {
      return await launch(mailApp.iosLaunchScheme);
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Attempts to open a specific email app installed on the device, and pre-fill the compose screen with user-generated fields.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<bool> composeFromSpecificMailApp(MailApp mailApp,
      {String message, String recipient, String subject}) async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
        'openSpecificMailApp',
        <String, dynamic>{'name': mailApp.name},
      );
      return result;
    } else if (Platform.isIOS) {
      if (mailApp.name == 'Outlook') {
        return await launch(
            '${mailApp.iosLaunchScheme}compose?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Gmail') {
        return await launch(
            '${mailApp.iosLaunchScheme}/co?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Spark') {
        return await launch(
            '${mailApp.iosLaunchScheme}compose?recipient=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Yahoo') {
        return await launch(
            '${mailApp.iosLaunchScheme}mail/compose?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Fastmail') {
        return await launch(
            '${mailApp.iosLaunchScheme}mail/compose?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Default Mail App') {
        return await launch(
            'mailto:?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Dispatch') {
        return await launch(
            '${mailApp.iosLaunchScheme}/compose?to=$recipient&subject=$subject&body=$message');
      } else if (mailApp.name == 'Airmail') {
        return await launch(
            '${mailApp.iosLaunchScheme}compose?to=$recipient&subject=$subject&plainBody=$message');
      } else {
        return await launch(mailApp.iosLaunchScheme);
      }
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Returns a list of installed email apps on the device
  ///
  /// iOS: [MailApp.iosLaunchScheme] will be populated
  static Future<List<MailApp>> getMailApps() async {
    if (Platform.isAndroid) {
      var appsJson = await _channel.invokeMethod<String>('getMainApps');
      var apps = (jsonDecode(appsJson) as Iterable)
          .map((x) => MailApp.fromJson(x))
          .toList();
      return apps;
    } else if (Platform.isIOS) {
      return await _getIosMailApps();
    } else {
      throw Exception('Platform not supported');
    }
  }

  static Future<List<MailApp>> _getIosMailApps() async {
    var installedApps = <MailApp>[];
    for (var app in _IosLaunchSchemes.mailApps) {
      if (await canLaunch(app.iosLaunchScheme)) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }
}

/// A simple dialog for allowing the user to pick and open an email app
/// Use with [OpenMailApp.getMailApps] or [OpenMailApp.openMailApp] to get a
/// list of mail apps installed on the device.
class MailAppPickerDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The mail apps for the dialog to provide as options
  final List<MailApp> mailApps;

  const MailAppPickerDialog({
    Key key,
    this.title = 'Choose Mail App',
    @required this.mailApps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: <Widget>[
        for (var app in mailApps)
          SimpleDialogOption(
            child: Text(app.name),
            onPressed: () {
              OpenMailApp.openSpecificMailApp(app);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class MailAppPickerToComposeDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;
  final String message;
  final String recipient;
  final String subject;

  /// The mail apps for the dialog to provide as options
  final List<MailApp> mailApps;

  const MailAppPickerToComposeDialog({
    Key key,
    this.title = 'Choose Mail App',
    this.message,
    this.subject,
    this.recipient,
    @required this.mailApps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: <Widget>[
        for (var app in mailApps)
          SimpleDialogOption(
            child: Text(app.name),
            onPressed: () {
              OpenMailApp.composeFromSpecificMailApp(app,
                  message: message, recipient: recipient, subject: subject);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class MailApp {
  final String name;
  final String iosLaunchScheme;

  const MailApp({
    this.name,
    this.iosLaunchScheme,
  });

  factory MailApp.fromJson(Map<String, dynamic> json) => MailApp(
        name: json["name"],
        iosLaunchScheme: json["iosLaunchScheme"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "iosLaunchScheme": iosLaunchScheme,
      };
}

/// Result of calling [OpenMailApp.openMailApp]
///
/// [options] and [canOpen] are only populated and used on iOS
class OpenMailAppResult {
  final bool didOpen;
  final List<MailApp> options;
  bool get canOpen => options?.isNotEmpty ?? false;

  OpenMailAppResult({@required this.didOpen, this.options});
}

class _IosLaunchSchemes {
  _IosLaunchSchemes._();

  static const apple = 'message://';
  static const gmail = 'googlegmail://';
  static const dispatch = 'x-dispatch://';
  static const spark = 'readdle-spark://';
  static const airmail = 'airmail://';
  static const outlook = 'ms-outlook://';
  static const yahoo = 'ymail://';
  static const fastmail = 'fastmail://';

  static const mailApps = [
    MailApp(name: 'Mail', iosLaunchScheme: apple),
    MailApp(name: 'Gmail', iosLaunchScheme: gmail),
    MailApp(name: 'Dispatch', iosLaunchScheme: dispatch),
    MailApp(name: 'Spark', iosLaunchScheme: spark),
    MailApp(name: 'Airmail', iosLaunchScheme: airmail),
    MailApp(name: 'Outlook', iosLaunchScheme: outlook),
    MailApp(name: 'Yahoo', iosLaunchScheme: yahoo),
    MailApp(name: 'Fastmail', iosLaunchScheme: fastmail),
  ];
}
