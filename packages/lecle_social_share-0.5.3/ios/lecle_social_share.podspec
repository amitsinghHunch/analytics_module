#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint lecle_social_share.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'lecle_social_share'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter project support share data to social media (Facebook, Instagram, etc.)'
  s.description      = <<-DESC
A Flutter project support share data to social media (Facebook, Instagram, etc.)
                       DESC
  s.homepage         = 'http://lecle.vn'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'

   s.dependency 'FBSDKCoreKit', '16.2.0'
   s.dependency 'FBSDKShareKit', '16.2.0'
   s.dependency 'TwitterKit5', '5.2.0'
  #  s.dependency 'TikTokOpenSDK', '~> 5.0.13'
   s.platform = :ios, '11.0'

   s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'
end
