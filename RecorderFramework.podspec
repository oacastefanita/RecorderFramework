#
# Be sure to run `pod lib lint RecorderFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RecorderFramework'
  s.version          = '0.1.66'
  s.summary          = 'A short description of RecorderFramework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/oacastefanita/RecorderFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'oacastefanita' => 'oacastefanita@gmail.com' }
  s.source           = { :git => 'https://github.com/oacastefanita/RecorderFramework.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.2'
  s.tvos.deployment_target = '10.13'
  s.osx.deployment_target  = '10.12'

  s.source_files = 'RecorderFramework/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RecorderFramework' => ['RecorderFramework/Assets/*.png']
  # }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreAudio', 'CoreFoundation'
  s.dependency 'Alamofire'
end
