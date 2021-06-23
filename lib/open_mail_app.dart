import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch Schemes for supported apps:
const String _LAUNCH_SCHEME_APPLE_MAIL = 'message://';
const String _LAUNCH_SCHEME_GMAIL = 'googlegmail://';
const String _LAUNCH_SCHEME_DISPATCH = 'x-dispatch://';
const String _LAUNCH_SCHEME_SPARK = 'readdle-spark://';
const String _LAUNCH_SCHEME_AIRMAIL = 'airmail://';
const String _LAUNCH_SCHEME_OUTLOOK = 'ms-outlook://';
const String _LAUNCH_SCHEME_YAHOO = 'ymail://';
const String _LAUNCH_SCHEME_FASTMAIL = 'fastmail://';

/// Provides ability to query device for installed email apps and open those
/// apps
class OpenMailApp {
  OpenMailApp._();

  static const MethodChannel _channel = const MethodChannel('open_mail_app');
  static List<String> _filterList = <String>['paypal'];
  static List<MailApp> _supportedMailApps = [
    MailApp(
      name: 'Apple Mail',
      iosLaunchScheme: _LAUNCH_SCHEME_APPLE_MAIL,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: 'mailto:',
      ),
    ),
    MailApp(
      name: 'Gmail',
      iosLaunchScheme: _LAUNCH_SCHEME_GMAIL,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_GMAIL + '/co',
      ),
    ),
    MailApp(
      name: 'Dispatch',
      iosLaunchScheme: _LAUNCH_SCHEME_DISPATCH,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_DISPATCH + '/compose',
      ),
    ),
    MailApp(
      name: 'Spark',
      iosLaunchScheme: _LAUNCH_SCHEME_SPARK,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_SPARK + 'compose',
        to: 'recipient=',
      ),
    ),
    MailApp(
      name: 'Airmail',
      iosLaunchScheme: _LAUNCH_SCHEME_AIRMAIL,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_AIRMAIL + 'compose',
        body: 'plainBody=',
      ),
    ),
    MailApp(
      name: 'Outlook',
      iosLaunchScheme: _LAUNCH_SCHEME_OUTLOOK,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_OUTLOOK + 'compose',
      ),
    ),
    MailApp(
      name: 'Yahoo',
      iosLaunchScheme: _LAUNCH_SCHEME_YAHOO,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_YAHOO + 'mail/compose',
      ),
    ),
    MailApp(
      name: 'Fastmail',
      iosLaunchScheme: _LAUNCH_SCHEME_FASTMAIL,
      iosComposeLaunchScheme: ComposeLaunchScheme(
        base: _LAUNCH_SCHEME_FASTMAIL + 'mail/compose',
      ),
    ),
  ];

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
  static Future<OpenMailAppResult> openMailApp({
    String nativePickerTitle = '',
  }) async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
            'openMailApp',
            <String, dynamic>{'nativePickerTitle': nativePickerTitle},
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (Platform.isIOS) {
      var apps = await _getIosMailApps();
      if (apps.length == 1) {
        var result = await launch(
          apps.first.iosLaunchScheme,
          forceSafariVC: false,
        );
        return OpenMailAppResult(didOpen: result);
      } else {
        return OpenMailAppResult(didOpen: false, options: apps);
      }
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Allows you to open a mail application installed on the user's device
  /// and start composing a new email with the contents in [emailContent].
  ///
  /// [EmailContent] Provides content for  the email you're composing
  /// [String] (android) sets the title of the native picker.
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<OpenMailAppResult> composeNewEmailInMailApp({
    String nativePickerTitle = '',
    EmailContent? emailContent,
  }) async {
    if (Platform.isAndroid) {
      return Future.value(OpenMailAppResult(didOpen: false));
    } else if (Platform.isIOS) {
      List<MailApp> installedApps = await _getIosMailApps();
      if (installedApps.length == 1) {
        bool result = await launch(
          installedApps.first.iosLaunchScheme,
          forceSafariVC: false,
        );
        return OpenMailAppResult(didOpen: result);
      } else {
        // This is pretty shit since you can't do anything with this...
        // Need to adapt the flow with that popup to also allow to pass emailcontent there.
        return OpenMailAppResult(didOpen: false, options: installedApps);
      }
    } else {
      throw Exception('Platform currently not supported.');
    }
  }

  /// Allows you to compose a new email in the specified [mailApp] witht the
  /// contents from [emailContent]
  ///
  /// [MailApp] (required) the maill app you wish to launch. Get it by calling [getMailApps]
  /// [EmailContent] provides content for the email you're composing
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<bool> composeNewEmailInSpecificMailApp({
    required MailApp mailApp,
    required EmailContent emailContent,
  }) async {
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
      String? launchScheme = mailApp.composeLaunchScheme(emailContent);
      print(launchScheme);
      if (launchScheme != null) {
        return await launch(launchScheme);
      }

      return false;
    } else {
      throw Exception('Platform currently not supported');
    }

    return false;
  }

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<bool> openSpecificMailApp(MailApp mailApp) async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
            'openSpecificMailApp',
            <String, dynamic>{'name': mailApp.name},
          ) ??
          false;
      return result;
    } else if (Platform.isIOS) {
      return await launch(
        mailApp.iosLaunchScheme,
        forceSafariVC: false,
      );
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Returns a list of installed email apps on the device
  ///
  /// iOS: [MailApp.iosLaunchScheme] will be populated
  static Future<List<MailApp>> getMailApps() async {
    if (Platform.isAndroid) {
      return await _getAndroidMailApps();
    } else if (Platform.isIOS) {
      return await _getIosMailApps();
    } else {
      throw Exception('Platform not supported');
    }
  }

  static Future<List<MailApp>> _getAndroidMailApps() async {
    var appsJson = await _channel.invokeMethod<String>('getMainApps');
    var apps = <MailApp>[];

    if (appsJson != null) {
      apps = (jsonDecode(appsJson) as Iterable)
          .map((x) => MailApp.fromJson(x))
          .where((app) => !_filterList.contains(app.name.toLowerCase()))
          .toList();
    }

    return apps;
  }

  static Future<List<MailApp>> _getIosMailApps() async {
    var installedApps = <MailApp>[];
    for (var app in _supportedMailApps) {
      if (await canLaunch(app.iosLaunchScheme) && !_filterList.contains(app.name.toLowerCase())) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }

  /// Clears existing filter list and sets the filter list to the passed values.
  /// Filter list is case insensitive. Listed apps will be excluded from the results
  /// of `getMailApps` by name.
  ///
  /// Default filter list includes PayPal, since it implements the mailto: intent-filter
  /// on Android, but the intention of this plugin is to provide
  /// a utility for finding and opening apps dedicated to sending/receiving email.
  static void setFilterList(List<String> filterList) {
    _filterList = filterList.map((e) => e.toLowerCase()).toList();
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
  final EmailContent? emailContent;

  const MailAppPickerDialog({
    Key? key,
    this.title = 'Choose Mail App',
    required this.mailApps,
    this.emailContent,
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
              if (emailContent == null) {
                OpenMailApp.openSpecificMailApp(app);
              } else {
                OpenMailApp.composeNewEmailInSpecificMailApp(
                  mailApp: app,
                  emailContent: emailContent!,
                );
              }

              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class ComposeLaunchScheme {
  String base;
  String to;
  String cc;
  String bcc;
  String subject;
  String body;
  bool composeStarted = false;
  String get qsPairSeparator {
    String separator = !composeStarted ? '?' : '&';
    composeStarted = true;
    return separator;
  }

  ComposeLaunchScheme({
    required this.base,
    this.to = 'to=',
    this.cc = 'cc=',
    this.bcc = 'bcc=',
    this.subject = 'subject=',
    this.body = 'body=',
  });

  String getComposeLaunchScheme(EmailContent content) {
    String scheme = base;
    if (content.to.isNotEmpty) {
      scheme += '$qsPairSeparator${this.to + content.to}';
    }
    if (content.cc.isNotEmpty) {
      scheme += '$qsPairSeparator${this.cc + content.cc}';
    }

    if (content.bcc.isNotEmpty) {
      scheme += '$qsPairSeparator${this.bcc + content.bcc}';
    }

    if (content.subject.isNotEmpty) {
      scheme += '$qsPairSeparator${this.subject + content.subject}';
    }

    if (content.body.isNotEmpty) {
      scheme += '$qsPairSeparator${this.body + content.body}';
    }

    // Reset to make sure you can fetch this multiple times on the same instance.
    composeStarted = false;

    return scheme;
  }

  @override
  String toString() {
    return this.getComposeLaunchScheme(EmailContent());
  }
}

class MailApp {
  final String name;
  final String iosLaunchScheme;
  final ComposeLaunchScheme? _iosComposeLaunchScheme;
  final ComposeLaunchScheme? _androidComposeLaunchScheme;

  const MailApp({
    required this.name,
    required this.iosLaunchScheme,
    ComposeLaunchScheme? androidComposeLaunchScheme,
    ComposeLaunchScheme? iosComposeLaunchScheme,
  })  : this._androidComposeLaunchScheme = androidComposeLaunchScheme,
        this._iosComposeLaunchScheme = iosComposeLaunchScheme;

  factory MailApp.fromJson(Map<String, dynamic> json) => MailApp(
        name: json["name"],
        iosLaunchScheme: json["iosLaunchScheme"],
        iosComposeLaunchScheme: json["iosComposeLaunchScheme"],
        androidComposeLaunchScheme: json["androidComposeLaunchScheme"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "iosLaunchScheme": iosLaunchScheme,
        "iosComposeLaunchScheme": _iosComposeLaunchScheme,
        "androidComposeLaunchScheme": _androidComposeLaunchScheme,
      };

  // String _interpolateQueryParams(String base, EmailContent content) {

  //   return
  // }

  String? composeLaunchScheme(EmailContent content) {
    if (Platform.isAndroid) {
      // return this._androidComposeLaunchScheme;
      return 'TODO';
    } else if (Platform.isIOS) {
      return this._iosComposeLaunchScheme!.getComposeLaunchScheme(content);
    } else {
      throw Exception('Platform not supported');
    }
  }
}

/// Result of calling [OpenMailApp.openMailApp]
///
/// [options] and [canOpen] are only populated and used on iOS
class OpenMailAppResult {
  final bool didOpen;
  final List<MailApp> options;

  bool get canOpen => options.isNotEmpty;

  OpenMailAppResult({
    required this.didOpen,
    this.options = const <MailApp>[],
  });
}

/// Used to populate the precomposed emails
///
/// [to] List of Addressees, will be joined on a ,
/// [cc] Carbon Copy list, will be joined on a,
/// [bcc] Blind carbon copy list, will be joined on a,
/// [subject] [String], getter returns [Uri.encodeComponent] from the set [String]
/// [body] [String], getter returns [Uri.encodeComponent] from the set [String]
class EmailContent {
  final String to;
  final String cc;
  final String bcc;
  final String _subject;
  String get subject => Uri.encodeComponent(_subject);
  final String _body;
  String get body => Uri.encodeComponent(_body);

  EmailContent({
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
  })  : this.to = (to ?? const []).join(','),
        this.cc = (cc ?? const []).join(','),
        this.bcc = (bcc ?? const []).join(','),
        this._subject = subject ?? '',
        this._body = body ?? '';
}
