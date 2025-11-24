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

    channel.setMethodCallHandler{(call, result) in 
      if call.method == "getBatteryLevel" {
        self.getBaterryLevel(result:result)
      } else {
        result(FlutterMethodNotImplemented)
      }
      else if call.method == "takePhoto" {
        self.takePhoto(result:result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getBaterryLevel(result: @escaping FlutterResult) {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel
    if batteryLevel >= 0 {
      result("\(Int(batteryLevel * 100))%")
    } else {
      result(FlutterError(code: "UNAVAILABLE", message: "Couldn't obtain battery level", details: nil))
    }
  }

  private func takePhoto(result: @escaping FlutterResult) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .camera
    imagePickerController.delegate = self
    if let flutterViewController = window?.rootViewController{
       flutterViewController.present(imagePickerController, animated: true)
    }
  }

}

 extension AppDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ) {
      if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
        let imagePath = imageUrl.path

        if let controller = window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)
          channel.invokeMethod("takePhoto", arguments: imagePath)
        }
      }
      picker.dismiss(animated: true, completion: nil)
    }
  }