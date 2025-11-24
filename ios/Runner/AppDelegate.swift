import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)

    batteryChannel.setMethodCallHandler{(call, result) in 
      if call.method == "getBatteryLevel" {
        self.getBaterryLevel(result:result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getBaterryLevel(result: @escaping FlutterResult) -> Int {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel
    if batteryLevel >= 0 {
      result("\(Int(batteryLevel * 100))%")
    } else {
      result(FlutterError(code: "UNAVAILABLE", message: "Couldn't obtain battery level", details: nil))
    }
  }
  
}
