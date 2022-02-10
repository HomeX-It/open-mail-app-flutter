# Open Mail App Flutter ![Flutter 2.10.0](https://img.shields.io/badge/Flutter-2.10.0-blue)
[![pub package](https://img.shields.io/pub/v/open_mail_app.svg?label=open_mail_app&color=blue)](https://pub.dev/packages/open_mail_app)

A boring but accurate name.

This library provides the ability to query the device for installed email apps and open those apps.

If you just want to compose an email or open any app with a `mailto:` link, you are looking for [url_launcher](https://pub.dev/packages/url_launcher).
## Why
While [url_launcher](https://pub.dev/packages/url_launcher) can help you compose an email or open the default email app, it doesn't give you control over which is opened and it doesn't tell you what is available on the device. This is especially a problem on iOS where only the default [Mail](https://apps.apple.com/us/app/mail/id1108187098) app will be opened, even if the user prefers a different app.
## Setup
iOS requires you to list the URL schemes you would like to query in the `Info.plist` file.

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlegmail</string>
    <string>x-dispatch</string>
    <string>readdle-spark</string>
    <string>airmail</string>
    <string>ms-outlook</string>
    <string>ymail</string>
    <string>fastmail</string>
    <string>superhuman</string>
    <string>protonmail</string>
</array>
```

Please file issues to add popular email apps you would like to see on iOS. They need to be added to both your app's `Info.plist` and in the source of this library. 
## Usage
### Open Mail App With Picker If Multiple
```dart
import 'package:open_mail_app/open_mail_app.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Open Mail App"),
      onPressed: () async {
        // Android: Will open mail app or show native picker.
        // iOS: Will open mail app if single mail app found.
        var result = await OpenMailApp.openMailApp();

        // If no mail apps found, show error
        if (!result.didOpen && !result.canOpen) {
          showNoMailAppsDialog(context);

          // iOS: if multiple mail apps found, show dialog to select.
          // There is no native intent/default app system in iOS so
          // you have to do it yourself.
        } else if (!result.didOpen && result.canOpen) {
          showDialog(
            context: context,
            builder: (_) {
              return MailAppPickerDialog(
                mailApps: result.options,
              );
            },
          );
        }
      },
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
```