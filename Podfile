source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10'
use_frameworks!

target 'FRC Advanced Scouting Touchstone' do
pod 'Alamofire'
pod 'NYTPhotoViewer'
pod "GMStepper"
pod 'SSBouncyButton', '~> 1.0'
pod 'UICircularProgressRing'
pod 'VTAcknowledgementsViewController'
pod 'TORoundedTableView'
pod 'AWSCore'
pod 'AWSMobileClient'
pod 'AWSUserPoolsSignIn'
pod 'AWSAuthUI'
pod 'AWSAppSync'
pod 'AWSPinpoint'
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