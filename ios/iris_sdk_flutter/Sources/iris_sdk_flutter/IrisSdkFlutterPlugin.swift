import Flutter
import PassportReader
import UIKit

/// Flutter plugin bridging `IrisFaceVerifier` (Dart) to the Iris SDK.
///
/// The vendor renamed the SDK from Iris to PassportReader, so the module and
/// its entry-point class now share the name `PassportReader`. Swift resolves
/// the bare `PassportReader()` to the type rather than the module; if a future
/// SDK drop makes that ambiguous, a `typealias` is the usual escape hatch.
///
/// The Swift spelling of `startFaceVerification` below is derived from the
/// framework's Objective-C header
/// (`-startFaceVerificationInWindowScene:portrait:completion:failure:cancellation:`)
/// via the standard Clang-importer naming rules. The example app in `example/`
/// is what keeps it honest: CI builds it against the real framework, so a
/// vendor rename fails there rather than in a consuming app.
public class IrisSdkFlutterPlugin: NSObject, FlutterPlugin {
    private let reader = PassportReader()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "iris_sdk_flutter", binaryMessenger: registrar.messenger())
        let instance = IrisSdkFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "version":
            result(reader.version())
        case "verify":
            verify(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func verify(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let portrait = (call.arguments as? FlutterStandardTypedData)?.data else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected the portrait PNG bytes as the call argument", details: nil))
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else {
            result(FlutterError(code: "NO_WINDOW_SCENE", message: "No active UIWindowScene to present the Iris flow", details: nil))
            return
        }

        reader.startFaceVerification(
            in: windowScene,
            portrait: portrait,
            completion: { face in
                result(["outcome": "matched", "face": FlutterStandardTypedData(bytes: face)])
            },
            failure: {
                result(["outcome": "failed", "face": NSNull()])
            },
            cancellation: {
                result(["outcome": "cancelled", "face": NSNull()])
            }
        )
    }
}
