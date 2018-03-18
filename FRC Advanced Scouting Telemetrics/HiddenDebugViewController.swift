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
    
    @IBAction func action1Pressed(_ sender: UIButton) {
        //Lower all image quals
        let stlEventRanker = RealmController.realmController.syncedRealm.object(ofType: EventRanker.self, forPrimaryKey: "2018ilpe")!
        
        RealmController.realmController.genericWrite(onRealm: .Synced) {
            for team in stlEventRanker.rankedTeams {
                if let teamImageData = team.frontImage {
                    let teamImage = UIImage(data: teamImageData)!
                    
                    let newCompressedData = UIImageJPEGRepresentation(teamImage, 0.01)
                    
                    team.frontImage = newCompressedData
                }
            }
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
