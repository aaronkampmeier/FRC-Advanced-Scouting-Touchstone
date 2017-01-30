//
//  SSDefenseViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/19/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton

class SSDefenseViewController: UIViewController {
    @IBOutlet weak var teamOneButton: SSBouncyButton!
    @IBOutlet weak var teamTwoButton: SSBouncyButton!
    @IBOutlet weak var teamThreeButton: SSBouncyButton!
    @IBOutlet weak var shootingButton: UIButton!
    @IBOutlet weak var movingButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet var teamButtons: [SSBouncyButton]!

    lazy var ssDataManager = SSDataManager.currentSSDataManager()!
    let stopwatch = Stopwatch()
    var isRunning = false {
        didSet {
            if isRunning {
                stopwatch.start()
                timeElapsedLabel.isHidden = false
                if #available(iOS 10.0, *) {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {timer in
                        if self.stopwatch.isRunning {
                            self.timeElapsedLabel.text = "Duration: \((self.stopwatch.elapsedTime * 10).rounded()/10)"
                        } else {
                            timer.invalidate()
                        }
                    }
                } else {
                    // Fallback on earlier versions
                    //TODO: Make friendly to older versions
                }
            } else {
                stopwatch.stop()
                timeElapsedLabel.isHidden = true
            }
        }
    }
    
    var successfulChooser: SSOffenseWhereViewController! {
        didSet {
            successfulChooser.delegate = self
            successfulChooser.setPrompt(to: "Successful?")
            successfulChooser.setUpWithButtons(buttons: [SSOffenseWhereViewController.Button.init(title: "Yes", color: .brown, id: "Yes"), SSOffenseWhereViewController.Button.init(title: "Somewhat", color: .brown, id: "Somewhat"), SSOffenseWhereViewController.Button.init(title: "No", color: .brown, id: "No")], time: 3)
        }
    }
    
    var opposingTeams: [TeamMatchPerformance] = []
    var selectedOpposingTeam: TeamMatchPerformance? {
        didSet {
            if selectedOpposingTeam != nil {
                shootingButton.isHidden = false
                movingButton.isHidden = false
            } else {
                shootingButton.isHidden = true
                movingButton.isHidden = true
            }
        }
    }
    
    var lastDefendingType: DefenseType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let teamsInMatch = ssDataManager.scoutedMatch.teamPerformances?.allObjects as! [TeamMatchPerformance]
        opposingTeams = teamsInMatch.filter() {teamMatchPerformance in
            return teamMatchPerformance.allianceColor != ssDataManager.scoutedMatchPerformance.allianceColor
        }
        opposingTeams = opposingTeams.sorted() {first, second in
            return first.allianceTeam!.doubleValue < second.allianceTeam!.doubleValue
        }
        assert(opposingTeams.count == 3)
        
        for button in teamButtons {
            button.tintColor = UIColor.brown
            button.backgroundColor = nil
        }
        
        shootingButton.layer.cornerRadius = 10
        movingButton.layer.cornerRadius = 10
        
        //Because the storyboard "Apple Brown" is different than the UIColor brown
        movingButton.backgroundColor = UIColor.brown
        shootingButton.backgroundColor = UIColor.brown
        
        teamOneButton.setTitle("Team \(opposingTeams[0].eventPerformance!.team.teamNumber!)", for: .normal)
        teamOneButton.addTarget(self, action: #selector(selectedTeam(_:)), for: .touchUpInside)
        teamTwoButton.setTitle("Team \(opposingTeams[1].eventPerformance!.team.teamNumber!)", for: .normal)
        teamTwoButton.addTarget(self, action: #selector(selectedTeam(_:)), for: .touchUpInside)
        teamThreeButton.setTitle("Team \(opposingTeams[2].eventPerformance!.team.teamNumber!)", for: .normal)
        teamThreeButton.addTarget(self, action: #selector(selectedTeam(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shootingButtonPressed(_ sender: UIButton) {
        if !isRunning {
            isRunning = true
            movingButton.isHidden = true
            sender.backgroundColor = UIColor.red
            sender.setTitle("End Blocking", for: .normal)
        } else {
            isRunning = false
            movingButton.isHidden = false
            sender.backgroundColor = UIColor.brown
            sender.setTitle("Shooting", for: .normal)
            successfulChooser.show()
            lastDefendingType = .Shooting
        }
    }
    
    @IBAction func movingButtonPressed(_ sender: UIButton) {
        if !isRunning {
            isRunning = true
            shootingButton.isHidden = true
            sender.backgroundColor = UIColor.red
            sender.setTitle("End Blocking", for: .normal)
        } else {
            isRunning = false
            shootingButton.isHidden = false
            sender.backgroundColor = UIColor.brown
            sender.setTitle("Moving", for: .normal)
            successfulChooser.show()
            lastDefendingType = .Moving
        }
    }
    
    func selectedTeam(_ sender: SSBouncyButton) {
        for button in teamButtons {
            button.isSelected = false
        }
        sender.isSelected = true
        switch sender {
        case teamOneButton:
            selectedOpposingTeam = opposingTeams[0]
        case teamTwoButton:
            selectedOpposingTeam = opposingTeams[1]
        case teamThreeButton:
            selectedOpposingTeam = opposingTeams[2]
        default:
            break
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "successfulVC" {
            successfulChooser = segue.destination as! SSOffenseWhereViewController
        }
    }

}

extension SSDefenseViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        switch id {
        default:
            ssDataManager.recordDefending(didDefendOffensiveTeam: selectedOpposingTeam!, withType: lastDefendingType!.description, atTime: ssDataManager.stopwatch.elapsedTime, forDuration: stopwatch.elapsedTime, successfully: id)
        }
    }
    
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
