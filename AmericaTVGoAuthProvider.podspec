Pod::Spec.new do |s|
  s.name             = 'AmericaTVGoAuthProvider-iOS'
  s.version          = '1.0.0'
  s.summary          = 'AmericaTVGo Authorization Client'
  s.description      = <<-DESC
AmericaTVGo Authorization Client
                       DESC

  s.homepage         = 'https://github.com/applicaster/AmericaTVGoAuthProvider-iOS.git'
  s.license          = ''
  s.author           = { 'roi kedarya' => 'r.kedarya@applicaster.com' }
  s.source           = { :git => 'git@github.com:applicaster/AmericaTVGoAuthProvider-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'AmericaTVGoAuthProvider/Classes/**/*'
  s.public_header_files  = 'AmericaTVGoAuthProvider/Classes/**/*.h'
  s.requires_arc = true
  s.dependency 'ApplicasterSDK'
  s.resources = [
    "AmericaTVGoAuthProvider/Resources/*.*"
  ]

  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                      'SWIFT_VERSION' => '4.2',
                      'ENABLE_BITCODE' => 'YES'
                  }

  s.dependency 'ApplicasterSDK'

end