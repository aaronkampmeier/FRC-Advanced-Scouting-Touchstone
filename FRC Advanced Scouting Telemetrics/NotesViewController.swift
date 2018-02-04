//
//  NotesViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/30/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol NotesDataSource {
    func currentTeamContext() -> Team
    func notesShouldSave() -> Bool
}

class NotesViewController: UIViewController {
    
    @IBOutlet weak var notesTextView: UITextView?
    
    var dataSource: NotesDataSource?
    var autosaveTimer: Timer?
    
    var team: Team!
    
    var notes: String = "" {
        didSet {
            notesTextView?.text = notes
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTextView?.becomeFirstResponder()
        
        notesTextView?.delegate = self
        
        reload()
    }
    
    @objc func autoSave(_ timer: Timer) {
        save()
    }
    
    func save() {
        RealmController.realmController.genericWrite(onRealm: .Synced) {
            team.scouted.notes = self.notes
        }
    }
    
    func reload() {
        if let team = dataSource?.currentTeamContext() {
            self.team = team
            self.notes = team.scouted.notes
            
            //Set the title in the nav bar
            if let _ = self.navigationController {
                self.navigationItem.title = "Team \(team.teamNumber) Notes"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if dataSource?.notesShouldSave() ?? false {
            autosaveTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(autoSave(_:)), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if dataSource?.notesShouldSave() ?? false {
            save()
        }
        
        if let timer = autosaveTimer {
            timer.invalidate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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

extension NotesViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        save()
    }
}
