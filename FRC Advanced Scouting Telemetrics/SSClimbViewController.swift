//
//  SSRopeClimbViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/29/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class SSClimbViewController: UIViewController {
    
    lazy var ssDataManager = SSDataManager.currentSSDataManager()!
    
    var climbSuccessfulVC: SSOffenseWhereViewController? {
        didSet {
            if let climbSuccessfulVC = climbSuccessfulVC {
                climbSuccessfulVC.delegate = self
                climbSuccessfulVC.setUpWithButtons(ClimbStatus.allValues.map({SSOffenseWhereViewController.Button(title: $0.description, color: UIColor.blue, id: $0.rawValue)}), time: 3)
                climbSuccessfulVC.setPrompt(to: "Rope Climb Status:")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        climbSuccessfulVC?.show()
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
            climbSuccessfulVC = (segue.destination as! SSOffenseWhereViewController)
        }
    }
}

extension SSClimbViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        ssDataManager.recordClimb(id)
    }
    
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
