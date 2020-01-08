source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10'
use_frameworks!

target 'FRC Advanced Scouting Touchstone' do
pod 'Alamofire'
pod 'Firebase/Analytics'
pod 'Firebase/Performance'
pod 'Fabric', '~> 1.10.2'
pod 'Crashlytics', '~> 3.14.0'
pod 'NYTPhotoViewer'
pod "GMStepper"
pod "SSBouncyButton"
pod 'UICircularProgressRing'
pod 'VTAcknowledgementsViewController'
pod 'TORoundedTableView'
pod 'AWSCore', '~> 2.12.3'
pod 'AWSAppSync', '~> 3.0.0'
pod 'AWSMobileClient', '~> 2.12.3'
pod 'AWSUserPoolsSignIn', '~> 2.12.3'
pod 'AWSAuthUI', '~> 2.12.3'
pod 'AWSS3', '~> 2.12.3'
pod 'Charts'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/Pods/Target Support Files/Pods-FRC Advanced Scouting Touchstone/Pods-FRC Advanced Scouting Touchstone-acknowledgements.plist', '/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/FRC Advanced Scouting Telemetrics/Pods-acknowledgments.plist', :remove_destination => true)

end