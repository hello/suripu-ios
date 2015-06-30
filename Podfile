source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

# UI
pod 'AttributedMarkdown', :git => 'https://github.com/dreamwieber/AttributedMarkdown.git',
                          :commit => '6bf420df77117f519af32a6393520ead4e7848c6'
pod 'SORelativeDateTransformer', '~> 1.1.10'
pod 'UIImageEffects', '~> 0.0.1'
pod 'SpinKit', '~> 1.2.0'
pod 'BEMSimpleLineGraph', :git => 'git@github.com:hello/BEMSimpleLineGraph.git',
                          :commit => '0571b7c5e4701b71d3955a6564679875f793fdc4'
pod 'NAPickerView', :git => 'git@github.com:hello/NAPickerView.git'
pod 'FDWaveformView', :git => 'git@github.com:hello/FDWaveformView.git'
pod 'SVWebViewController', :git => 'https://github.com/TransitApp/SVWebViewController.git'
pod 'MSDynamicsDrawerViewController', '1.5.1'
pod 'ZendeskSDK', :git => 'https://github.com/zendesk/zendesk_sdk_ios.git'
pod 'UICountingLabel', '~> 1.2.0'

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
end
