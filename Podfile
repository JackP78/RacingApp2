# Uncomment this line to define a global platform for your project
platform :ios, '8.1'
use_frameworks!
workspace 'ListowelRaces'
xcodeproj 'ListowelRaces.xcodeproj'
target 'ListowelRaces' do
    pod 'Bolts'
    pod 'FBSDKCoreKit', '4.16.1'
    pod 'FBSDKLoginKit', '4.16.1'
    pod 'FBSDKShareKit', '4.16.1'
    #pod 'SwiftValidator', '3.0.3'
    #pod 'Eureka', '2.0.0-beta.1'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git'
    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'SVGPath', :git => 'https://github.com/timrwood/SVGPath.git', :branch => 'swift/3.0'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/RemoteConfig'
    pod 'Firebase/Storage'
    #pod 'GeoFire', '>= 1.2'
    pod 'JSQMessagesViewController'
    pod 'SDWebImage'
    pod 'UIActivityIndicator-for-SDWebImage'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        end
    end
end
