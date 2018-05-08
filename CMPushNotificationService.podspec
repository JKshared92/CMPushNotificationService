#
# Be sure to run `pod lib lint CMPushNotificationService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'CMPushNotificationService'
s.version          = '1.0.3'
s.summary          = '对推送服务的封装'

s.homepage         = 'https://github.com/JKshared92/CMPushNotificationService'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'comma' => '506702341@qq.com' }
s.source           = { :git => 'https://github.com/JKshared92/CMPushNotificationService.git', :tag => "#{s.version}" }

s.subspec "Core" do |core|
    core.source_files        = "CMPushNotificationService/Classes/Core/*.{h,m}"
    core.public_header_files = "CMPushNotificationService/Classes/Core/*.h"
    core.dependency "CMPushNotificationService/JPushLib"
    core.dependency "CMPushNotificationService/XGLib"
  end

s.subspec "JPushLib" do |lib|
    lib.dependency "JPush"
  end

s.subspec "XGLib" do |lib|
    lib.source_files        = "CMPushNotificationService/Classes/XGPushLib/*.{h}"
    lib.vendored_libraries  = "CMPushNotificationService/Classes/XGPushLib/*.{a}"
    lib.public_header_files = "CMPushNotificationService/Classes/XGPushLib/*.{h}"
  end

s.requires_arc       = true
s.static_framework   = true
s.platform           = :ios, "8.0"
s.xcconfig           = { 'VALID_ARCHS' =>  'arm64 x86_64',}
s.frameworks         = "UIKit", "CFNetwork", "CoreFoundation", "CoreTelephony", "SystemConfiguration", "CoreGraphics", "Foundation", "Security"
s.weak_frameworks    = "UserNotifications"
s.libraries          = "resolv", "z", 'sqlite3'
end
