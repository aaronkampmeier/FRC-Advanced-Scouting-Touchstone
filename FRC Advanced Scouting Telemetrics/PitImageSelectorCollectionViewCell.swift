//
//  PitImageSelectorCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Crashlytics

class PitImageSelectorCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var updateHandler: PitScoutingUpdateHandler?
    let imageController = UIImagePickerController()
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        label.text = parameter.label
        updateHandler = parameter.updateHandler
        
        //Set current value
        imageButton.imageView?.contentMode = .scaleAspectFit
        if let currentImage = parameter.currentValue() as? UIImage {
            imageButton.setImage(currentImage, for: .normal)
        } else {
            imageButton.setImage(UIImage.init(named: "Camera"), for: .normal)
        }
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //Ask for permission
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if  authStatus != .authorized && authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {_ in })
            } else if authStatus == .denied {
                let alert = UIAlertController(title: "You Have Denied Acces to the Camera", message: "Go to Settings> Privacy> Camera> FAST and turn it on.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                appDelegate.presentViewControllerOnTop(alert, animated: true)
            } else if authStatus == .authorized {
                //Set up the camera view and present it
                imageController.delegate = self
                imageController.allowsEditing = true
                
                //Figure out which source to use
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    presentImageController(imageController, withSource: .photoLibrary)
                } else {
                    let sourceSelector = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    sourceSelector.addAction(UIAlertAction(title: "Camera", style: .default) {_ in
                        self.presentImageController(self.imageController, withSource: .camera)
                        Answers.logCustomEvent(withName: "Added Team Photo", customAttributes: ["Label":self.label.text ?? "Unknown", "Source":"Camera"])
                    })
                    sourceSelector.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
                        self.presentImageController(self.imageController, withSource: .photoLibrary)
                        Answers.logCustomEvent(withName: "Added Team Photo", customAttributes: ["Label":self.label.text ?? "Unknown", "Source":"Photo Library"])
                    })
                    sourceSelector.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    sourceSelector.popoverPresentationController?.sourceView = sender
                    appDelegate.presentViewControllerOnTop(sourceSelector, animated: true)
                }
            } else {
                
            }
        } else {
            let alert = UIAlertController(title: "No Camera", message: "The device you are using does not have image taking abilities.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            appDelegate.presentViewControllerOnTop(alert, animated: true)
        }
    }
    
    func presentImageController(_ controller: UIImagePickerController, withSource source: UIImagePickerControllerSourceType) {
        controller.sourceType = source
        controller.allowsEditing = false
        
        if source == .camera {
            imageController.modalPresentationStyle = .fullScreen
        } else if source == .photoLibrary {
            imageController.modalPresentationStyle = .popover
            imageController.popoverPresentationController?.sourceView = imageButton
        }
        appDelegate.presentViewControllerOnTop(controller, animated: true)
    }
    
}

extension PitImageSelectorCollectionViewCell: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            updateHandler?(image)
            imageButton.setImage(image, for: .normal)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PitImageSelectorCollectionViewCell: UINavigationControllerDelegate {
    
}
