post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end

platform :ios, '8.0'
inhibit_all_warnings!

source 'https://github.com/Cocoapods/Specs.git'

target 'TFDropDownMenuDemo' do
    pod 'TFSegment', :git => 'https://github.com/554994782/TFSegment.git', :branch => ‘develop’
end

target 'TFDropDownMenu' do
end

