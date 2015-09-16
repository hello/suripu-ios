source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

# UI
pod 'AttributedMarkdown', :git => 'https://github.com/dreamwieber/AttributedMarkdown.git',
                          :commit => '6bf420df77117f519af32a6393520ead4e7848c6',
                          :inhibit_warnings => true
pod 'SORelativeDateTransformer', '~> 1.1.10'
pod 'UIImageEffects', '~> 0.0.1'
pod 'SpinKit', '~> 1.2.0'
pod 'BEMSimpleLineGraph', :git => 'git@github.com:hello/BEMSimpleLineGraph.git',
                          :commit => '201b13c35d4a4bebafd0ca8493387b9dddc717e5'
pod 'NAPickerView', :git => 'git@github.com:hello/NAPickerView.git'
pod 'SVWebViewController', :git => 'https://github.com/TransitApp/SVWebViewController.git'
pod 'MSDynamicsDrawerViewController', '1.5.1'
pod 'ZendeskSDK', :git => 'https://github.com/zendesk/zendesk_sdk_ios.git',
                  :tag => '1.4.0.2'
pod 'UICountingLabel', '~> 1.2.0'
pod 'CGFloatType', '~> 1.3.1'

# Private
pod 'SHSProtoBuf', :git => 'git@github.com:hello/protobuf-objc.git'
pod 'LGBluetooth', :git => 'git@github.com:hello/LGBluetooth.git'
pod 'SenseKit', :git => 'git@github.com:hello/SenseKit.git'

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist',
                   'SleepModel/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

target 'Tests', :exclusive => true do
  pod 'Kiwi'
  pod 'Nocilla'
end
