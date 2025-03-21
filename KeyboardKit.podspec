# Run `pod lib lint KeyboardKit.podspec' to ensure this is a valid spec.

Pod::Spec.new do |s|
  s.name             = 'KeyboardKit'
  s.version          = '2.4.2'
  s.summary          = 'KeyboardKit helps you create iOS keyboard extensions.'

  s.description      = <<-DESC
KeyboardKit is a Swift library that can be used to create iOS keyboard extensions.
                       DESC

  s.homepage         = 'https://github.com/danielsaidi/KeyboardKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Saidi' => 'daniel.saidi@gmail.com' }
  s.source           = { :git => 'https://github.com/evtuhovaleksander/KeyboardKit', :tag => '2.4.2'}
  s.social_media_url = 'https://twitter.com/danielsaidi'
  s.resources = "KeyboardKit/**/*.xib"
    s.resource_bundles = {
    'KeyboardKit' => [
    'Pod/**/*.xib'
    ]
}
  s.ios.deployment_target = '11.0'

  s.source_files = 'KeyboardKit/**/*.swift'
end
