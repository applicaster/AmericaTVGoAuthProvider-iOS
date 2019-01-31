Pod::Spec.new do |s|
  s.name             = 'AmericaTVGoAuthProvider'
  s.version          = '1.2.16'
  s.summary          = 'AmericaTVGo Authorization Client'
  s.description      = <<-DESC
AmericaTVGo Authorization Client
                       DESC

  s.homepage         = 'https://github.com/applicaster/AmericaTVGoAuthProvider-iOS.git'
  s.license          = ''
  s.author           = { 'roi kedarya' => 'r.kedarya@applicaster.com' }
  s.source           = { :git => 'git@github.com:applicaster/AmericaTVGoAuthProvider-iOS.git', :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.source_files = 'AmericaTVGoAuthProvider/*.{swift,h,m}'
  s.public_header_files  = 'AmericaTVGoAuthProvider/*.h'
  s.requires_arc = true
  s.resources = [
    "AmericaTVGoAuthProvider/Resources/*.{png,xib}",
    "AmericaTVGoAuthProvider/Resources/iap.plist",
    "AmericaTVGoAuthProvider/Resources/script.js"
  ]

  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                      'SWIFT_VERSION' => '4.2',
                      'ENABLE_BITCODE' => 'YES'
                  }
  s.dependency 'ApplicasterSDK'
  s.dependency 'ZappPlugins'
  s.dependency 'AFNetworking'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'MBProgressHUD'
end
