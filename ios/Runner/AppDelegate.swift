import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "hibiscus/export", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "saveVideoToGallery":
          guard
            let args = call.arguments as? [String: Any],
            let path = args["path"] as? String
          else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing path", details: nil))
            return
          }
          let url = URL(fileURLWithPath: path)
          if !FileManager.default.fileExists(atPath: url.path) {
            result(FlutterError(code: "NOT_FOUND", message: "File not found", details: nil))
            return
          }
          self.saveVideoToGallery(url: url) { error in
            if let error = error {
              result(FlutterError(code: "SAVE_FAILED", message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveVideoToGallery(url: URL, completion: @escaping (Error?) -> Void) {
    let handleAuthorized: () -> Void = {
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
      }, completionHandler: { success, error in
        DispatchQueue.main.async {
          completion(success ? nil : (error ?? NSError(domain: "hibiscus", code: 1)))
        }
      })
    }

    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        DispatchQueue.main.async {
          switch status {
          case .authorized, .limited:
            handleAuthorized()
          default:
            completion(NSError(domain: "hibiscus", code: 2, userInfo: [NSLocalizedDescriptionKey: "No photo permission"]))
          }
        }
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
          if status == .authorized {
            handleAuthorized()
          } else {
            completion(NSError(domain: "hibiscus", code: 2, userInfo: [NSLocalizedDescriptionKey: "No photo permission"]))
          }
        }
      }
    }
  }
}
