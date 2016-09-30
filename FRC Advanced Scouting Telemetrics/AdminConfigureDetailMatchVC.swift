//
//  AdminConfigureDetailMatchVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AdminConfigureDetailMatchVC: UIViewController {
    @IBOutlet weak var blue1Field: UITextField!
    @IBOutlet weak var blue2Field: UITextField!
    @IBOutlet weak var blue3Field: UITextField!
    @IBOutlet weak var red1Field: UITextField!
    @IBOutlet weak var red2Field: UITextField!
    @IBOutlet weak var red3Field: UITextField!
	
	@IBOutlet var textFields: [UITextField]!
	
    let dataManager = TeamDataManager()
    var selectedMatch: Match?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the view, until a match is selected
        view.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewWillChange()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func removedCurrentMatch() {
		view.isHidden = true
	}
	
	func removedMatch(_ match: Match) {
		if match == selectedMatch {
			removedCurrentMatch()
		}
	}
	
    func didSelectMatch(_ match: Match) {
        viewWillChange()
        view.isHidden = false
		
		//Set up the view
		blue1Field.text = nil
		blue2Field.text = nil
		blue3Field.text = nil
		red1Field.text = nil
		red2Field.text = nil
		red3Field.text = nil
		
		//Set the current match
		selectedMatch = match
		
		let teamsAndPlaces = dataManager.getTeamsForMatch(match)
		
		for teamAndPlace in teamsAndPlaces {
			switch Int(teamAndPlace.allianceColor!) {
			case 0:
				switch Int(teamAndPlace.allianceTeam!) {
				case 1:
					blue1Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				case 2:
					blue2Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				case 3:
					blue3Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				default:
					break
				}
			case 1:
				switch Int(teamAndPlace.allianceTeam!) {
				case 1:
					red1Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				case 2:
					red2Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				case 3:
					red3Field.text = (teamAndPlace.regionalPerformance?.value(forKey: "team") as! Team).teamNumber
				default:
					break
				}
			default:
				break
			}
		}
	}
	
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        var isAcceptable: Bool
        
        let teamNumber = sender.text
        
        if !dataManager.getTeams(teamNumber!).isEmpty {
            isAcceptable = true
        } else {
            isAcceptable = false
        }
        
        sender.rightViewMode = .always
        if isAcceptable {
            let correctImageView = UIImageView(image: UIImage(named: "CorrectIcon"))
            correctImageView.contentMode = .scaleAspectFit
            correctImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            sender.rightView = correctImageView
        } else {
            let incorrectImageView = UIImageView(image: UIImage(named: "IncorrectIcon"))
            incorrectImageView.contentMode = .scaleAspectFit
            incorrectImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            sender.rightView = incorrectImageView
        }
	}
	
    func viewWillChange() {
        //Save the match's new data only if the view was shown and if the user was allowed to leave the scene
        if !view.isHidden {
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
			
			//Create an array of all the Teams and Match Places
			let teamsAndPlaces: [TeamDataManager.TeamAndMatchPlace] = [TeamDataManager.TeamAndMatchPlace.blue1(blue1Team), TeamDataManager.TeamAndMatchPlace.blue2(blue2Team), TeamDataManager.TeamAndMatchPlace.blue3(blue3Team), TeamDataManager.TeamAndMatchPlace.red1(red1Team), TeamDataManager.TeamAndMatchPlace.red2(red2Team), TeamDataManager.TeamAndMatchPlace.red3(red3Team)]
			
			//Set the teams in the match
			dataManager.setTeamsInMatch(teamsAndPlaces, inMatch: selectedMatch!)
			
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
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
