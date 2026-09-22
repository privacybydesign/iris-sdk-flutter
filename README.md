# iris_sdk_flutter

Flutter bindings for the **Iris SDK** from [passportreader.app](https://passportreader.app)
— a vendor-owned face-verification engine that drives its own full-screen
native camera UI.

Unlike a headless pipeline, there is no per-frame event stream to hook into:
you hand `verify()` a reference portrait, the SDK presents its flow, and you
get back the outcome.

## Using it

Both Yivi apps consume this package straight from git — the vendor binaries are
committed here, so there is no separate download or setup step:

```yaml
dependencies:
  iris_sdk_flutter:
    git:
      url: https://github.com/privacybydesign/iris-sdk-flutter.git
      ref: v1.0.1
```

```dart
import 'package:iris_sdk_flutter/iris_sdk_flutter.dart';

final verifier = IrisFaceVerifier();
final result = await verifier.verify(portraitPng); // PNG bytes, e.g. the NFC DG2 photo

switch (result.outcome) {
  case IrisVerificationOutcome.matched:
    // result.face holds the captured live face crop.
  case IrisVerificationOutcome.failed:
  case IrisVerificationOutcome.cancelled:
}
```

## The vendor renamed the SDK

What used to ship as `iris.aar` / `Iris.xcframework` with an `iris.Iris` entry
point is now `PassportReader.aar` / `PassportReader.xcframework` with
`passportreader.PassportReader`. The package keeps the Iris name; the bindings
target the current `PassportReader` API.

The SDK exposes more than face verification — `start`, `startMRZScan`,
`startChipRead` and `startQRCodeScan` are all on the same class. Only
`startFaceVerification` is bridged here.

## What consuming apps inherit

**Android.** The `.aar`'s own manifest merges `INTERNET`, `VIBRATE`, `CAMERA`
and `NFC` permissions plus `android.hardware.camera` and `android.hardware.nfc`
features into the app. Those `<uses-feature>` entries default to
`required="true"`, which hides the app on Google Play from devices without a
camera or NFC — override with `required="false"` in the app manifest if that
isn't wanted. The SDK requires `minSdk 26`.

**iOS.** The framework's `MinimumOSVersion` is **16.0**, so a consuming app
needs an iOS deployment target of at least 16.0 in both its Podfile and Xcode
project or CocoaPods will refuse to integrate the pod. The xcframework ships
`ios-arm64` and `ios-arm64-simulator` slices only — no Intel simulator slice,
so it will not build for a simulator on an Intel Mac.

The Swift call in `ios/iris_sdk_flutter/Sources/iris_sdk_flutter/IrisSdkFlutterPlugin.swift`
is derived from the framework's Objective-C header via the standard
Clang-importer naming rules. It does compile and link against the real
framework — the `Build iOS` check below builds the example app on every push,
so a vendor rename breaks CI rather than a consuming app.

## Swift Package Manager

The iOS side ships both a CocoaPods podspec and a Swift package, the way
Flutter's own plugins do. Apps pick whichever they use; both read the same
sources and the same xcframework:

```
ios/iris_sdk_flutter.podspec                       CocoaPods entry point
ios/iris_sdk_flutter/Package.swift                 SPM entry point
ios/iris_sdk_flutter/Sources/iris_sdk_flutter/     Swift sources (shared)
ios/iris_sdk_flutter/PassportReader.xcframework/   vendor SDK (shared)
```

The xcframework sits inside the Swift package directory because an SPM
`binaryTarget` path has to stay within the package root; the podspec reaches
down into that directory for it.

Two things to know before switching an app over:

- Swift Package Manager is **off by default** and is enabled per machine with
  `flutter config --enable-swift-package-manager`.
- `Package.swift` declares its Flutter dependency as `FlutterFramework`, which
  is what Flutter 3.47 generates. Older SDKs generated a package named
  `Flutter` instead, so this manifest needs **3.47 or newer**. irmamobile's CI
  pins 3.47.0; vcmrtd's pins 3.38.4 and would need bumping first.

Nothing breaks in the meantime — the podspec stays authoritative for any app
that hasn't enabled SPM.

## Example app

`example/` is a one-screen host app: it reads the SDK version over the method
channel and runs a verification against a blank placeholder portrait.

```
cd example
flutter run
```

It exists to prove the package builds and links on both platforms, not to
demonstrate a real flow — the placeholder portrait has no face in it, so
verification is expected to fail. Reading the version already exercises the
whole chain: Dart → method channel → native plugin → the bundled vendor binary.

The example carries the platform minimums a consuming app inherits, and is
worth copying from: `minSdk 26` in `android/app/build.gradle.kts`, `platform
:ios, '16.0'` in the Podfile alongside a matching `IPHONEOS_DEPLOYMENT_TARGET`,
and `NSCameraUsageDescription` in `Info.plist`.

## CI

`.github/workflows/ci.yml` runs three status checks on every pull request:

| Check | What it proves |
| --- | --- |
| `Analyze & test` | Formatting, analysis and the Dart tests, for the package and the example both. |
| `Build Android` | `PassportReader.aar` merges into a consuming app — manifest, resources and JNI libs included. |
| `Build iOS` | The Swift bridge compiles and `PassportReader.xcframework` links, for an arm64 device. |

Neither native build is signed, so no signing credentials are involved.
`FLUTTER_VERSION` at the top of the workflow pins the toolchain — keep it in
step with the consuming apps.

## Updating the SDK

1. Drop the new `PassportReader.aar` into `android/libs/` and the unzipped
   `PassportReader.xcframework` into `ios/`.
2. Check the API surface still matches (`javap -classpath classes.jar
   passportreader.PassportReader` for Android, `Headers/PassportReader.h` for
   iOS) — the vendor has renamed things before.
3. Bump `version:` in `pubspec.yaml` and the podspec, tag the repo, and move
   the `ref:` in each consuming app.

The binaries are ~49 MB together and are committed rather than fetched, so each
vendor update adds that much to this repository's history permanently. That is
the deliberate trade for consumers needing nothing but a `ref:` bump.
