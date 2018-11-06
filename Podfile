platform :ios, '9.0'
use_frameworks!

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:CocoaPods/Specs.git'

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'AmericaTVGoAuthProvider-iOS' do
    
    pod 'ApplicasterSDK'
    #pod 'ApplicasterSDK' , :path => 'Submodules/ApplicasterSDK/ApplicasterSDK-Dev.podspec'
    #pod AmericaTVGoAuthProvider-iOS , :path => '/Users/roikedarya/Desktop/AmericaTVGoAuthProvider-iOS/AmericaTVGoAuthProvider.podspec'
    
    target 'AmericaTVGoAuthProvider-iOSTests' do
    end
end


