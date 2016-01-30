//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

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
            let alert = UIAlertController(title: "Team Updated", message: "Weight: \(weight!) lbs. \n Driver XP: \(driverXp!) yrs. \n Added to Team \(teamNumber!)", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: dismissAlert))
            
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            //Alert that the team does not exist
            let alert = UIAlertController(title: "Team Doesn't Exist", message: "The team you entered does not exist in the local databse", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
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
            //Set up the camera view and present it
            imageController.delegate = self
            imageController.sourceType = .Camera
            presentViewController(imageController, animated: true, completion: nil)
            
            //Add observer for the new image notification
            observer = notificationCenter.addObserverForName("newImage", object: self, queue: nil, usingBlock: {(notification: NSNotification) in self.setPhoto(frontOrSide, image: ((notification.userInfo!) as! [String: UIImage])["image"]!)})
        } else {
            let alert = UIAlertController(title: "No Camera", message: "The device you are using does not have image taking capabilities", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
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
}