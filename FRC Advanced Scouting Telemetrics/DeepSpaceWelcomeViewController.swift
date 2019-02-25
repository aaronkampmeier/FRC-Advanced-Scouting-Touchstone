//
//  DeepSpaceWelcomeViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/24/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

class DeepSpaceWelcomeViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImage(named: "FIRST-DeepSpace-Background-Stars")
        let imageView = UIImageView(image: image)
        imageView.frame = view.frame
        imageView.contentMode = .scaleAspectFill
        self.view.insertSubview(imageView, at: 0)
        
        button.backgroundColor = UIColor.orange
        button.layer.cornerRadius = 15
        button.setTitleColor(UIColor.white, for: .normal)
        
        descriptionLabel.text = "FAST is ready for the 2019 Deep Space competition with a brand new update that focuses on adaptability, performance, and future development. This includes brand new pit scouting, stands scouting, and statistics designed for the 2019 competition."
        
        //Get the new events
        Globals.appDelegate.appSyncClient?.fetch(query: ListTrackedEventsQuery(), cachePolicy: .fetchIgnoringCacheData, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "DeepSpaceWelcome-ListTrackedEvents", result: result, error: error) {
                if result?.data?.listTrackedEvents?.count ?? 0 > 0 {
                    self.button.setTitle("Get Started With Current Events", for: .normal)
                } else {
                    self.button.setTitle("Add 2019 Event", for: .normal)
                }
            } else {
                
            }
        })
    }
    
    @IBAction func pressedButton(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "HasShownDeepSpaceWelcome")
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
