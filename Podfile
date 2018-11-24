source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.2'
use_frameworks!

target 'FRC Advanced Scouting Touchstone' do
pod 'Alamofire'
pod 'NYTPhotoViewer', '~> 1.1.0'
pod "GMStepper", '~> 2.1'
pod 'SSBouncyButton', '~> 1.0'
pod 'UICircularProgressRing'
pod 'VTAcknowledgementsViewController'
pod 'RealmSwift', '~> 3.7.1'
pod 'TORoundedTableView'
pod 'AWSCore'
pod 'AWSMobileClient'
pod 'AWSUserPoolsSignIn'
pod 'AWSAuthUI'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/Pods/Target Support Files/Pods-FRC Advanced Scouting Touchstone/Pods-FRC Advanced Scouting Touchstone-acknowledgements.plist', '/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/FRC Advanced Scouting Telemetrics/Pods-acknowledgments.plist', :remove_destination => true)
end