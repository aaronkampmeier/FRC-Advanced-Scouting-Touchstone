//
//  StandsScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

class StandsScoutingViewController: UIViewController {
	@IBOutlet weak var timerButton: UIButton!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var matchAndEventLabel: UILabel!
	@IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var endAutonomousButton: UIButton!
    @IBOutlet weak var autonomousLabel: UILabel!
    
    var teamKey: String?
    var match: Match?
    
    var ssDataManager: SSDataManager?
	
	var isRunning = false {
		willSet {
		if newValue {
			Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StandsScoutingViewController.updateTimeLabel(_:)), userInfo: nil, repeats: true)
			ssDataManager?.stopwatch.start()
			
			//Update the button
			timerButton.setTitle("Stop", for: UIControl.State())
			timerButton.backgroundColor = UIColor.red
			
			//Set appropriate state for elements in the view
			closeButton.isHidden = true
			
			if let currentVC = currentVC, let gameScoutVC = gameScoutVC {
				cycleFromViewController(currentVC, toViewController: gameScoutVC)
			}
            
            endAutonomousButton.isHidden = false
            autonomousLabel.isHidden = false
		} else {
            ssDataManager?.stopwatch.stop()
            
            //Update the button
            timerButton.setTitle("Ended", for: UIControl.State())
            timerButton.backgroundColor = UIColor.gray
            timerButton.isEnabled = false
            
            //Set appropriate state for elements in the view
            closeButton.isHidden = false
            
            //Cycle to the rope view controller
			if let currentVC = currentVC, let gameVC = gameEndVC {
				cycleFromViewController(currentVC, toViewController: gameVC)
			}
            
            endAutonomousButton.isHidden = true
            autonomousLabel.isHidden = true
            
            //Notify Others
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StandsScoutingEnded"), object: self)
        }
        }
	}
	
    //Child view controllers
	var currentVC: UIViewController?
    
    var gameStartVC: SSGameStateViewController?
    var gameScoutVC: SSGameScoutingViewController?
    var gameEndVC: SSGameStateViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		//Get all the view controllers
        gameScoutVC = (storyboard?.instantiateViewController(withIdentifier: "ssGameScoutVC") as! SSGameScoutingViewController)
        gameStartVC = storyboard?.instantiateViewController(withIdentifier: "gameState") as? SSGameStateViewController
        gameEndVC = storyboard?.instantiateViewController(withIdentifier: "gameState") as? SSGameStateViewController
		
		self.timerButton.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.traitCollection.horizontalSizeClass == .regular {
            //Make it look nice
            timerButton.layer.cornerRadius = 10
            closeButton.layer.cornerRadius = 10
            notesButton.layer.cornerRadius = 10
            
            autonomousLabel.layer.cornerRadius = 5
            endAutonomousButton.layer.cornerRadius = 10
        } else {
            //Make it look nice
            timerButton.layer.cornerRadius = 5
            closeButton.layer.cornerRadius = 5
            notesButton.layer.cornerRadius = 5
            
            autonomousLabel.layer.cornerRadius = 2.5
            endAutonomousButton.layer.cornerRadius = 5
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp(forTeamKey teamKey: String, andMatchKey matchKey: String, inEventKey eventKey: String, noLocal: Bool = false) {
        self.teamKey = teamKey
        //Get the match
        Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey), cachePolicy: noLocal ? .fetchIgnoringCacheData : .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListMatches-SetUpStandsScout", result: result, error: error) {
                self?.match = result?.data?.listMatches?.first(where: {$0?.key == matchKey})??.fragments.match
                
                if let match = self?.match {
					self?.teamLabel.text = "Team \(teamKey.trimmingCharacters(in: CharacterSet.letters) )"
                    self?.matchAndEventLabel.text = match.description
                    self?.ssDataManager = SSDataManager(match: match, teamKey: teamKey)
                    
                    self?.gameStartVC?.set(gameSection: .Start)
                    self?.gameEndVC?.set(gameSection: .End)
                    
                    self?.cycleFromViewController(self!.children.first!, toViewController: self!.gameStartVC!)
					self?.timerButton.isEnabled = true
					
                } else {
                    //Throw up an error that the match does not exist
                    CLSNSLogv("Desired Match for stands scouting does not exist or is not stored in the cache, trying again", getVaList([]))
                    self?.setUp(forTeamKey: teamKey, andMatchKey: matchKey, inEventKey: eventKey, noLocal: true)
                    return
                }
            } else {
                //TODO: - Show error
            }
        })
    }
    
    func setUp(forTeamKey teamKey: String, andEventKey eventKey: String) {
        //If no match key is specified, then get all of the matches and offer them up to be selected
        //Eventually calls other setUp method
        Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListMatchesQuery-StandsScout", result: result, error: error) {
                //Filter the matches to only be ones that this team is in
                let filteredMatches = result?.data?.listMatches?.filter({
                    return $0!.alliances?.blue?.teamKeys?.contains(teamKey) ?? false || $0!.alliances?.red?.teamKeys?.contains(teamKey) ?? false
                }) .map({$0!.fragments.match}) ?? []
                
                let sortedMatches = filteredMatches.sorted(by: {$0 < $1})
                
                let askAction = UIAlertController(title: "Select Match", message: "Select the match for Team \(teamKey.trimmingCharacters(in: CharacterSet.letters)) to Stands Scout", preferredStyle: .alert)
                for match in sortedMatches {
                    askAction.addAction(UIAlertAction(title: "\(match.compLevel.description) \(match.matchNumber)", style: .default, handler: {_ in
                        self?.setUp(forTeamKey: teamKey, andMatchKey: match.key, inEventKey: eventKey)
                    }))
                }
                
                askAction.addAction(UIAlertAction(title: "Cancel", style: .cancel) {action in
                    self?.close(andSave: false)
                })
                self?.present(askAction, animated: true, completion: nil)
            } else {
                
            }
        })
    }
	
	@IBAction func closePressed(_ sender: UIButton) {
		if (150 - (ssDataManager?.stopwatch.elapsedTime ?? 0)) > 15 {
			let alert = UIAlertController(title: "Hold On, You're Not Finished", message: "It doesn't look like you've completed a full 2 minute 30 second match. Are you sure you want to close with this partial data?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "No, don't close", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "Yes, close and save data", style: .default, handler: {_ in self.close(andSave: true)}))
			alert.addAction(UIAlertAction(title: "Yes, close but don't save data", style: .destructive, handler: {_ in self.close(andSave: false)}))
			present(alert, animated: true, completion: nil)
		} else {
			close(andSave: true)
		}
	}
	
	func close(andSave shouldSave: Bool) {
        if shouldSave {
            self.ssDataManager?.recordScoutSession()
        }
        
        self.dismiss(animated: true, completion: nil)
        Globals.recordAnalyticsEvent(eventType: "closed_stands_scouting", attributes: ["with_save":shouldSave.description, "at_time":ssDataManager?.stopwatch.elapsedTimeAsString ?? ""])
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
	}
	
	func cycleFromViewController(_ oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMove(toParent: nil)
		addChild(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transition(from: oldVC, to: newVC, duration: 0, options: UIView.AnimationOptions(), animations: {}, completion: {_ in oldVC.removeFromParent(); newVC.didMove(toParent: self); self.currentVC = newVC})
	}
	
	//Timer
	@IBAction func timerButtonTapped(_ sender: UIButton) {
		isRunning = !isRunning
	}
	
	@objc func updateTimeLabel(_ timer: Timer) {
		if ssDataManager?.stopwatch.isRunning ?? false {
			timerLabel.text = ssDataManager?.stopwatch.elapsedTimeAsString
			
            //Auto end Autonomous when timer hits 20 seconds
            if ssDataManager?.stopwatch.elapsedTime ?? 0 > 20 {
                endAutonomousPressed(endAutonomousButton)
            }
            
			if ssDataManager?.stopwatch.elapsedTime ?? 0 > 160 {
				isRunning = false
			} else if ssDataManager?.stopwatch.elapsedTime ?? 0 > 135 {
				//Change the color of the start/stop button to blue signifying that it is safe to stop it.
				timerButton.backgroundColor = UIColor.blue
            }
		} else {
			timer.invalidate()
		}
	}
    
    @IBAction func endAutonomousPressed(_ sender: UIButton) {
        ssDataManager?.endAutonomousPeriod()
        
        endAutonomousButton.isHidden = true
        autonomousLabel.isHidden = true
    }
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func returnToStandsScouting(_ segue: UIStoryboardSegue) {
		
	}
    
    @IBAction func shortPressOnNotesButton(_ sender: UITapGestureRecognizer) {
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
        
        let navVC = UINavigationController(rootViewController: notesVC)
        
        if let eventKey = self.match?.eventKey, let teamKey = self.teamKey {
            notesVC.load(forEventKey: eventKey, andTeamKey: teamKey)
        }
		
		navVC.modalPresentationStyle = .popover
		let popoverController = navVC.popoverPresentationController
		popoverController?.permittedArrowDirections = .any
        popoverController?.sourceView = notesButton
//		popoverController?.sourceRect = CGRect(x: notesButton.frame.maxX, y: notesButton.frame.midY, width: 5, height: 5)
		navVC.preferredContentSize = CGSize(width: 400, height: 600)
		present(navVC, animated: true, completion: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StandsScoutingEnded"), object: self, queue: nil) {notification in
            navVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func longPressOnNotesButton(_ sender: UILongPressGestureRecognizer) {
        let superNotesNavVC = storyboard?.instantiateViewController(withIdentifier: "superNotesNavVC") as! UINavigationController
        let superNotesVC = superNotesNavVC.topViewController as! SuperNotesCollectionViewController
        
        let redKeys = self.match?.alliances?.red?.teamKeys?.map({$0!}) ?? []
        let blueKeys = self.match?.alliances?.blue?.teamKeys?.map({$0!}) ?? []
        if let eventKey = self.match?.eventKey {
            superNotesVC.load(forEventKey: eventKey, withTeamKeys: redKeys + blueKeys)
        }
        
        present(superNotesNavVC, animated: true, completion: nil)
    }
}

