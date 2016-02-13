//
//  ViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var teamListButton: UIButton!
    @IBOutlet weak var pitScoutingButton: UIButton!
    @IBOutlet weak var standsScoutingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Round all the buttons' corners
        teamListButton.layer.cornerRadius = 10
        teamListButton.clipsToBounds = true
        
        pitScoutingButton.layer.cornerRadius = 10
        pitScoutingButton.clipsToBounds = true
        
        standsScoutingButton.layer.cornerRadius = 10
        standsScoutingButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func teamListPressed(sender: AnyObject) {
        
    }
    
    @IBAction func pitScoutingPressed(sender: AnyObject) {
        
    }

    @IBAction func standsScoutingPressed(sender: AnyObject) {
        
    }
    
    @IBAction func draftBoardPressed(sender: AnyObject) {
    }
}

