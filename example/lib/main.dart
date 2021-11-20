import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Open Mail App Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: Text("Open Mail App"),
              onPressed: () async {
                // Android: Will open mail app or show native picker.
                // iOS: Will open mail app if single mail app found.
                var result = await OpenMailApp.openMailApp(
                  nativePickerTitle: 'Select email app to open',
                );

                // If no mail apps found, show error
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);

                  // iOS: if multiple mail apps found, show dialog to select.
                  // There is no native intent/default app system in iOS so
                  // you have to do it yourself.
                } else if (!result.didOpen && result.canOpen) {
                  OpenMailApp.showMailPicker(
                    context,
                    mailApps: result.options,
                  );
                }
              },
            ),
            ElevatedButton(
              child: Text('Open mail app, with email already composed'),
              onPressed: () async {
                EmailContent email = EmailContent(
                  to: [
                    'user@domain.com',
                  ],
                  subject: 'Hello!',
                  body: 'How are you doing?',
                  cc: ['user2@domain.com', 'user3@domain.com'],
                  bcc: ['boss@domain.com'],
                );

                OpenMailAppResult result =
                    await OpenMailApp.composeNewEmailInMailApp(
                        nativePickerTitle: 'Select email app to compose',
                        emailContent: email);
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);
                } else if (!result.didOpen && result.canOpen) {
                  OpenMailApp.showMailPicker(
                    context,
                    mailApps: result.options,
                    emailContent: email,
                  );
                }
              },
            ),
            ElevatedButton(
              child: Text("Get Mail Apps"),
              onPressed: () async {
                var apps = await OpenMailApp.getMailApps();

                if (apps.isEmpty) {
                  showNoMailAppsDialog(context);
                } else {
                  OpenMailApp.showMailPicker(
                    context,
                    mailApps: apps,
                    emailContent: EmailContent(
                      to: [
                        'user@domain.com',
                      ],
                      subject: 'Hello!',
                      body: 'How are you doing?',
                      cc: ['user2@domain.com', 'user3@domain.com'],
                      bcc: ['boss@domain.com'],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
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
            TextButton(
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
