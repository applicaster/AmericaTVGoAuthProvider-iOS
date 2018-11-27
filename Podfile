platform :ios, '9.0'
use_frameworks!

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:CocoaPods/Specs.git'

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'AmericaTVGoAuthProviderDemoApp' do
    pod 'AmericaTVGoAuthProvider' , :path => 'AmericaTVGoAuthProvider.podspec'
end

target 'AmericaTVGoAuthProvider' do
    pod 'ApplicasterSDK'
    pod 'ZappPlugins'
    pod 'AFNetworking'
    pod 'TPKeyboardAvoiding'
end



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
