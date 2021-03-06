#
# Be sure to run `pod lib lint IZImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IZImagePicker'
  s.version          = '0.2.0'
  s.summary          = 'A subclass for UIImagePicker'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library is to make UIImagePicker easier to use. It makes it so all you need is one function to do everything: handle the camera and library; handle cropping. Implement one function to handle everything and output a usable UIImage.
                       DESC

  s.homepage         = 'https://github.com/izeni-team/IZImagePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Izeni' => 'tallred@izeni.com' }
  s.source           = { :git => 'https://github.com/izeni-team/IZImagePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'IZImagePicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IZImagePicker' => ['IZImagePicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'TOCropViewController'
end
