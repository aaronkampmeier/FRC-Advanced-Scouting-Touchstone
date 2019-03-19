source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10'
use_frameworks!

target 'FRC Advanced Scouting Touchstone' do
pod 'Alamofire'
pod 'Firebase/Core'
pod 'Firebase/Performance'
pod 'Fabric', '~> 1.9.0'
pod 'Crashlytics', '~> 3.12.0'
pod 'NYTPhotoViewer'
pod "GMStepper"
pod "SSBouncyButton"
pod 'UICircularProgressRing'
pod 'VTAcknowledgementsViewController'
pod 'TORoundedTableView'
pod 'AWSCore', '~> 2.9.3'
pod 'AWSAppSync', '~> 2.10.3'
pod 'AWSMobileClient', '~> 2.9.3'
pod 'AWSUserPoolsSignIn', '~> 2.9.3'
pod 'AWSAuthUI', '~> 2.9.3'
pod 'AWSS3', '~> 2.9.3'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/Pods/Target Support Files/Pods-FRC Advanced Scouting Touchstone/Pods-FRC Advanced Scouting Touchstone-acknowledgements.plist', '/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/FRC Advanced Scouting Telemetrics/Pods-acknowledgments.plist', :remove_destination => true)

  installer.pods_project.targets.each do |target|

    puts target.name

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'

    end
  end
end