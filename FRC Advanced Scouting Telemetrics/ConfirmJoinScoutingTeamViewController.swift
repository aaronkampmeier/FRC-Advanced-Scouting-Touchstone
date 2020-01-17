//
//  ConfirmJoinScoutingTeamViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/7/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ConfirmJoinScoutingTeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinTeamButton: UIButton!
    var indicator: UIActivityIndicatorView!
    
    var inviteId: String?
    var secretCode: String?
    var enteredName: String?
    
    let isLoadedSemaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        joinTeamButton.layer.cornerRadius = 8
        joinTeamButton.isEnabled = false
        
        joinTeamButton.backgroundColor = .systemGray
        
        tableView.dataSource = self
//        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        mainLabel.text = "Do you want to join the scouting team?"
        
        
        indicator = UIActivityIndicatorView(style: .white)
        indicator.center = CGPoint(x: joinTeamButton.frame.midX, y: joinTeamButton.frame.midY)
        indicator.hidesWhenStopped = true
        joinTeamButton.addSubview(indicator)
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        isLoadedSemaphore.signal()
    }
    
    func load(forInviteId inviteId: String, andCode code: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.isLoadedSemaphore.wait()
            self.isLoadedSemaphore.signal()
            self.inviteId = inviteId
            self.secretCode = code
            Globals.appSyncClient?.fetch(query: GetScoutingTeamPublicNameQuery(inviteID: inviteId), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "GetScoutingTeamPublicName", result: result, error: error) {
                    if let teamName = result?.data?.getScoutingTeamPublicName {
                        self?.mainLabel.text = "Do you want to join \"\(teamName)\"?"
                        self?.joinTeamButton.setTitle("Join \"\(teamName)\"", for: .normal)
                    }
                }
            })
        }
    }
    
    @IBAction func joinPressed(_ sender: UIView) {
        if let inviteId = inviteId, let secretCode = secretCode, let memberName = enteredName {
            //Add a spinner
            indicator.startAnimating()
            
            Globals.appSyncClient?.perform(mutation: RedeemInvitationMutation(inviteID: inviteId, secretCode: secretCode, memberName: memberName), resultHandler: {[weak self] (result, error) in
                
                self?.indicator.stopAnimating()
                
                if Globals.handleAppSyncErrors(forQuery: "JoinScoutingTeam", result: result, error: error) {
                    self?.dismiss(animated: true, completion: nil)
                    
                    // If there is no scouting team currently selected for scouting, set it to this one
                    if Globals.dataManager.enrolledScoutingTeamID == nil {
                        Globals.dataManager.switchCurrentScoutingTeam(to: result?.data?.redeemInvitation)
                    }

                    Globals.recordAnalyticsEvent(eventType: AnalyticsEventJoinGroup, attributes: [AnalyticsParameterGroupID:result?.data?.redeemInvitation ??
                    "?"])
                    
                    //Was successful, try to list them scouting teams again to update the cache
                    Globals.appSyncClient?.fetch(query: ListEnrolledScoutingTeamsQuery(), cachePolicy: .fetchIgnoringCacheData, resultHandler: { (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "JoinTeam-ListScoutingTeamsToVerify", result: result, error: error) {
                            
                        }
                    })
                    
                }
                
            })
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Table View Stuff
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let textField = cell.contentView.viewWithTag(2) as! UITextField
        textField.placeholder = "Johnny Appleseed"
        textField.addTarget(self, action: #selector(textValueChanged(_:)), for: .editingChanged)
        
        textField.returnKeyType = .join
        textField.delegate = self
        
        return cell
    }
    
    @objc func textValueChanged(_ sender: UITextField) {
        enteredName = sender.text
        
        if enteredName?.count ?? 0 > 0 {
            joinTeamButton.isEnabled = true
            joinTeamButton.backgroundColor = .systemOrange
        } else {
            joinTeamButton.isEnabled = false
            joinTeamButton.backgroundColor = .systemGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.joinPressed(textField)
        return true
    }
}
