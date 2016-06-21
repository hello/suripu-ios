source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

abstract_target 'SenseApp' do
    
    pod 'SHSProtoBuf', :git => 'git@github.com:hello/protobuf-objc.git'
    pod 'LGBluetooth', :git => 'git@github.com:hello/LGBluetooth.git'
    pod 'SenseKit', :git => 'git@github.com:hello/SenseKit.git'
    #pod 'SenseKit', :path => '../SenseKit'
    pod 'AttributedMarkdown', :git => 'git@github.com:hello/AttributedMarkdown.git', :inhibit_warnings => true
    pod 'CGFloatType', '~> 1.3.1'
    pod 'SORelativeDateTransformer', '~> 1.1.10'
    
    # the actual Sense iOS app
    target 'Sense' do
        pod 'FBSDKLoginKit', '~> 4.11.0'
        pod 'FBSDKCoreKit', '~> 4.11.0'
        pod 'UIImageEffects', '~> 0.0.1'
        pod 'SVWebViewController', :git => 'https://github.com/TransitApp/SVWebViewController.git'
        pod 'MSDynamicsDrawerViewController', '1.5.1'
        pod 'ZendeskSDK', :git => 'https://github.com/zendesk/zendesk_sdk_ios.git', :tag => '1.5.4.1'
        pod 'UICountingLabel', '~> 1.2.0'
        pod 'Analytics', '3.0.7'
        pod 'Bugsnag', '~> 4.1.0'
        pod 'NAPickerView', :git => 'git@github.com:hello/NAPickerView.git'
        pod 'BEMSimpleLineGraph', :git => 'git@github.com:hello/BEMSimpleLineGraph.git'
    end
    
    # the Sense iOS today extension
    target 'SenseWidget' do
        
    end
    
    # tests for the app
    target 'Tests' do
        inherit! :search_paths
        pod 'Kiwi'
        pod 'Nocilla'
    end
    
end

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-SenseApp-Sense/Pods-SenseApp-Sense-acknowledgements.plist',
                   'SleepModel/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
