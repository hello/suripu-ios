source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

ENV['COCOAPODS_DISABLE_STATS'] = '1'

# UI
pod 'SORelativeDateTransformer', '~> 1.1.10'
pod 'UIImageEffects', '~> 0.0.1'
pod 'SpinKit', '~> 1.2.0'
pod 'SVWebViewController', :git => 'https://github.com/TransitApp/SVWebViewController.git'
pod 'MSDynamicsDrawerViewController', '1.5.1'
pod 'ZendeskSDK', :git => 'https://github.com/zendesk/zendesk_sdk_ios.git',
                  :tag => '1.5.4.1'
pod 'UICountingLabel', '~> 1.2.0'
pod 'CGFloatType', '~> 1.3.1'
pod 'Analytics', '3.0.7'
pod 'Bugsnag', '~> 4.1.0'

# Private
pod 'NAPickerView', :git => 'git@github.com:hello/NAPickerView.git'
pod 'BEMSimpleLineGraph', :git => 'git@github.com:hello/BEMSimpleLineGraph.git'
pod 'SHSProtoBuf', :git => 'git@github.com:hello/protobuf-objc.git'
pod 'LGBluetooth', :git => 'git@github.com:hello/LGBluetooth.git'
pod 'SenseKit', :git => 'git@github.com:hello/SenseKit.git'
pod 'AttributedMarkdown', :git => 'git@github.com:hello/AttributedMarkdown.git',
                          :inhibit_warnings => true

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist',
                   'SleepModel/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

target 'Tests', :exclusive => true do
  pod 'Kiwi'
  pod 'Nocilla'
end
