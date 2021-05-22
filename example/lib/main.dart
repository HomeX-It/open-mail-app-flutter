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
                  OpenMailApp.showNoMailAppsDialog(context);

                  // iOS: if multiple mail apps found, show dialog to select.
                  // There is no native intent/default app system in iOS so
                  // you have to do it yourself.
                } else if (!result.didOpen && result.canOpen) {
                  OpenMailApp.showMailAppList(context, result.options);
                }
              },
            ),
            ElevatedButton(
              child: Text("Get Mail Apps"),
              onPressed: () async {
                var apps = await OpenMailApp.getMailApps();
                if (apps.isEmpty) {
                  OpenMailApp.showNoMailAppsDialog(context);
                } else {
                  OpenMailApp.showMailAppList(context, apps);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
