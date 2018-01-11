//
//  SSPreloadingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import VerticalSlider

class SSPreloadingViewController: UIViewController {
    @IBOutlet weak var fuelTankSlider: VerticalSlider!
    @IBOutlet weak var gearSwitch: UISwitch!
    
    lazy var ssDataManager = SSDataManager.currentSSDataManager()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fuelTankSlider.slider.addTarget(self, action: #selector(didChangeFuelTankSliderValue(_:)), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didChangeGearSwitch(_ sender: UISwitch) {
        ssDataManager.preloadedGear = sender.isOn
    }
    
    @objc func didChangeFuelTankSliderValue(_ sender: UISlider) {
        ssDataManager.preloadedFuel = Double(sender.value)
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
