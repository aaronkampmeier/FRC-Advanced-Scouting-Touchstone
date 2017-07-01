//
//  HiddenDebugViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 4/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

class HiddenDebugViewController: UIViewController {
    @IBOutlet weak var exitButton: UIButton!
    
	let dataManager = DataManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func exitPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeDuplicatesPressed(_ sender: UIButton) {
        //Get all the localMatchPerformances
        do {
            let localMatchPerformances = try DataManager.managedContext.fetch(LocalMatchPerformance.fetchRequest()) as! [LocalMatchPerformance]
            
            for localMatchPerformance in localMatchPerformances {
                var accountedForIds = [(String, String?, TimeInterval?)]()
                //First the time markers
                let timeMarkers = localMatchPerformance.timeMarkers?.array as! [TimeMarker]
                for marker in timeMarkers {
                    let accountedId = ("TM", marker.scoutID, marker.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already a time marker with this scout id and time, so remove this one
                        dataManager.delete(marker)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
                
                //Fuel Loading
                let floadings = localMatchPerformance.fuelLoadings?.allObjects as! [FuelLoading]
                for object in floadings {
                    let accountedId = ("FL", object.scoutID, object.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already an object with this scout id and time, so remove this one
                        dataManager.delete(object)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
                
                //Fuel Scoring
                let fscorings = localMatchPerformance.fuelScorings?.allObjects as! [FuelScoring]
                for object in fscorings {
                    let accountedId = ("FS", object.scoutID, object.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already an object with this scout id and time, so remove this one
                        dataManager.delete(object)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
                
                //Gear Loading
                let gloadings = localMatchPerformance.gearLoadings?.allObjects as! [GearLoading]
                for object in gloadings {
                    let accountedId = ("GL", object.scoutID, object.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already a time marker with this scout id and time, so remove this one
                        dataManager.delete(object)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
                
                //Gear Scorings
                let gscorings = localMatchPerformance.gearMountings?.allObjects as! [GearMounting]
                for object in gscorings {
                    let accountedId = ("GS", object.scoutID, object.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already a time marker with this scout id and time, so remove this one
                        dataManager.delete(object)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
                
                //Defendings
                let defendings = localMatchPerformance.defendings?.allObjects as! [Defending]
                for object in defendings {
                    let accountedId = ("D", object.scoutID, object.time?.doubleValue)
                    if accountedForIds.contains(where: {$0.0 == accountedId.0 && $0.1 == accountedId.1 && $0.2 == accountedId.2}) {
                        //There is already a time marker with this scout id and time, so remove this one
                        dataManager.delete(object)
                    } else {
                        accountedForIds.append(accountedId)
                    }
                }
            }
            
            CLSNSLogv("Removed Duplicates", getVaList([]))
        } catch {
            CLSNSLogv("Error removing duplicates: \(error)", getVaList([]))
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
