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
      ref: v1.0.0
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

The Swift call in `ios/Classes/IrisSdkFlutterPlugin.swift` is derived from the
framework's Objective-C header via the standard Clang-importer naming rules and
has not yet been compiled against a real Xcode toolchain. Confirm it on the
first iOS build.

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
