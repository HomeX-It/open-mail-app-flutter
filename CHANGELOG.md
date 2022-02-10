## 0.4.4
- Support Flutter 2.10.0
  - Update Android compileSdkVersion to 31 (Android 12)

## 0.4.3

- Android: migrate from jcenter to mavenCentral
- Updated Gradle to 7.0.2
- Updated Gradle Build Tools to 7.0.4

## 0.4.2
Thanks to deathcoder for the following fix

- Updated Kotlin to 1.6.10
- Updated Gradle to 7.0.2 (example)
- Updated Gradle Build Tools to 7.0.4 (example)

## 0.4.1
Thanks to LosDanieloss for the following fix

- Fix composing a new email on iOS when there is only one email app installed

## 0.4.0

- Added ProtonMail
- Bumped min iOS version to 9

## 0.3.0

- Added the ability to mock platform during testing to make it easier to write tests 

## 0.2.0

- Added possibility to call a specific email app and compose a new email.

## 0.1.1

- Added optional list for filtering mail apps by name.

## 0.1.0

- Null safety stable release

## 0.0.8

Thanks to martyfuhry for the following fix

- Fixed opening mail apps not working on Android when targetSdkVersion is 30

## 0.0.7

Thanks to PrinceGoyal for the following improvement

- Update gradle to 6.7.1 from 5.6.2

## 0.0.6

Thanks to nerder for the following feature

- Added the option to set the title of the native picker for Android
- Added title parameter for MailAppPickerDialog

## 0.0.5

- Fixed MailApp name being null when building on Android when minifyEnabled is set to true

## 0.0.3

Thanks to andrzejchm for the following bug fix.

- Fix null pointer exception on Android

## 0.0.2

- Update description in pubspec

## 0.0.1

- Initial release.
- Open email apps
- Get list of installed email apps
