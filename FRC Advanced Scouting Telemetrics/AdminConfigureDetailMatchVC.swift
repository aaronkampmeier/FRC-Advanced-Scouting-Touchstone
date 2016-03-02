//
//  AdminConfigureDetailMatchVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AdminConfigureDetailMatchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var blue1Field: UITextField!
    @IBOutlet weak var blue2Field: UITextField!
    @IBOutlet weak var blue3Field: UITextField!
    @IBOutlet weak var red1Field: UITextField!
    @IBOutlet weak var red2Field: UITextField!
    @IBOutlet weak var red3Field: UITextField!
	
	@IBOutlet weak var catADefensesTable: UITableView!
	@IBOutlet weak var catBDefensesTable: UITableView!
	@IBOutlet weak var catCDefensesTable: UITableView!
	@IBOutlet weak var catDDefensesTable: UITableView!
	
    let datePicker = UIDatePicker()
    let dataManager = TeamDataManager()
    var selectedMatch: Match?
	
	var allowsChange: Bool {
		get {
			if let override = nextAllowsChangeOverride {
				nextAllowsChangeOverride = nil
				return override
			} else {
				//Check to see if there are defenses selected, if there aren't then don't allow the view to change
				if (catADefensesTable.indexPathForSelectedRow != nil && catBDefensesTable.indexPathForSelectedRow != nil && catCDefensesTable.indexPathForSelectedRow != nil && catDDefensesTable.indexPathForSelectedRow != nil) || view.hidden {
					return true
				} else {
					return false
				}
			}
		}
		
		set {
			nextAllowsChangeOverride = newValue
		}
	}
	var nextAllowsChangeOverride: Bool? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the view, until a match is selected
        view.hidden = true
        
        // Do any additional setup after loading the view.
        dateField.inputView = datePicker
		
		//Set the data sources and delegates
		catADefensesTable.dataSource = self
		catADefensesTable.delegate = self
		catBDefensesTable.dataSource = self
		catBDefensesTable.delegate = self
		catCDefensesTable.dataSource = self
		catCDefensesTable.delegate = self
		catDDefensesTable.dataSource = self
		catDDefensesTable.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewWillChange()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func removedCurrentMatch() {
		view.hidden = true
	}
	
	func removedMatch(match: Match) {
		if match == selectedMatch {
			removedCurrentMatch()
		}
	}
	
    func didSelectMatch(match: Match) {
        viewWillChange()
        view.hidden = false
		
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
					blue1Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				case 2:
					blue2Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				case 3:
					blue3Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				default:
					break
				}
			case 1:
				switch Int(teamAndPlace.allianceTeam!) {
				case 1:
					red1Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				case 2:
					red2Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				case 3:
					red3Field.text = (teamAndPlace.regionalPerformance?.valueForKey("team") as! Team).teamNumber
				default:
					break
				}
			default:
				break
			}
		}
		
		//Select the appropriate rows in the table views
		//First get the defenses being used
		let defenses = match.defenses?.allObjects as! [Defense]
		for defense in defenses {
			var first: Bool?
			var defenseTable: UITableView?
			switch defense.category! {
			case "A":
				first = TeamDataManager.CategoryADefense.Portcullis.string == defense.defenseName
				defenseTable = catADefensesTable
			case "B":
				first = TeamDataManager.CategoryBDefense.Moat.string == defense.defenseName
				defenseTable = catBDefensesTable
			case "C":
				first = TeamDataManager.CategoryCDefense.Drawbridge.string == defense.defenseName
				defenseTable = catCDefensesTable
			case "D":
				first = TeamDataManager.CategoryDDefense.RockWall.string == defense.defenseName
				defenseTable = catDDefensesTable
			default:
				break
			}
			
			//Now select the row and notify the delegate
			let indexPath = NSIndexPath.init(forRow: first!.hashValue, inSection: 0)
			defenseTable!.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
			defenseTable?.delegate?.tableView!(defenseTable!, didSelectRowAtIndexPath: indexPath)
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
	
    func viewWillChange() {
        //Save the match's new data only if the view was shown and if the user was allowed to leave the scene
        if !view.hidden && allowsChange {
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
			let teamsAndPlaces: [TeamDataManager.TeamAndMatchPlace] = [TeamDataManager.TeamAndMatchPlace.Blue1(blue1Team), TeamDataManager.TeamAndMatchPlace.Blue2(blue2Team), TeamDataManager.TeamAndMatchPlace.Blue3(blue3Team), TeamDataManager.TeamAndMatchPlace.Red1(red1Team), TeamDataManager.TeamAndMatchPlace.Red2(red2Team), TeamDataManager.TeamAndMatchPlace.Red3(red3Team)]
			
			//Set the teams in the match
			dataManager.setTeamsInMatch(teamsAndPlaces, inMatch: selectedMatch!)
			
			//Now set the defense for the match
			dataManager.setDefenses(inMatch: selectedMatch!, defenseA: defenseA!, defenseB: defenseB!, defenseC: defenseC!, defenseD: defenseD!)
		
			//Next, do some cleanup of the view
			//Remove all the right images on the text fields
			blue1Field.rightView = nil
			blue2Field.rightView = nil
			blue3Field.rightView = nil
			red1Field.rightView = nil
			red2Field.rightView = nil
			red3Field.rightView = nil
			//Deselect all the table view rows
			catADefensesTable.deselectRowAtIndexPath(catADefensesTable.indexPathForSelectedRow!, animated: false)
			catBDefensesTable.deselectRowAtIndexPath(catBDefensesTable.indexPathForSelectedRow!, animated: false)
			catCDefensesTable.deselectRowAtIndexPath(catCDefensesTable.indexPathForSelectedRow!, animated: false)
			catDDefensesTable.deselectRowAtIndexPath(catDDefensesTable.indexPathForSelectedRow!, animated: false)
		}
	}
	
	//DEFENSE TABLE METHODS
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = catADefensesTable.dequeueReusableCellWithIdentifier("cell")
		
		//Set the defense names
		var defenseNames = ["",""]
		switch tableView {
		case catADefensesTable:
			defenseNames[0] = "Portcullis"
			defenseNames[1] = "Cheval de Frise"
		case catBDefensesTable:
			defenseNames[0] = "Moat"
			defenseNames[1] = "Ramparts"
		case catCDefensesTable:
			defenseNames[0] = "Drawbridge"
			defenseNames[1] = "Sally Port"
		case catDDefensesTable:
			defenseNames[0] = "Rock Wall"
			defenseNames[1] = "Rough Terrain"
		default:
			break
		}
		
		//Set the text label
		cell?.textLabel?.text = defenseNames[indexPath.row]
		return cell!
	}
	
	var defenseA: TeamDataManager.CategoryADefense?
	var defenseB: TeamDataManager.CategoryBDefense?
	var defenseC: TeamDataManager.CategoryCDefense?
	var defenseD: TeamDataManager.CategoryDDefense?
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch tableView {
		case catADefensesTable:
			if indexPath.row == 0 {
				defenseA = .Portcullis
			} else {
				defenseA = .ChevalDeFrise
			}
		case catBDefensesTable:
			if indexPath.row == 0 {
				defenseB = .Moat
			} else {
				defenseB = .Ramparts
			}
		case catCDefensesTable:
			if indexPath.row == 0 {
				defenseC = .Drawbridge
			} else {
				defenseC = .SallyPort
			}
		case catDDefensesTable:
			if indexPath.row == 0 {
				defenseD = .RockWall
			} else {
				defenseD = .RoughTerrain
			}
		default:
			break
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
