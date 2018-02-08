source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.2'
use_frameworks!

target 'FRC Advanced Scouting Touchstone' do
pod 'Alamofire', '~> 4.0'
pod 'NYTPhotoViewer', '~> 1.1.0'
pod "GMStepper"
pod 'VerticalSlider'
pod 'SSBouncyButton', '~> 1.0'
pod 'UICircularProgressRing'
pod 'VTAcknowledgementsViewController'
pod 'RealmSwift'
pod 'TORoundedTableView'
pod 'AWSMobileClient'
pod 'AWSUserPoolsSignIn'
pod 'AWSAuthUI'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/Pods/Target Support Files/Pods-FRC Advanced Scouting Touchstone/Pods-FRC Advanced Scouting Touchstone-acknowledgements.plist', '/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/FRC Advanced Scouting Telemetrics/Pods-acknowledgments.plist', :remove_destination => true)
end