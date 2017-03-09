//
//  ShotChartViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/22/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol ShotChartDataSource {
    func teamEventPerformance() -> TeamEventPerformance?
}

class ShotChartViewController: UIViewController {
    @IBOutlet weak var allianceColorSelector: UISegmentedControl!
    
    var dataSource: ShotChartDataSource?
    
    var currentAlliance: TeamMatchPerformance.Alliance = .Red {
        didSet {
            switch currentAlliance {
            case .Red:
                cycle(fromChildViewController: self.childViewControllers.first!, toNewViewController: redFieldLocationDisplayController)
            case .Blue:
                cycle(fromChildViewController: self.childViewControllers.first!, toNewViewController: blueFieldLocationDisplayController)
            }
        }
    }
    
    var blueFieldLocationDisplayController: FieldLocationDisplayViewController!
    var redFieldLocationDisplayController: FieldLocationDisplayViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        blueFieldLocationDisplayController = storyboard?.instantiateViewController(withIdentifier: "fieldLocationDisplay") as! FieldLocationDisplayViewController
        redFieldLocationDisplayController = storyboard?.instantiateViewController(withIdentifier: "fieldLocationDisplay") as! FieldLocationDisplayViewController
        blueFieldLocationDisplayController?.dataSource = self
        redFieldLocationDisplayController?.dataSource = self
        
        cycle(fromChildViewController: self.childViewControllers.first!, toNewViewController: redFieldLocationDisplayController)
    }

    func cycle(fromChildViewController childVC: UIViewController, toNewViewController newVC: UIViewController) {
        //Tell the old view controller that he is being moved away, and tell self to add the new view controller
        childVC.willMove(toParentViewController: nil)
        self.addChildViewController(newVC)
        
        //Set the new view's frame to the same as the old one
        newVC.view.frame = childVC.view.frame
        
        transition(from: childVC, to: newVC, duration: 0, options: UIViewAnimationOptions(), animations: nil) {_ in
            //Tell the old view controller to remove itself
            childVC.removeFromParentViewController()
            
            //Tell the new one that he was moved to a new parent (self)
            newVC.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func differentSegmentSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentAlliance = .Red
        } else if sender.selectedSegmentIndex == 1 {
            currentAlliance = .Blue
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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

extension ShotChartViewController: FieldLocationDisplayDataSource {
    func allowsMultiplePoints() -> Bool {
        return true
    }
    
    func allowsAddition() -> Bool {
        return false
    }
    
    func allPoints(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> [CGPoint] {
        var forAlliance: TeamMatchPerformance.Alliance
        switch fieldLocationDisplayVC {
        case blueFieldLocationDisplayController:
            forAlliance = .Blue
        case redFieldLocationDisplayController:
            forAlliance = .Red
        default:
            abort()
        }
        
        if let matchPerformances = dataSource?.teamEventPerformance()?.matchPerformances?.allObjects as? [TeamMatchPerformance] {
            let shots = matchPerformances.reduce([CGPoint]()) {points, matchPerformance in
                if matchPerformance.alliance == forAlliance {
                    var newPoints = [CGPoint]()
                    let matchScorings = (matchPerformance.local.fuelScorings?.allObjects as? [FuelScoring])?.filter {$0.goal == BoilerGoal.HighGoal.rawValue}
                    if let scorings = matchScorings {
                        for scoring in scorings {
                            newPoints.append(CGPoint(x: scoring.xLocation?.doubleValue ?? 0, y: scoring.yLocation?.doubleValue ?? 0))
                        }
                    }
                    
                    return points + newPoints
                } else {
                    return points
                }
            }
            
            return shots
        } else {
            return [CGPoint]()
        }
    }
    
    func fieldImage(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> UIImage {
        switch fieldLocationDisplayVC {
        case blueFieldLocationDisplayController:
            return #imageLiteral(resourceName: "Blue Boiler Map")
        case redFieldLocationDisplayController:
            return #imageLiteral(resourceName: "Red Boiler Map")
        default:
            return UIImage()
        }
    }
}
