platform :ios, '9.0'
use_frameworks!

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:CocoaPods/Specs.git'

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'AmericaTVGoAuthClient' do
    
    pod 'ApplicasterSDK', :path => 'Submodules/ApplicasterSDK/ApplicasterSDK-Dev.podspec'
    
    target 'AmericaTVGoAuthClientTests' do
    end
end


