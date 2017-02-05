//
//  SSRopeClimbViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/29/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class SSRopeClimbViewController: UIViewController {
    
    lazy var ssDataManager = SSDataManager.currentSSDataManager()!
    
    var ropeClimbSuccessfulVC: SSOffenseWhereViewController? {
        didSet {
            if let ropeClimbSuccessfulVC = ropeClimbSuccessfulVC {
                ropeClimbSuccessfulVC.delegate = self
                ropeClimbSuccessfulVC.setUpWithButtons([SSOffenseWhereViewController.Button.init(title: "Yes", color: .blue, id: LocalMatchPerformance.RopeClimbSuccess.Yes.rawValue), SSOffenseWhereViewController.Button.init(title: "Somewhat", color: .blue, id: LocalMatchPerformance.RopeClimbSuccess.Somewhat.rawValue), SSOffenseWhereViewController.Button.init(title: "No", color: .blue, id: LocalMatchPerformance.RopeClimbSuccess.No.rawValue)], time: 3)
                ropeClimbSuccessfulVC.setPrompt(to: "Rope Climb Successful")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ropeClimbSuccessfulVC?.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ropeClimbSuccessful" {
            ropeClimbSuccessfulVC = segue.destination as! SSOffenseWhereViewController
        }
    }
}

extension SSRopeClimbViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        ssDataManager.recordRopeClimb(id)
    }
    
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
