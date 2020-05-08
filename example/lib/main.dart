import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:open_mail_app/open_mail_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Open Mail App Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text("Open Mail App!"),
                onPressed: () {
                  OpenMailApp.openMailApp();
                },
              ),
              RaisedButton(
                child: Text("Get Mail Apps"),
                onPressed: () {
                  OpenMailApp.getMailApps();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
