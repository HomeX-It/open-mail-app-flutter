import 'package:flutter/cupertino.dart';

import 'open_mail_app.dart';

/// A simple dialog for allowing the user to pick and open an email app
/// Use with [OpenMailApp.getMailApps] or [OpenMailApp.openMailApp] to get a
/// list of mail apps installed on the device.
class MailAppPickerDialogIOS extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The title for cancel button of the dialog
  final String cancelButtonTitle;

  /// The mail apps for the dialog to provide as options
  final List<MailApp> mailApps;
  final EmailContent? emailContent;

  const MailAppPickerDialogIOS({
    Key? key,
    required this.title,
    required this.cancelButtonTitle,
    required this.mailApps,
    this.emailContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(title),
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          cancelButtonTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        for (var app in mailApps)
          CupertinoActionSheetAction(
            child: Text(app.name),
            onPressed: () {
              final content = this.emailContent;
              if (content != null) {
                OpenMailApp.composeNewEmailInSpecificMailApp(
                  mailApp: app,
                  emailContent: content,
                );
              } else {
                OpenMailApp.openSpecificMailApp(app);
              }

              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
