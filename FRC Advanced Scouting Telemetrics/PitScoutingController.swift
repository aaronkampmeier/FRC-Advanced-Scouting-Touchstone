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
    @IBOutlet weak var updateTeamButton: UIButton!
    @IBOutlet weak var driverXpField: UITextField!
    @IBOutlet weak var validTeamSymbol: UIImageView!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
    
    let dataManager = TeamDataManager()
    let imageController = UIImagePickerController()
    
    var observer: NSObjectProtocol? = nil
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    private var acceptableTeam = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTeamButton.layer.cornerRadius = 10
        updateTeamButton.clipsToBounds = true
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
    }
    
    @IBAction func updateTeamPressed(sender: UIButton) {
        
        if acceptableTeam {
            let driverXp = driverXpField.text
            let weight = weightField.text
            let teamNumber = teamNumberField.text
            
            let returnedTeams = dataManager.getTeams(teamNumber!)
            
            for team in returnedTeams {
                
                team.driverExp = Double(driverXp!)!
                team.robotWeight = Double(weight!)!
                team.frontImage = UIImageJPEGRepresentation(frontImage.image!, 1)
                team.sideImage = UIImageJPEGRepresentation(sideImage.image!, 1)
            }
            
            dataManager.save()
            
            //Present Confirmation Alert
            presentOkAlert("Team Updated", message: "Weight: \(weight!) lbs. \n Driver XP: \(driverXp!) yrs. \n Added to Team \(teamNumber!)")
        } else {
            //Alert that the team does not exist
            presentOkAlert("Team Doesn't Exist", message: "The team you entered does not exist in the local databse")
        }
    }
    
    func dismissAlert(alertAction: UIAlertAction) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func frontPhotoPressed(sender: UIButton) {
        getPhoto("front")
    }
    
    @IBAction func sidePhotoPressed(sender: UIButton) {
        getPhoto("side")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Dismiss the Cam view
        dismissViewControllerAnimated(true, completion: nil)
        
        //Create and post notification of image selected with userInfo of the image
        let notification = NSNotification(name: "newImage", object: self, userInfo: ["image":image])
        
        notificationCenter.postNotification(notification)
    }
    
    func getPhoto(frontOrSide: String) {
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
            presentOkAlert("No Camera", message: "The device you are using does not have image taking capabilities")
        }
    }
    
    func setPhoto(frontOrSide: String, image: UIImage) {
        
        switch frontOrSide {
        case "front":
            frontImage.image = image
        case "side":
            sideImage.image = image
        default:
            NSLog("Neither Front Nor Side was for the photo")
        }
        
        //Remove the observer so we don't get repeated commands
        notificationCenter.removeObserver(observer!, name: "newImage", object: self)
    }
    
    //Function for presenting a simple alert
    func presentOkAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}