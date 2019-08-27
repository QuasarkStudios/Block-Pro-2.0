platform :ios, '9.0'

target 'Block Pro' do

  use_frameworks!

  # Pods for Block Pro

pod 'RealmSwift'
#pod 'ChameleonFramework'
pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
pod 'JTAppleCalendar'
pod 'Firebase/Core'
pod 'Firebase/Firestore'
pod 'Firebase/Auth'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end