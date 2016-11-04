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
import Crashlytics

class PitScoutingController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProvidesTeam {
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
	@IBOutlet weak var notesButton: UIBarButtonItem!
	@IBOutlet weak var climberSwitch: UISwitch!
	@IBOutlet weak var highGoalSwitch: UISwitch!
	@IBOutlet weak var lowGoalSwitch: UISwitch!
    
    let dataManager = TeamDataManager()
    let imageController = UIImagePickerController()
    
    var observer: NSObjectProtocol? = nil
    
    let notificationCenter = NotificationCenter.default
	
	var selectedTeam: TeamSelection = TeamSelection.invalid {
		didSet {
			switch selectedTeam {
			case .invalid:
				notesButton.isEnabled = false
			case .valid(_):
				notesButton.isEnabled = true
			}
		}
	}
	
	var team: Team {
		switch selectedTeam {
		case .invalid:
			assertionFailure("No selected team")
			fatalError()
		case .valid(let team):
			return team
		}
	}
	
	enum TeamSelection {
		case invalid
		case valid(Team)
		
		var optionalTeam: Team? {
			get {
				switch self {
				case .invalid:
					return nil
				case .valid(let team):
					return team
				}
			}
		}
		
		var vaild: Bool {
			switch self {
			case .invalid:
				return false
			case .valid(_):
				return true
			}
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		teamNumberField.becomeFirstResponder()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		dataManager.commitChanges()
	}
    
    @IBAction func desiredTeamEdited(_ sender: UITextField) {
        if let number = teamNumberField.text {
            if let team = dataManager.getTeams(number).first {
                selectedTeam = .valid(team)
                validTeamSymbol.image = UIImage(named: "CorrectIcon")
			} else {
                selectedTeam = .invalid
                validTeamSymbol.image = UIImage(named: "IncorrectIcon")
            }
        }
		
		//Set all the fields to their correct values
		weightField.text = selectedTeam.optionalTeam?.robotWeight?.stringValue ?? ""
		driverXpField.text = selectedTeam.optionalTeam?.driverExp?.stringValue ?? ""
		frontImage.image = UIImage(data: ((selectedTeam.optionalTeam?.frontImage) ?? Data()) as Data)
		sideImage.image = UIImage(data: ((selectedTeam.optionalTeam?.sideImage) ?? Data()) as Data)
		visionTrackingSlider.setValue((selectedTeam.optionalTeam?.visionTrackingRating?.floatValue) ?? 0, animated: false)
		driveTrainField.text = selectedTeam.optionalTeam?.driveTrain ?? ""
		heightField.text = selectedTeam.optionalTeam?.height?.stringValue ?? ""
		climberSwitch.isOn = selectedTeam.optionalTeam?.climber?.boolValue ?? false
		highGoalSwitch.isOn = selectedTeam.optionalTeam?.highGoal?.boolValue ?? false
		lowGoalSwitch.isOn = selectedTeam.optionalTeam?.lowGoal?.boolValue ?? false
		setDefensesAbleToCross(forPart: currentGamePart(), inTeam: selectedTeam.optionalTeam)
    }
	
	@IBAction func gamePartChanged(_ sender: UISegmentedControl) {
		setDefensesAbleToCross(forPart: currentGamePart(), inTeam: selectedTeam.optionalTeam)
	}
	
	func setDefensesAbleToCross(forPart part: GamePart, inTeam team: Team?) {
		//Set all the buttons to not selected
		for defenseButton in defenseButtons {
			setDefenseButton(defenseButton, state: .notSelected)
		}
		
		if let team = team {
			let defenses: [Defense]
			var autonomousDefensesForShooting: [Defense] = [Defense]()
			switch part {
			case .autonomous:
				defenses = team.autonomousDefensesAbleToCrossArray
				autonomousDefensesForShooting = team.autonomousDefensesAbleToShootArray
			case .teleop:
				defenses = team.defensesAbleToCrossArray
			}
			
			//Set the ones that are able to be crossed as selected
			for defense in defenses {
				let defenseButton = defenseButtons.filter() {
					$0.title(for: UIControlState()) == defense.description
					}.first!
				setDefenseButton(defenseButton, state: .canCross)
			}
			for defense in autonomousDefensesForShooting {
				let defenseButton = defenseButtons.filter() {
					$0.title(for: UIControlState()) == defense.description
					}.first!
				setDefenseButton(defenseButton, state: .canShootFrom)
			}
		}
	}
	
	func setDefenseButton(_ button: UIButton, state: DefenseButtonState) {
		switch state {
		case .canShootFrom:
			button.layer.borderWidth = 5
			button.layer.borderColor = UIColor.blue.cgColor
			button.layer.cornerRadius = 10
		case .canCross:
			button.layer.borderWidth = 5
			button.layer.borderColor = UIColor.green.cgColor
			button.layer.cornerRadius = 10
		case .notSelected:
			button.layer.borderWidth = 0
		}
	}
	
	enum DefenseButtonState {
		case notSelected
		case canCross
		case canShootFrom
	}
	
	@IBAction func visionTrackingValueChanged(_ sender: UISlider) {
		let stepValue = round(sender.value)
		sender.setValue(stepValue, animated: true)
		
		if let team = selectedTeam.optionalTeam {
			team.visionTrackingRating = stepValue as NSNumber?
		}
	}
	
	@IBAction func heightEdited(_ sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.height = Double(sender.text!) as NSNumber?? ?? 0
		}
	}
	
	@IBAction func driveTrainEdited(_ sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.driveTrain = sender.text
		}
	}
	
	@IBAction func weightEdited(_ sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.robotWeight = Double(sender.text!) as NSNumber?? ?? 0
		}
	}
	
	@IBAction func xpEdited(_ sender: UITextField) {
		if let team = selectedTeam.optionalTeam {
			team.driverExp = Double(sender.text!) as NSNumber?? ?? 0
		}
	}
	
	@IBAction func climberSwitched(_ sender: UISwitch) {
		if let team = selectedTeam.optionalTeam {
			team.climber = sender.isOn as NSNumber?
		}
	}
	
	@IBAction func highGoalSwitched(_ sender: UISwitch) {
		if let team = selectedTeam.optionalTeam {
			team.highGoal = sender.isOn as NSNumber?
		}
	}
	
	@IBAction func lowGoalSwitched(_ sender: UISwitch) {
		if let team = selectedTeam.optionalTeam {
			team.lowGoal = sender.isOn as NSNumber?
		}
	}
    
    @IBAction func frontPhotoPressed(_ sender: UIButton) {
        getPhoto(.front, sender: sender)
    }
    
    @IBAction func sidePhotoPressed(_ sender: UIButton) {
		getPhoto(.side, sender: sender)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Dismiss the camera view
        dismiss(animated: true, completion: nil)
        
        //Create and post notification of image selected with userInfo of the image
        let notification = Notification(name: NSNotification.Name("newImage"), object: self, userInfo: ["image":image])
        
        notificationCenter.post(notification)
    }
    
	func getPhoto(_ frontOrSide: imagePOV, sender: UIView!) {
        //Check to make sure there is a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //Ask for permission
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if  authStatus != .authorized && authStatus == .notDetermined {
				AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
			} else if authStatus == .denied {
				presentOkAlert("You Have Denied Acces to the Camera", message: "Go to Settings> Privacy> Camera> FAST and turn it on.")
			} else if authStatus == .authorized {
				//Set up the camera view and present it
				imageController.delegate = self
				imageController.allowsEditing = true
				
				//Figure out which source to use
				if !UIImagePickerController.isSourceTypeAvailable(.camera) {
					presentImageController(imageController, withSource: .camera, forFrontOrSide: frontOrSide, sender: sender)
				} else {
					let sourceSelector = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
					sourceSelector.addAction(UIAlertAction(title: "Camera", style: .default) {_ in
						self.presentImageController(self.imageController, withSource: .camera, forFrontOrSide: frontOrSide, sender: sender)
						Answers.logCustomEvent(withName: "Added Team Photo", customAttributes: ["View":frontOrSide.description, "Source":"Camera"])
						})
					sourceSelector.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
						self.presentImageController(self.imageController, withSource: .photoLibrary, forFrontOrSide: frontOrSide, sender: sender)
						Answers.logCustomEvent(withName: "Added Team Photo", customAttributes: ["View":frontOrSide.description, "Source":"Photo Library"])
						})
					sourceSelector.popoverPresentationController?.sourceView = sender
					present(sourceSelector, animated: true, completion: nil)
				}
            } else {
				
            }
        } else {
            presentOkAlert("No Camera", message: "The device you are using does not have image taking abilities.")
        }
    }
	
	func presentImageController(_ controller: UIImagePickerController, withSource source: UIImagePickerControllerSourceType, forFrontOrSide frontOrSide: imagePOV, sender: UIView!) {
		controller.sourceType = source
		
		if source == .camera {
			imageController.modalPresentationStyle = .fullScreen
		} else {
			imageController.modalPresentationStyle = .popover
			imageController.popoverPresentationController?.sourceView = sender
		}
		present(controller, animated: true, completion: nil)
		
		//Add observer for the new image notification
		observer = notificationCenter.addObserver(forName: NSNotification.Name("newImage"), object: self, queue: nil, using: {(notification: Notification) in self.setPhoto(frontOrSide, image: (((notification as NSNotification).userInfo!) as! [String: UIImage])["image"]!)})
	}
	
    func setPhoto(_ frontOrSide: imagePOV, image: UIImage) {
        
        switch frontOrSide {
        case .front:
			if let team = selectedTeam.optionalTeam {
				team.frontImage = UIImageJPEGRepresentation(image, 1)
			}
            frontImage.image = image
        case .side:
			if let team = selectedTeam.optionalTeam {
				team.sideImage = UIImageJPEGRepresentation(image, 1)
			}
            sideImage.image = image
        }
        
        //Remove the observer so we don't get repeated commands
        notificationCenter.removeObserver(observer!, name: NSNotification.Name("newImage"), object: self)
    }
	
	enum imagePOV: CustomStringConvertible {
        case front, side
		
		var description: String {
			switch self {
			case .front:
				return "Front"
			case .side:
				return "Side"
			}
		}
    }
	
	//Functions for managing the defenses that a team can do
	@IBAction func selectedDefense(_ sender: UIButton) {
		if sender.layer.borderWidth == 0 {
			//Hasn't been selected previously, set it selected
			setDefenseButton(sender, state: .canCross)
			
//			sender.layer.shadowOpacity = 0.5
//			sender.layer.shadowColor = UIColor.greenColor().CGColor
//			sender.layer.shadowOffset = CGSizeMake(0, 0)
//			sender.layer.shadowRadius = 10
			
			if let team = selectedTeam.optionalTeam {
				//First, get the defense for the button
				let defense = Defense(rawValue: sender.title(for: UIControlState())!)
				
				dataManager.addDefense(defense!, toTeam: team, forPart: currentGamePart())
			}
		} else if (sender.layer.borderColor == UIColor.green.cgColor) {
			//Was selected as can cross
			switch currentGamePart() {
			case .autonomous:
				setDefenseButton(sender, state: .canShootFrom)
				if let team = selectedTeam.optionalTeam {
					let defense = Defense(rawValue: sender.title(for: UIControlState())!)
					
					dataManager.setDefenseAbleToShootFrom(defense!, toTeam: team, canShootFrom: true)
				}
			case .teleop:
				setDefenseButton(sender, state: .notSelected)
				if let team = selectedTeam.optionalTeam {
					let defense = Defense(rawValue: sender.title(for: UIControlState())!)
					
					dataManager.removeDefense(defense!, fromTeam: team, forPart: currentGamePart())
				}
			}
		} else if (sender.layer.borderColor == UIColor.blue.cgColor) {
			setDefenseButton(sender, state: .notSelected)
			if let team = selectedTeam.optionalTeam {
				let defense = Defense(rawValue: sender.title(for: UIControlState())!)
				
				dataManager.setDefenseAbleToShootFrom(defense!, toTeam: team, canShootFrom: false)
				dataManager.removeDefense(defense!, fromTeam: team, forPart: currentGamePart())
			}
		}
	}
	
	@IBAction func notesPressed(_ sender: UIBarButtonItem) {
		let notesVC = storyboard?.instantiateViewController(withIdentifier: "notesVC") as! NotesViewController
		notesVC.originatingView = self
		notesVC.preferredContentSize = CGSize(width: 400, height: 500)
		notesVC.modalPresentationStyle = .popover
		let popoverVC = notesVC.popoverPresentationController
		popoverVC?.barButtonItem = sender
		present(notesVC, animated: true, completion: nil)
	}
	
	func currentGamePart() -> GamePart {
		if gamePartSelector.selectedSegmentIndex == 0 {
			return GamePart.autonomous
		} else {
			return GamePart.teleop
		}
	}
    
    //Function for presenting a simple alert
    func presentOkAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
