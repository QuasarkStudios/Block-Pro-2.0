platform :ios, '13.0'

target 'Block Pro' do

  use_frameworks!

  # Pods for Block Pro

pod 'Firebase/Core'
pod 'Firebase/Firestore'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'Firebase/Analytics'
pod 'GoogleSignIn'
pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
pod 'JTAppleCalendar'
pod 'iProgressHUD', '~> 1.1.1' 
pod 'BEMCheckBox'
pod 'SVProgressHUD'
pod 'lottie-ios'
pod 'FavIcon', '~> 3.1.0'


end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
	    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end
