//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PitScoutingController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //IBOutlets
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var sideImage: UIImageView!
    @IBOutlet weak var driverXpField: UITextField!
    @IBOutlet weak var validTeamSymbol: UIImageView!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
	@IBOutlet weak var visionTrackingSlider: UISlider!
	@IBOutlet weak var driveTrainField: UITextField!
	@IBOutlet weak var heightField: UITextField!
	@IBOutlet var defenseButtons: [UIButton]!
	@IBOutlet weak var gamePartSelector: UISegmentedControl!
    
    let dataManager = TeamDataManager()
    let imageController = UIImagePickerController()
    
    var observer: NSObjectProtocol? = nil
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
	
	var selectedTeam: TeamSelection = TeamSelection.Invalid
	
	enum TeamSelection {
		case Invalid
		case Valid(Team)
		
		var optionalTeam: Team? {
			get {
				switch self {
				case .Invalid:
					return nil
				case .Valid(let team):
					return team
				}
			}
		}
		
		var vaild: Bool {
			switch self {
			case .Invalid:
				return false
			case .Valid(_):
				return true
			}
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		dataManager.commitChanges()
	}
    
    @IBAction func desiredTeamEdited(sender: UITextField) {
        if let number = teamNumberField.text {
            if let team = dataManager.getTeams(number).first {
                selectedTeam = .Valid(team)
                validTeamSymbol.image = UIImage(named: "CorrectIcon")
			} else {
                selectedTeam = .Invalid
                validTeamSymbol.image = UIImage(named: "IncorrectIcon")
            }
        }
		
		//Set all the fields to their correct values
		weightField.text = String(selectedTeam.optionalTeam?.robotWeight ?? "") ?? ""
		driverXpField.text = String(selectedTeam.optionalTeam?.driverExp ?? "") ?? ""
		frontImage.image = UIImage(data: (selectedTeam.optionalTeam?.frontImage) ?? NSData())
		sideImage.image = UIImage(data: (selectedTeam.optionalTeam?.sideImage) ?? NSData())
		visionTrackingSlider.setValue((selectedTeam.optionalTeam?.visionTrackingRating?.floatValue) ?? 0, animated: false)
		driveTrainField.text = String(selectedTeam.optionalTeam?.driveTrain ?? "") ?? ""
		heightField.text = String(selectedTeam.optionalTeam?.height ?? "") ?? ""
		setDefensesAbleToCross(forPart: currentGamePart(), inTeam: selectedTeam.optionalTeam)
    }
	
	@IBAction func gamePartChanged(sender: UISegmentedControl) {
		setDefensesAbleToCross(forPart: currentGamePart(), inTeam: selectedTeam.optionalTeam)
	}
	
	func setDefensesAbleToCross(forPart part: GamePart, inTeam team: Team?) {
		//Set all the buttons to not selected
		for defenseButton in defenseButtons {
			setDefenseButton(defenseButton, selected: false)
		}
		
		if let team = team {
			let defenses: [Defense]
			switch part {
			case .Autonomous:
				defenses = team.autonomousDefensesAbleToCross?.allObjects as! [Defense]
			case .Teleop:
				defenses = team.defensesAbleToCross?.allObjects as! [Defense]
			}
			
			//Set the ones that are able to be crossed as selected
			for defense in defenses {
				let defenseButton = defenseButtons.filter() {
					$0.titleForState(.Normal) == defense.defenseName
					}.first!
				setDefenseButton(defenseButton, selected: true)
			}
		}
	}
	
	func setDefenseButton(button: UIButton, selected: Bool) {
		switch selected {
		case true:
			button.layer.borderWidth = 5
			button.layer.borderColor = UIColor.greenColor().CGColor
			button.layer.cornerRadius = 10
		case false:
			button.layer.borderWidth = 0
		}
	}
	
	@IBAction func visionTrackingValueChanged(sender: UISlider) {
		let stepValue = round(sender.value)
		sender.setValue(stepValue, animated: true)
		
		if let team = selectedTeam.optionalTeam {
			team.visionTrackingRating = stepValue
		}
	}
	
	@IBAction func heightEdited(sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.height = Double(sender.text!) ?? 0
		}
	}
	
	@IBAction func driveTrainEdited(sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.driveTrain = sender.text
		}
	}
	
	@IBAction func weightEdited(sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.robotWeight = Double(sender.text!) ?? 0
		}
	}
	
	@IBAction func xpEdited(sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.driverExp = Double(sender.text!) ?? 0
		}
	}
    
    @IBAction func frontPhotoPressed(sender: UIButton) {
        getPhoto(.Front)
    }
    
    @IBAction func sidePhotoPressed(sender: UIButton) {
        getPhoto(.Side)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Dismiss the Cam view
        dismissViewControllerAnimated(true, completion: nil)
        
        //Create and post notification of image selected with userInfo of the image
        let notification = NSNotification(name: "newImage", object: self, userInfo: ["image":image])
        
        notificationCenter.postNotification(notification)
    }
    
    func getPhoto(frontOrSide: imagePOV) {
        //Check to make sure there is a camera
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            //Ask fro permission
            let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if  authStatus != .Authorized && authStatus == .NotDetermined {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
            } else if authStatus == .Denied {
                presentOkAlert("You Have Denied Acces to the Camera", message: "Go to Settings> Privacy> Camera> FAST and turn it on.")
            } else if authStatus == .Authorized {
                //Set up the camera view and present it
                imageController.delegate = self
                imageController.sourceType = .Camera
                presentViewController(imageController, animated: true, completion: nil)
                
                //Add observer for the new image notification
                observer = notificationCenter.addObserverForName("newImage", object: self, queue: nil, usingBlock: {(notification: NSNotification) in self.setPhoto(frontOrSide, image: ((notification.userInfo!) as! [String: UIImage])["image"]!)})
            } else {
                
            }
        } else {
            presentOkAlert("No Camera", message: "The device you are using does not have image taking abilities.")
        }
    }
    
    func setPhoto(frontOrSide: imagePOV, image: UIImage) {
        
        switch frontOrSide {
        case .Front:
			if let team = selectedTeam.optionalTeam {
				team.frontImage = UIImageJPEGRepresentation(image, 1)
			}
            frontImage.image = image
        case .Side:
			if let team = selectedTeam.optionalTeam {
				team.sideImage = UIImageJPEGRepresentation(image, 1)
			}
            sideImage.image = image
        }
        
        //Remove the observer so we don't get repeated commands
        notificationCenter.removeObserver(observer!, name: "newImage", object: self)
    }
	
    enum imagePOV {
        case Front, Side
    }
	
	//Functions for managing the defenses that a team can do
	@IBAction func selectedDefense(sender: UIButton) {
		if sender.layer.borderWidth == 0 {
			//Hasn't been selected previously, set it selected
			setDefenseButton(sender, selected: true)
			
//			sender.layer.shadowOpacity = 0.5
//			sender.layer.shadowColor = UIColor.greenColor().CGColor
//			sender.layer.shadowOffset = CGSizeMake(0, 0)
//			sender.layer.shadowRadius = 10
			
			if let team = selectedTeam.optionalTeam {
				//First, get the defense for the button
				let defense = dataManager.getDefense(withName: sender.titleForState(.Normal)!)
				
				dataManager.addDefense(defense!, toTeam: team, forPart: currentGamePart())
			}
		} else {
			//Was selected, set it not selected
			setDefenseButton(sender, selected: false)
			
			if let team = selectedTeam.optionalTeam {
				let defense = dataManager.getDefense(withName: sender.titleForState(.Normal)!)
				
				dataManager.removeDefense(defense!, fromTeam: team, forPart: currentGamePart())
			}
		}
	}
	
	func currentGamePart() -> GamePart {
		if gamePartSelector.selectedSegmentIndex == 0 {
			return GamePart.Autonomous
		} else {
			return GamePart.Teleop
		}
	}
    
    //Function for presenting a simple alert
    func presentOkAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}