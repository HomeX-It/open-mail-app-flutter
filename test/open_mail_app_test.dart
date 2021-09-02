import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('open_mail_app');
  final log = <MethodCall>[];

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    if (methodCall.method == 'openMailApp') {
      return true;
    }
    return null;
  });

  tearDown(() {
    log.clear();
  });

  test('openMailApp Android', () async {
    OpenMailApp.platform = FakePlatform(operatingSystem: Platform.android);
    final result = await OpenMailApp.openMailApp();
    expect(result.didOpen, true);
    expect(
      log,
      <Matcher>[
        isMethodCall('openMailApp', arguments: {'nativePickerTitle': ''}),
      ],
    );
  });
}
