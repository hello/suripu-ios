source 'https://github.com/CocoaPods/Specs.git'

ENV['COCOAPODS_DISABLE_STATS'] = '1'

def core_libs
    pod 'CGFloatType', '~> 1.3.1'
    pod 'FXKeychain', :path => 'Vendor/'
    pod 'AFNetworking', :git => 'https://github.com/AFNetworking/AFNetworking', :branch => 'kylef/os_obj_use_objc'
end

ENV['COCOAPODS_DISABLE_STATS'] = '1'

def ui_libs
    pod 'AttributedMarkdown',
        :git => 'https://github.com/dreamwieber/AttributedMarkdown.git',
        :commit => '6bf420df77117f519af32a6393520ead4e7848c6',
        :inhibit_warnings => true
    pod 'UIImageEffects', '~> 0.0.1'
    pod 'SpinKit', '~> 1.2.0'
    pod 'BEMSimpleLineGraph',
        :git => 'git@github.com:hello/BEMSimpleLineGraph.git',
        :commit => '201b13c35d4a4bebafd0ca8493387b9dddc717e5'
    pod 'NAPickerView', :git => 'git@github.com:hello/NAPickerView.git'
    pod 'SVWebViewController', :git => 'https://github.com/TransitApp/SVWebViewController.git'
    pod 'MSDynamicsDrawerViewController', '1.5.1'
    pod 'ZendeskSDK',
        :git => 'https://github.com/zendesk/zendesk_sdk_ios.git',
        :tag => '1.4.1.2'
    pod 'UICountingLabel', '~> 1.2.0'
end
# UI

def core_libs
    pod 'CGFloatType', '~> 1.3.1'
    pod 'SORelativeDateTransformer', '~> 1.1.10'

    # Private
    pod 'SHSProtoBuf', :git => 'git@github.com:hello/protobuf-objc.git'
    pod 'LGBluetooth', :git => 'git@github.com:hello/LGBluetooth.git'
    pod 'Mixpanel-simple', :git => 'git@github.com:hello/Mixpanel-simple.git'
    pod 'SenseKit', :git => 'git@github.com:hello/SenseKit.git'
end

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Sense/Pods-Sense-acknowledgements.plist',
                   'SleepModel/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

target 'Sense' do
    ui_libs
    core_libs
end

target 'SenseWidget' do
    platform :ios, '8.0'
    ui_libs
    core_libs
end

target 'Sense Now Extension' do
    platform :watchos, '2.0'
    core_libs
end

target 'Tests', :exclusive => true do
  pod 'Kiwi'
  pod 'Nocilla'
end
