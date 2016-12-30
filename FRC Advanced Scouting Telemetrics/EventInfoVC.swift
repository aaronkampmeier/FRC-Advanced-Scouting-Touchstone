//
//  EventInfoVCViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

class EventInfoVC: UIViewController {
    var selectedEvent: FRCEvent?

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventShortName: UILabel!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var firstFMS: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
        eventShortName.text = selectedEvent?.shortName
        eventType.text = selectedEvent?.eventTypeString
        year.text = selectedEvent?.year.description
        address.text = selectedEvent?.venueAddress
        website.text = selectedEvent?.website
        firstFMS.text = selectedEvent?.official.description.capitalized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //Create a cloud event import object and begin the import process
        if let frcEvent = selectedEvent {
            let cloudImport = CloudEventImportManager(shouldPreload: true, forEvent: frcEvent, withCompletionHandler: finishedImport)
            cloudImport.import()
            activityIndicator.startAnimating()
            loadingView.isHidden = false
        }
    }
    
    func finishedImport(didComplete: Bool, withError error: CloudEventImportManager.ImportError?) {
        if didComplete {
            NSLog("Did complete event import")
            if let error = error {
                NSLog("With error: \(error)")
            }
            
            performSegue(withIdentifier: "unwindToAdminConsoleFromEventAdd", sender: self)
        } else {
            let errorMessage: String?
            if let error = error {
                CLSNSLogv("Didn't complete event import with error: \(error)", getVaList([]))
                errorMessage = error.localizedDescription
            } else {
                CLSNSLogv("Didn't complete event import", getVaList([]))
                errorMessage = nil
            }
            
            let alert = UIAlertController(title: "Unable to Add", message: "An error occurred when adding the event \(errorMessage)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
