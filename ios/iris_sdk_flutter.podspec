Pod::Spec.new do |s|
  s.name             = 'iris_sdk_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Flutter bindings for the Iris SDK (passportreader.app).'
  s.description      = <<-DESC
Face verification backed by the vendor Iris SDK, which drives its own
full-screen native camera UI and returns only the final outcome.
                       DESC
  s.homepage         = 'https://github.com/privacybydesign/iris-sdk-flutter'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Yivi' => 'support@yivi.app' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'

  # The vendor framework is committed to this repository, so consumers need no
  # separate download step.
  s.vendored_frameworks = 'PassportReader.xcframework'

  # Matches PassportReader.xcframework's own MinimumOSVersion. Consuming apps
  # must set an iOS deployment target of at least 16.0 or CocoaPods will refuse
  # to integrate this pod.
  s.platform = :ios, '16.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
