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
    
    let dataManager = TeamDataManager()
    let imageController = UIImagePickerController()
    
    var observer: NSObjectProtocol? = nil
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
	private var acceptableTeam: Bool {
		get {
			return selectedTeam != nil
		}
		set {
			selectedTeam = dataManager.getTeams(teamNumberField.text!).first
		}
	}
	
	var selectedTeam: Team? //Make sure to check acceptableTeam first
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		dataManager.commitChanges()
	}
    
    @IBAction func desiredTeamEdited(sender: UITextField) {
        if let number = teamNumberField.text {
            if dataManager.getTeams(number).count >= 1 {
                acceptableTeam = true
                validTeamSymbol.image = UIImage(named: "CorrectIcon")
			} else {
                acceptableTeam = false
                validTeamSymbol.image = UIImage(named: "IncorrectIcon")
            }
        }
		
		//Set all the fields to their correct values
		weightField.text = String(selectedTeam?.robotWeight ?? "") ?? ""
		driverXpField.text = String(selectedTeam?.driverExp ?? "") ?? ""
		frontImage.image = UIImage(data: (selectedTeam?.frontImage) ?? NSData())
		sideImage.image = UIImage(data: (selectedTeam?.sideImage) ?? NSData())
    }
	
	@IBAction func weightEdited(sender: UITextField) {
		if acceptableTeam {
			selectedTeam!.robotWeight = Double(sender.text!)
		}
	}
	
	@IBAction func xpEdited(sender: UITextField) {
		if acceptableTeam {
			selectedTeam!.driverExp = Double(sender.text!)
		}
	}
    
    @IBAction func frontPhotoPressed(sender: UIButton) {
        getPhoto(.front)
    }
    
    @IBAction func sidePhotoPressed(sender: UIButton) {
        getPhoto(.side)
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
                presentOkAlert("You Have Denied Acces to the Camera", message: "Go to Settings> Privacy> Camera> FAST and turn it on")
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
            presentOkAlert("No Camera", message: "The device you are using does not have image taking abilities")
        }
    }
    
    func setPhoto(frontOrSide: imagePOV, image: UIImage) {
        
        switch frontOrSide {
        case .front:
            frontImage.image = image
        case .side:
            sideImage.image = image
        }
        
        //Remove the observer so we don't get repeated commands
        notificationCenter.removeObserver(observer!, name: "newImage", object: self)
    }
    
    enum imagePOV {
        case front, side
    }
	
	//Functions for managing the defenses that a team can do
	@IBAction func selectedDefense(sender: UIButton) {
		if sender.layer.borderWidth == 0 {
			//Hasn't been selected previously, set it selected
			sender.layer.borderWidth = 5
			sender.layer.borderColor = UIColor.greenColor().CGColor
			sender.layer.cornerRadius = 10
			
//			sender.layer.shadowOpacity = 0.5
//			sender.layer.shadowColor = UIColor.greenColor().CGColor
//			sender.layer.shadowOffset = CGSizeMake(0, 0)
//			sender.layer.shadowRadius = 10
			
			if acceptableTeam {
				//First, get the defense for the button
				let defense = dataManager.getDefense(withName: sender.titleForState(.Normal)!)
				
				dataManager.addDefense(defense!, toTeam: selectedTeam!)
			}
		} else {
			//Was selected, set it not selected
			sender.layer.borderWidth = 0
			
			if acceptableTeam {
				let defense = dataManager.getDefense(withName: sender.titleForState(.Normal)!)
				
				dataManager.removeDefense(defense!, fromTeam: selectedTeam!)
			}
		}
	}
    
    //Function for presenting a simple alert
    func presentOkAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}