import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var mapsConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Maps key comes from MAPS_API_KEY in ios/Flutter/Secrets.xcconfig
    // (git-ignored) via the GMSApiKey Info.plist entry.
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String, !key.isEmpty {
      GMSServices.provideAPIKey(key)
      mapsConfigured = true
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Without a key a map view would crash on iOS; Dart shows a fallback instead.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "Farm2ForkMaps") {
      let configured = mapsConfigured
      FlutterMethodChannel(name: "farm2fork/maps", binaryMessenger: registrar.messenger())
        .setMethodCallHandler { call, result in
          result(call.method == "isConfigured" ? configured : FlutterMethodNotImplemented)
        }
    }
  }
}
