# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
workspace 'ListowelRaces'
xcodeproj 'ListowelRaces.xcodeproj'
target 'ListowelRaces' do
    pod 'Alamofire', '~> 4.2.0'
    pod 'Bolts'
    pod 'FBSDKCoreKit', '4.27.1'
    pod 'FBSDKLoginKit', '4.27.1'
    pod 'FBSDKShareKit', '4.27.1'
    #pod 'SwiftValidator', '3.0.3'
    pod 'Eureka'
    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'SVGPath'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/RemoteConfig'
    pod 'Firebase/Storage'
    pod 'Firebase/Messaging'
    pod 'FCAlertView'
    pod 'SendBirdSDK'
    #pod 'GeoFire', '>= 1.2'
    pod 'JSQMessagesViewController'
    pod 'IQKeyboardManagerSwift'
    pod 'SDWebImage'
    pod 'UIActivityIndicator-for-SDWebImage'
    pod 'RealmSwift'
    pod 'Gloss', '2.0.0-beta.2'
    pod 'SwiftyJSON'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
