//
//  OffenseSSViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/7/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import GMStepper

class OffenseSSViewController: UIViewController {
    @IBOutlet weak var highLoaderFuelStepper: GMStepper!
    @IBOutlet weak var lowLoaderFuelStepper: GMStepper!
    @IBOutlet weak var airShipGearsLoaded: GMStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        highLoaderFuelStepper.layer.cornerRadius = 7
        lowLoaderFuelStepper.layer.cornerRadius = 7
        airShipGearsLoaded.layer.cornerRadius = 7
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
