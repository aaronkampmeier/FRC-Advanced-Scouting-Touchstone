//
//  AdminConfigureDetailMatchVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AdminConfigureDetailMatchVC: UIViewController {
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var blue1Field: UITextField!
    @IBOutlet weak var blue2Field: UITextField!
    @IBOutlet weak var blue3Field: UITextField!
    @IBOutlet weak var red1Field: UITextField!
    @IBOutlet weak var red2Field: UITextField!
    @IBOutlet weak var red3Field: UITextField!
    
    let datePicker = UIDatePicker()
    let dataManager = TeamDataManager()
    var selectedMatch: Match?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the view, until a match is selected
        view.hidden = true
        
        // Do any additional setup after loading the view.
        dateField.inputView = datePicker
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewWillChange()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectMatch(match: Match) {
        viewWillChange()
        view.hidden = false
        
        //Set the current match
        selectedMatch = match
        
        let teamsAndPlaces = dataManager.getTeamsForMatch(match)
        
        for teamAndPlace in teamsAndPlaces {
            switch teamAndPlace {
            case .Blue1(let team):
                blue1Field.text = team?.teamNumber
            case  .Blue2(let team):
                blue2Field.text = team?.teamNumber
            case .Blue3(let team):
                blue3Field.text = team?.teamNumber
            case .Red1(let team):
                red1Field.text = team?.teamNumber
            case .Red2(let team):
                red2Field.text = team?.teamNumber
            case .Red3(let team):
                red3Field.text = team?.teamNumber
            }
        }
    }
    
    @IBAction func textFieldValueChanged(sender: UITextField) {
        var isAcceptable: Bool
        
        let teamNumber = sender.text
        
        if !dataManager.getTeams(teamNumber!).isEmpty {
            isAcceptable = true
        } else {
            isAcceptable = false
        }
        
        sender.rightViewMode = .Always
        if isAcceptable {
            let correctImageView =  UIImageView(image: UIImage(named: "CorrectIcon"))
            correctImageView.contentMode = .ScaleAspectFit
            correctImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            sender.rightView = correctImageView
        } else {
            let incorrectImageView = UIImageView(image: UIImage(named: "IncorrectIcon"))
            incorrectImageView.contentMode = .ScaleAspectFit
            incorrectImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            sender.rightView = incorrectImageView
        }
    }
    
    @IBAction func textFieldEditingDidEnd(sender: UITextField) {
        
    }
    
    func viewWillChange() {
        //Save the match's new data
        if !view.hidden {
            //First, retrieve all the teams using the values in the text fields
            var blue1Team: Team? {
                let teamArray = self.dataManager.getTeams(self.blue1Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            var blue2Team: Team? {
                let teamArray = self.dataManager.getTeams(self.blue2Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            var blue3Team: Team? {
                let teamArray = self.dataManager.getTeams(self.blue3Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            var red1Team: Team? {
                let teamArray = self.dataManager.getTeams(self.red1Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            var red2Team: Team? {
                let teamArray = self.dataManager.getTeams(self.red2Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            var red3Team: Team? {
                let teamArray = self.dataManager.getTeams(self.red3Field.text!)
                if !teamArray.isEmpty {
                    return teamArray[0]
                } else {
                    return nil
                }
            }
            
            
            var teamsAndPlaces: [TeamDataManager.TeamPlaceInMatch] = []
            
            //Then add the teams to a team place array, if there are any
            if let team = blue1Team {
                teamsAndPlaces.append(.Blue1(team))
            }
            if let team = blue2Team {
                teamsAndPlaces.append(.Blue2(team))
            }
            if let team = blue3Team {
                teamsAndPlaces.append(.Blue3(team))
            }
            if let team = red1Team {
                teamsAndPlaces.append(.Red1(team))
            }
            if let team = red2Team {
                teamsAndPlaces.append(.Red2(team))
            }
            if let team = red3Team {
                teamsAndPlaces.append(.Red3(team))
            }
            
            //Then update the match
            dataManager.addTeamsToMatch(teamsAndPlaces, match: selectedMatch!)
            
            //Next, do some cleanup of the view
            //Remove all the right images on the text fields
            blue1Field.rightView = nil
            blue2Field.rightView = nil
            blue3Field.rightView = nil
            red1Field.rightView = nil
            red2Field.rightView = nil
            red3Field.rightView = nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
