//
//  ConfirmJoinScoutingTeamViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/7/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit

class ConfirmJoinScoutingTeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinTeamButton: UIButton!
    var indicator: UIActivityIndicatorView!
    
    var inviteId: String?
    var secretCode: String?
    var enteredName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        joinTeamButton.layer.cornerRadius = 8
        tableView.dataSource = self
        tableView.delegate = self
        mainLabel.text = "Do you want to join the scouting team?"
        
        
        indicator = UIActivityIndicatorView(style: .white)
        indicator.center = CGPoint(x: joinTeamButton.frame.midX, y: joinTeamButton.frame.midY)
        indicator.hidesWhenStopped = true
        joinTeamButton.addSubview(indicator)
    }
    
    func load(forInviteId inviteId: String, andCode code: String) {
        self.inviteId = inviteId
        self.secretCode = code
        Globals.appSyncClient?.fetch(query: GetScoutingTeamPublicNameQuery(inviteID: inviteId), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "GetScoutingTeamPublicName", result: result, error: error) {
                if let teamName = result?.data?.getScoutingTeamPublicName {
                    self?.mainLabel.text = "Do you want to join \(teamName)"
                    self?.joinTeamButton.setTitle("Join \(teamName)", for: .normal)
                }
            }
        })
    }
    
    @IBAction func joinPressed(_ sender: UIButton) {
        if let inviteId = inviteId, let secretCode = secretCode, let memberName = enteredName {
            //Add a spinner
            indicator.startAnimating()
            
            Globals.appSyncClient?.perform(mutation: RedeemInvitationMutation(inviteID: inviteId, secretCode: secretCode, memberName: memberName), resultHandler: {[weak self] (result, error) in
                
                self?.indicator.stopAnimating()
                
                if Globals.handleAppSyncErrors(forQuery: "JoinScoutingTeam", result: result, error: error) {
                    self?.dismiss(animated: true, completion: nil)
                    
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
        
        return cell
    }
    
    @objc func textValueChanged(_ sender: UITextField) {
        enteredName = sender.text
        
        joinTeamButton.isEnabled = enteredName?.count ?? 0 > 0
    }
}
