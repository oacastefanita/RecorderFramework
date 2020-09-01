#
# Be sure to run `pod lib lint RecorderFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RecorderFramework'
  s.version          = '2.0.12'
  s.summary          = 'Recorder SDK used to communicate with Recorder API'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Recorder SDK used to communicate with Recorder API. All data retrieved from the server is locally saved and can be accessed without internet.
                       DESC

  s.homepage         = 'https://github.com/oacastefanita/RecorderFramework'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'oacastefanita' => 'oacastefanita@gmail.com' }
  s.source           = { :git => 'https://github.com/oacastefanita/RecorderFramework.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target  = '10.0'

  s.source_files = 'RecorderFramework/Classes/**/*'
  s.swift_version = '5.0'
  s.frameworks = 'CoreAudio', 'CoreFoundation'
  s.dependency 'Alamofire', '~> 4.0'
  s.ios.dependency 'Mixpanel'
  s.tvos.dependency 'Mixpanel'
  s.macos.dependency 'Mixpanel'
end
