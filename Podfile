source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

# UI
pod 'AttributedMarkdown', :git => 'https://github.com/dreamwieber/AttributedMarkdown.git',
                          :commit => '6bf420df77117f519af32a6393520ead4e7848c6'
pod 'SORelativeDateTransformer', '~> 1.1.10'
pod 'SVProgressHUD', :git =>    'https://github.com/samvermette/SVProgressHUD.git',
                     :commit => '90e5921e0a0a782c7e06dd8d308031041c10f789'
pod 'iCarousel', '~> 1.7.6'
pod 'UIImageEffects', '~> 0.0.1'
pod 'SpinKit', '~> 1.2.0'
pod 'BEMSimpleLineGraph'

# Private
pod 'FCDynamicPanesNavigationController', :git => 'git@github.com:hello/FCDynamicPanesNavigationController.git'
pod 'SHSProtoBuf', :git => 'git@github.com:hello/protobuf-objc.git'
pod 'SenseKit', :git => 'git@github.com:hello/SenseKit.git'
# pod 'SenseKit', :path => '../SenseKit'

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist',
                   'SleepModel/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

target 'Tests', :exclusive => true do
  pod 'Kiwi'
end
