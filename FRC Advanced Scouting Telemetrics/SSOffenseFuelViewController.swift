//
//  SSOffenseFuelViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import VerticalSlider

class SSOffenseFuelViewController: UIViewController {
    @IBOutlet weak var addFuelButton: UIButton!
    @IBOutlet weak var fuelTankSlider: VerticalSlider!
    @IBOutlet weak var setFuelIncreaseLabel: UILabel!
    
    let ssDataManager = SSDataManager.currentSSDataManager()!
    
    var loadingWhereVC: SSOffenseWhereViewController! {
        didSet {
            loadingWhereVC.delegate = self
            loadingWhereVC.setUpWithButtons([FuelLoadingLocations.Hopper.button(.orange), FuelLoadingLocations.LoadingStation.button(.orange), FuelLoadingLocations.Floor.button(.orange)], time: 3)
        }
    }
    var scoringWhereVC: SSOffenseWhereViewController! {
        didSet {
            scoringWhereVC.delegate = self
            scoringWhereVC.setUpWithButtons([BoilerGoal.HighGoal.button(.orange), BoilerGoal.LowGoal.button(.orange)], time: 3)
        }
    }
    
    var hasLoadedFuel: Bool = false {
        didSet {
            if hasLoadedFuel {
                scoringWhereVC.show()
            } else {
                scoringWhereVC.hide()
                setFuelIncreaseLabel.isHidden = true
                fuelTankSlider.slider.isEnabled = false
                fuelTankSlider.slider.value = 0
                currentFuelTankLevel = 0
            }
        }
    }
    var lastFuelLoadingTime: TimeInterval?
    
    var lastSelectedShotLocation: CGPoint?
    var lastScoringShouldSelectHandler: ((Bool)->Void)?
    var lastAccuracy: Float?
    
    var currentFuelTankLevel = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setFuelIncreaseLabel.isHidden = true
        fuelTankSlider.slider.addTarget(self, action: #selector(fuelSliderChanged(_:)), for: .touchUpInside)
        fuelTankSlider.slider.addTarget(self, action: #selector(fuelSliderChanged(_:)), for: .touchUpOutside)
        fuelTankSlider.slider.isEnabled = false
        
        //Account for preloaded fuel
        let preloadedFuel = ssDataManager.preloadedFuel
        if preloadedFuel == 0 {
            hasLoadedFuel = false
        } else {
            hasLoadedFuel = true
        }
        
        fuelTankSlider.slider.value = Float(preloadedFuel)
        currentFuelTankLevel = preloadedFuel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFuelButtonPressed(_ sender: UIButton) {
        loadingWhereVC.show()
        setFuelIncreaseLabel.isHidden = false
        fuelTankSlider.slider.isEnabled = true
        lastFuelLoadingTime = ssDataManager.stopwatch.elapsedTime
    }

    func fuelSliderChanged(_ sender: UISlider) {
        ssDataManager.setAssociatedFuelIncrease(withFuelIncrease: Double(sender.value) - currentFuelTankLevel, afterTime: lastFuelLoadingTime ?? 0)
        currentFuelTankLevel = Double(sender.value)
        fuelTankSlider.slider.isEnabled = false
        setFuelIncreaseLabel.isHidden = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier ?? "" {
        case "loadingWhereVC":
            loadingWhereVC = segue.destination as! SSOffenseWhereViewController
        case "scoringWhereVC":
            scoringWhereVC = segue.destination as! SSOffenseWhereViewController
        default:
            break
        }
    }
    
    enum FuelLoadingLocations: String, CustomStringConvertible, FASTSSButtonable {
        case Hopper
        case LoadingStation = "Loading Station"
        case Floor
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    @IBAction func rewindToSSOffenseFuel(withSegue segue: UIStoryboardSegue) {
        
    }
}

extension BoilerGoal: FASTSSButtonable {
    
}

extension SSOffenseFuelViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        switch whereVC {
        case loadingWhereVC:
            ssDataManager.recordFuelLoading(id, atTime: ssDataManager.stopwatch.elapsedTime)
            hasLoadedFuel = true
        case scoringWhereVC:
            ssDataManager.recordFuelScoring(inGoal: id, atTime: ssDataManager.stopwatch.elapsedTime, scoredFrom: lastSelectedShotLocation ?? CGPoint(x: 0, y: 0), withAmountShot: Double(fuelTankSlider.value), withAccuracy: Double(lastAccuracy ?? 1))
            hasLoadedFuel = false
        default:
            break
        }
    }
    
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        switch whereVC {
        case loadingWhereVC:
            lastAccuracy = 1
            handler(true)
        case scoringWhereVC:
            if id == BoilerGoal.HighGoal.rawValue {
                lastScoringShouldSelectHandler = handler
                let gameFieldLocationNav = storyboard?.instantiateViewController(withIdentifier: "gameFieldLocationNav") as! UINavigationController
                let gameFieldLocation = gameFieldLocationNav.topViewController as! GameFieldLocationViewController
                gameFieldLocation.delegate = self
                present(gameFieldLocationNav, animated: true, completion: nil)
            } else {
                handler(true)
            }
        default:
            break
        }
    }
}

extension SSOffenseFuelViewController: GameFieldLocationDelegate {
    func selectedRelativePoint(_ point: CGPoint, withShotAccuracy accuracy: Float) {
        lastSelectedShotLocation = point
        lastAccuracy = accuracy
        lastScoringShouldSelectHandler?(true)
    }
    
    func canceled() {
        lastScoringShouldSelectHandler?(false)
    }
}
