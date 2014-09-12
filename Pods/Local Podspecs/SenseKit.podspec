
Pod::Spec.new do |s|
  s.name             = "SenseKit"
  s.version          = "0.1.0"
  s.summary          = "Toolkit for building Sense apps"
  s.homepage         = "https://github.com/hello/SenseKit"
  s.author           = { "Delisa Mason" => "iskanamagus@gmail.com" }
  s.source           = { :git => "https://github.com/hello/SenseKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.resources = 'Pod/Assets/*.png'

  s.subspec "API" do |ss|
    ss.source_files = 'Pod/Classes/API/*'
    ss.dependency 'FXKeychain', '~> 1.5.1'
    ss.dependency 'AFNetworking', '~> 2.4.1'
  end

  s.subspec "BLE" do |ss|
    ss.source_files = 'Pod/Classes/BLE/**/*.{h,m}'
    ss.dependency 'LGBluetooth', '~> 1.1.4'
    ss.dependency 'SHSProtoBuf'
  end

  s.subspec "Model" do |ss|
    ss.source_files = 'Pod/Classes/Model/*'
    ss.dependency 'YapDatabase', '~> 2.4.3'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
end
