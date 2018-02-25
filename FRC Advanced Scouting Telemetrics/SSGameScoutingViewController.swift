//
//  SSGameScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/28/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

class SSGameScoutingViewController: UIViewController {
    
    var grabCubeVC: SSOffenseWhereViewController!
    var placeCubeVC: SSOffenseWhereViewController!
    
    lazy var ssDataManager = SSDataManager.currentSSDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        grabCubeVC = storyboard?.instantiateViewController(withIdentifier: "whereVC") as! SSOffenseWhereViewController
        placeCubeVC = storyboard?.instantiateViewController(withIdentifier: "whereVC") as! SSOffenseWhereViewController
        
        grabCubeVC.delegate = self
        grabCubeVC.setUpWithButtons(CubeSource.allValues.map({SSOffenseWhereViewController.Button(title: $0.description, color: UIColor.orange, id: $0.rawValue)}), time: 3)
        grabCubeVC.setPrompt(to: "Grabbed Cube From:")
        
        placeCubeVC.delegate = self
        placeCubeVC.setUpWithButtons(CubeDestination.allValues.map({SSOffenseWhereViewController.Button(title: $0.description, color: UIColor.purple, id: $0.rawValue)}), time: 3)
        placeCubeVC.setPrompt(to: "Placed Cube: ")
        
        
        let initialChildVC = self.childViewControllers.first!
        let nextVC: UIViewController?
        if ssDataManager?.preloadedCube ?? false {
            nextVC = placeCubeVC
        } else {
            nextVC = grabCubeVC
        }
        cycleFromViewController(initialChildVC, toViewController: nextVC!)
        (nextVC as! SSOffenseWhereViewController).show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cycleFromViewController(_ oldVC: UIViewController, toViewController newVC: UIViewController) {
        oldVC.willMove(toParentViewController: nil)
        addChildViewController(newVC)
        
        newVC.view.frame = oldVC.view.frame
        
        transition(from: oldVC, to: newVC, duration: 0, options: UIViewAnimationOptions(), animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMove(toParentViewController: self)})
    }

    @IBAction func didCrossAutoLineChanged(_ sender: UISwitch) {
        ssDataManager?.setDidCrossAutoLine(didCross: sender.isOn)
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

extension SSGameScoutingViewController: WhereDelegate {
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
    
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        if whereVC == grabCubeVC {
            ssDataManager?.saveTimeMarker(event: .GrabbedCube, atTime: ssDataManager!.stopwatch.elapsedTime, withAssociatedLocation: id)
            cycleFromViewController(grabCubeVC, toViewController: placeCubeVC)
            placeCubeVC.show()
        } else if whereVC == placeCubeVC {
            ssDataManager?.saveTimeMarker(event: .PlacedCube, atTime: ssDataManager!.stopwatch.elapsedTime, withAssociatedLocation: id)
            cycleFromViewController(placeCubeVC, toViewController: grabCubeVC)
            grabCubeVC.show()
        }
    }
}
