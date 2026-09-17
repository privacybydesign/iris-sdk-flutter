Pod::Spec.new do |s|
  s.name             = 'iris_sdk_flutter'
  s.version          = '1.0.1'
  s.summary          = 'Flutter bindings for the Iris SDK (passportreader.app).'
  s.description      = <<-DESC
Face verification backed by the vendor Iris SDK, which drives its own
full-screen native camera UI and returns only the final outcome.
                       DESC
  s.homepage         = 'https://github.com/privacybydesign/iris-sdk-flutter'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Yivi' => 'support@yivi.app' }
  s.source           = { :path => '.' }
  s.dependency 'Flutter'

  # Sources and the vendor framework live in the Swift package directory so
  # that CocoaPods and Swift Package Manager share one copy of each. Apps on
  # CocoaPods use this podspec; apps with Swift Package Manager enabled use
  # iris_sdk_flutter/Package.swift instead.
  s.source_files        = 'iris_sdk_flutter/Sources/iris_sdk_flutter/**/*.swift'
  s.vendored_frameworks = 'iris_sdk_flutter/PassportReader.xcframework'

  # Matches PassportReader.xcframework's own MinimumOSVersion. Consuming apps
  # must set an iOS deployment target of at least 16.0 or CocoaPods will refuse
  # to integrate the pod.
  s.platform = :ios, '16.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
