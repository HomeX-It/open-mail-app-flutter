import Flutter
import UIKit

public class SwiftOpenMailAppPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "open_mail_app", binaryMessenger: registrar.messenger())
    let instance = SwiftOpenMailAppPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
