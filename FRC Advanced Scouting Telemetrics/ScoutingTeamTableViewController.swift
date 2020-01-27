//
//  ScoutingTeamTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/4/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient
import FirebaseAnalytics
import Crashlytics

class ScoutingTeamTableViewController: UITableViewController {
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var editTeamButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    var isLoadedSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    var scoutingTeamWatcher: GraphQLQueryWatcher<GetScoutingTeamWithMembersQuery>?
    var scoutingTeamId: GraphQLID?
    var scoutingTeamWithMembers: ScoutingTeamWithMembers?
    var activeInvitations: [ScoutTeamInvitation?]?
    
//    let qrCodeTransitioningDelegate = QrCodeTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            editTeamButton.trailingAnchor.constraint(greaterThanOrEqualTo: tableView.trailingAnchor, constant: 5)
            teamNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tableView.leadingAnchor, constant: 30)
        ])
        
        editTeamButton.imageView?.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            editTeamButton.imageView?.image = UIImage(systemName: "square.and.pencil")
        } else {
            editTeamButton.imageView?.image = UIImage(named: "Edit")
        }
        editTeamButton.isHidden = true
        editTeamButton.addTarget(self, action: #selector(editTeamDataPressed(_:)), for: .touchUpInside)
        isLoadedSemaphore.signal()
    }
    
    func loadData(forId scoutingTeamId: GraphQLID) {
        //Load the data again
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.isLoadedSemaphore.wait()
            self?.isLoadedSemaphore.signal()
            self?.scoutingTeamId = scoutingTeamId
            self?.scoutingTeamWatcher?.cancel()
            self?.scoutingTeamWatcher = Globals.appSyncClient?.watch(query: GetScoutingTeamWithMembersQuery(scoutTeam: scoutingTeamId), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "GetScoutingTeamWithMembers", result: result, error: error) {
                    self?.scoutingTeamWithMembers = result?.data?.getScoutingTeam?.fragments.scoutingTeamWithMembers
                    
                    //Set in all the info
                    self?.teamNameLabel.text = self?.scoutingTeamWithMembers?.name
                    self?.secondaryLabel.text = "\(self?.scoutingTeamWithMembers?.associatedFrcTeamNumber.description ?? "")"
                    if self?.scoutingTeamWithMembers?.teamLead == Globals.dataManager.userSub {
                        self?.editTeamButton.isHidden = false
                    } else {
                        self?.editTeamButton.isHidden = true
                    }
                    self?.tableView.reloadData()
                }
            })
            
            //Invitations
            Globals.appSyncClient?.fetch(query: ListScoutingTeamInvitationsQuery(scoutTeam: scoutingTeamId), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutingTeamInvitations", result: result, error: error) {
                    self?.activeInvitations = result?.data?.listScoutingTeamInvitations?.map {$0?.fragments.scoutTeamInvitation}
                    self?.tableView.reloadSections([2], with: .automatic)
                }
            })
        }
    }
    
    @objc func editTeamDataPressed(_ sender: UIButton) {
        //Show alert asking for new team name and number
        let alert = UIAlertController(title: "Edit Scouting Team Info", message: nil, preferredStyle: .alert)
        var teamNameField: UITextField?
        var teamNumberField: UITextField?
        alert.addTextField { (textField) in
            textField.placeholder = "Scouting Team Name"
            textField.text = self.scoutingTeamWithMembers?.name
            teamNameField = textField
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Associted FRC Team Number"
            textField.keyboardType = .asciiCapableNumberPad
            textField.text = self.scoutingTeamWithMembers?.associatedFrcTeamNumber.description
            teamNumberField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            //Save the new info
            if let teamName = teamNameField?.text, let number = Int(teamNumberField?.text ?? "") {
                if teamName != self.scoutingTeamWithMembers?.name || number != self.scoutingTeamWithMembers?.associatedFrcTeamNumber {
                    Globals.appSyncClient?.perform(mutation: EditScoutingTeamInfoMutation(scoutTeam: self.scoutingTeamId ?? "", name: teamName, asscoiatedFrcTeamNumber: number), resultHandler: {[weak self] (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "EditScoutingTeamInfo", result: result, error: error) {
                            let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                                try? transaction.update(query: GetScoutingTeamWithMembersQuery(scoutTeam: self?.scoutingTeamId ?? "")) { (selectionSet) in
                                    selectionSet.getScoutingTeam?.associatedFrcTeamNumber = number
                                    selectionSet.getScoutingTeam?.name = teamName
                                }
                                return true
                            })
                            
                            let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                                try? transaction.update(query: ListEnrolledScoutingTeamsQuery(), { (selectionSet) in
                                    var scoutingTeams = selectionSet.listEnrolledScoutingTeams
                                    if let index = scoutingTeams?.firstIndex(where: {$0?.teamId == self?.scoutingTeamId}) {
                                        var scoutingTeamToUpdate = scoutingTeams?.remove(at: index)
                                        scoutingTeamToUpdate?.name = teamName
                                        scoutingTeamToUpdate?.associatedFrcTeamNumber = number
                                        scoutingTeams?.append(scoutingTeamToUpdate)
                                        selectionSet.listEnrolledScoutingTeams = scoutingTeams
                                    }
                                })
                                return true
                            })
                        }
                    })
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        if headerHeight != headerView.frame.height {
            let newFrame = CGRect(x: headerView.frame.minX, y: headerView.frame.minY, width: tableView.frame.width, height: headerHeight)
            tableView.tableHeaderView?.frame = newFrame
            tableView.layoutSubviews()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            //Select for scouting
            return 1
        case 1:
            //Members
            return scoutingTeamWithMembers?.members?.count ?? 0
        case 2:
            //Invitations
            if activeInvitations?.count == 0 {
                return 1
            } else {
                return activeInvitations?.count ?? 0
            }
        case 3:
            //Leave team
            if Globals.dataManager.userSub == scoutingTeamWithMembers?.teamLead {
                //The team lead cannot leave the team
                return 0
            } else {
                return 1
            }
        default:
            return 0
        }
    }

    //MARK: - Cell for Row at
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "scout")!
            let label = cell.contentView.viewWithTag(1) as! UILabel
            
            if Globals.dataManager.enrolledScoutingTeamID == scoutingTeamWithMembers?.teamId {
                //Already scouting
                label.text = "Currently scouting for this team"
                label.textColor = .systemGray
            } else {
                label.text = "Switch to scouting for this team"
                label.textColor = .systemBlue
            }
            return cell
        case 1:
            //Members
            let cell = tableView.dequeueReusableCell(withIdentifier: "member")!
            let member = scoutingTeamWithMembers?.members?[indexPath.row]
            
            cell.textLabel?.text = member?.name ?? "Unknown Name"
            if member?.userId == scoutingTeamWithMembers?.teamLead {
                cell.detailTextLabel?.text = "Lead"
                cell.detailTextLabel?.textColor = .systemGreen
            } else {
                let dateFormat = DateFormatter()
                let joinTime = Date(timeIntervalSince1970: Double(member?.memberSince ?? 0))
                dateFormat.timeZone = TimeZone.current
                dateFormat.locale = NSLocale.current
                dateFormat.dateStyle = .medium
                cell.detailTextLabel?.text = "Member since \(dateFormat.string(from: joinTime))"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .secondaryLabel
                } else {
                    cell.detailTextLabel?.textColor = .lightText
                }
            }
            
            //If this entry is the current user, then indicate it by marking the name blue
            if Globals.dataManager.userSub == member?.userId {
                cell.textLabel?.textColor = .systemBlue
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    cell.textLabel?.textColor = .black
                }
            }
            
            return cell
        case 2:
            //Scout Team Invitations section
            
            
            if activeInvitations?.count ?? 0 > 0 {
                //Show the invitations
                let cell = tableView.dequeueReusableCell(withIdentifier: "invitationInfo")!
                let invitation = activeInvitations?[indexPath.row]
                
                let inviteIdLabel = cell.contentView.viewWithTag(1) as! UILabel
                let secretCodeLabel = cell.contentView.viewWithTag(2) as! UILabel
                let expDateLabel = cell.contentView.viewWithTag(3) as! UILabel
                let qrCodeIcon = UIImageView()
                
                inviteIdLabel.text = invitation?.inviteId
                secretCodeLabel.text = invitation?.secretCode
                
                let expDate = Date(timeIntervalSince1970: Double(invitation?.expDate ?? 0))
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                
                expDateLabel.text = "Expires \(dateFormatter.string(from: expDate))"
                
                qrCodeIcon.frame.size = CGSize(width: 35, height: 35)
                qrCodeIcon.contentMode = .scaleAspectFit
                if #available(iOS 13.0, *) {
                    qrCodeIcon.image = UIImage(systemName: "qrcode")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .unspecified))
                } else {
                    // Fallback on earlier versions
                    qrCodeIcon.image = UIImage(named: "qr-code")
                }
                cell.accessoryView = qrCodeIcon
                
                return cell
            } else {
                //Show the create invitation button
                let cell = tableView.dequeueReusableCell(withIdentifier: "createInvitation")!

                return cell
            }
            
        case 3:
            //Leave team
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveTeam")!
            
            let textLabel = cell.contentView.viewWithTag(1) as! UILabel
            if Globals.dataManager.userSub == scoutingTeamWithMembers?.teamLead {
                textLabel.text = "Transfer Team Lead"
            } else {
                textLabel.text = "Leave Team"
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Members"
        case 2:
            return "Invitations"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            if Globals.dataManager.userSub == scoutingTeamWithMembers?.teamLead {
                return "Swipe left on members to remove them from the team or to transfer leadership to them."
            } else {
                return nil
            }
        case 2:
            return "To add members to your scouting team, first create an invitation here. Then have your teammate enter the invitation details on their devices in the Admin Console."
        default:
            return nil
        }
    }
    
//    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        switch indexPath.section {
//
//        default:
//            return false
//        }
//    }
    
    //MARK: - Accessory Button Tapped
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let member = scoutingTeamWithMembers?.members?[indexPath.row]
            if member?.userId == Globals.dataManager.userSub {
                //Show an alert to edit member name
                let alert = UIAlertController(title: "Edit Member Name", message: nil, preferredStyle: .alert)
                var nameField: UITextField?
                alert.addTextField { (textField) in
                    nameField = textField
                    textField.placeholder = "Member Name"
                    textField.text = member?.name
                }
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                    if let newName = nameField?.text {
                        if newName != member?.name {
                            Globals.appSyncClient?.perform(mutation: ChangeMemberNameMutation(scoutTeam: self.scoutingTeamId ?? "", newName: newName), resultHandler: {[weak self] (result, error) in
                                if Globals.handleAppSyncErrors(forQuery: "ChangeMemberName", result: result, error: error) {
                                    self?.loadData(forId: self?.scoutingTeamId ?? "")
                                }
                            })
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        case 2:
            if indexPath.row < activeInvitations?.count ?? 0 {
                
            }
        default:
            break
        }
    }
    
    //MARK: Did Select Row At
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            //Switch to scouting it
            if Globals.dataManager.enrolledScoutingTeamID != scoutingTeamId {
                Globals.dataManager.switchCurrentScoutingTeam(to: scoutingTeamWithMembers!)
                tableView.reloadSections([0], with: .automatic)
            }
        case 1:
            
            break
        case 2:
            //Invitations
            if indexPath.row < activeInvitations?.count ?? 0 {
                if let invitation = activeInvitations?[indexPath.row] {
                    //Show the qr code
                    let qrCodeVC = storyboard!.instantiateViewController(withIdentifier: "qrCodeView") as! QrCodeViewController
                    
                    qrCodeVC.show(invite: invitation)

                    self.present(qrCodeVC, animated: true, completion: nil)
                }
            } else {
                //Call create invitation
                //Ask for expDate
                let alert = UIAlertController(title: "When should the invitation expire?", message: nil, preferredStyle: .alert)
                //Time options holds the options for how long an invitation should last and the associated TimeInterval
                let timeOptions: [(String,TimeInterval)] = [
                    ("5 Hours",60*60*5),
                    ("1 Day", 60*60*24),
                    ("3 Days", 60*60*24*3),
                    ("1 Week", 60*60*24*7),
                    ("30 Days", 60*60*24*30),
                    ("3 Months", 60*60*24*30*3)
                ]
                
                let actionHandler = { (action: UIAlertAction) -> Void in
                    //Get the exp date
                    if let ttl = timeOptions.first(where: {$0.0 == action.title})?.1 {
                        let expDate = Date().addingTimeInterval(ttl)
                        
                        Globals.appSyncClient?.perform(mutation: MakeScoutTeamInvitationMutation(scoutTeam: self.scoutingTeamId ?? "", expDate: Int(expDate.timeIntervalSince1970)), resultHandler: {[weak self] (result, error) in
                            
                            if Globals.handleAppSyncErrors(forQuery: "MakeScoutTeamInvitation", result: result, error: error) {
                                self?.loadData(forId: self?.scoutingTeamId ?? "")
                            }
                        })
                    }
                }
                for option in timeOptions {
                    alert.addAction(UIAlertAction(title: option.0, style: .default, handler: actionHandler))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            break
        case 3:
            //Leave
            let alert = UIAlertController(title: "Leave Team?", message: "Are you sure you want to leave this team? Your access to its shared data and any data you contributed will be immediately revoked.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
                Globals.appSyncClient?.perform(mutation: RemoveMemberMutation(scoutTeam: self.scoutingTeamId ?? "", userToRemove: Globals.dataManager.userSub ?? ""), resultHandler: { [scoutingTeamId = self.scoutingTeamId, weak self] (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "LeaveTeam", result: result, error: error) {
                        //Remove this scouted team from the ListEnrolledScoutingTeamsQuery
                        let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                            try? transaction.update(query: ListEnrolledScoutingTeamsQuery()) { (selectionSet) in
                                if let index = selectionSet.listEnrolledScoutingTeams?.firstIndex(where: {$0?.teamId == scoutingTeamId}) {
                                    selectionSet.listEnrolledScoutingTeams?.remove(at: index)
                                }
                            }
                            return true
                        })
                        
                        self?.dismiss(animated: true, completion: nil)
                        
                        if Globals.dataManager.enrolledScoutingTeamID == self?.scoutingTeamId {
                            Globals.dataManager.switchCurrentScoutingTeam(to: nil)
                        }
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            if activeInvitations?.count ?? 0 > 0 {
                return 88
            } else {
                return 44
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 1:
            if Globals.dataManager.userSub == scoutingTeamWithMembers?.teamLead {
                let member = scoutingTeamWithMembers?.members?[indexPath.row]
                if member?.userId != scoutingTeamWithMembers?.teamLead {
                    let removeMemberAction = UIContextualAction(style: .destructive, title: "Remove") {[weak self] (contextualAction, view, completion) in
                        //Remove this member
                        let alert = UIAlertController(title: "Remove Member?", message: "Are you sure you want to remove \(String(describing: member?.name)) from the scouting team? They will no longer be able to access any scouted data, but they can still rejoin using an invitation.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Remove Them", style: .destructive, handler: { (action) in
                            Globals.appSyncClient?.perform(mutation: RemoveMemberMutation(scoutTeam: self?.scoutingTeamId ?? "", userToRemove: member?.userId ?? ""), optimisticUpdate: { (transaction) in
                                
                            }, resultHandler: {[weak self] (result, error) in
                                if Globals.handleAppSyncErrors(forQuery: "RemoveScoutingTeamMember", result: result, error: error) {
                                    let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                                        do {
                                            try transaction.update(query: GetScoutingTeamWithMembersQuery(scoutTeam: self?.scoutingTeamId ?? "")) { (selectionSet) in
                                                selectionSet.getScoutingTeam?.members?.removeAll(where: { $0?.userId == member?.userId})
                                            }
                                        } catch {
                                            CLSNSLogv("Error removing member from apollo cache: \(error)", getVaList([]))
                                            Crashlytics.sharedInstance().recordError(error)
                                        }
                                        return true
                                    })
                                    completion(true)
                                } else {
                                    completion(false)
                                }
                            })
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in completion(false)}))
                        self?.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    let transferLeadAction = UIContextualAction(style: .normal, title: "Transfer Lead") {[weak self] (action, view, completion) in
                        //Ask for reassurance
                        let alert = UIAlertController(title: "Transfer Leadership?", message: "Are you sure you want to transfer leadership of the team to \(member?.name ?? "?"). This will immediately revoke all leadership priveleges from you including the ability to remove team members.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes, Transfer", style: .destructive, handler: { (action) in
                            Globals.appSyncClient?.perform(mutation: TransferLeadMutation(scoutTeam: self?.scoutingTeamId ?? "", newTeamLeadUserId: member?.userId ?? ""), resultHandler: { (result, error) in
                                if Globals.handleAppSyncErrors(forQuery: "TransferTeamLead", result: result, error: error) {
                                    completion(true)
                                    self?.loadData(forId: self?.scoutingTeamId ?? "")
                                } else {
                                    completion(false)
                                }
                            })
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in completion(false)}))
                        self?.present(alert, animated: true, completion: nil)
                    }
                    transferLeadAction.backgroundColor = .systemBlue
                    
                    return UISwipeActionsConfiguration(actions: [removeMemberAction, transferLeadAction])
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

class QrCodeViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    
    private(set) var invitation: ScoutTeamInvitation?
    
    let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 15
        
        shareButton.tintColor = UIColor.systemBlue
        if #available(iOS 13.0, *) {
            shareButton.setTitle(nil, for: .normal)
            shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        }
        viewIsLoadedSemaphore.signal()
    }
    
    internal func show(invite: ScoutTeamInvitation) {
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.viewIsLoadedSemaphore.wait()
            self?.viewIsLoadedSemaphore.signal()
            DispatchQueue.main.async {
                self?.invitation = invite
                if let qrCode = FASTQRCodeManager.createCode(forInviteId: invite.inviteId, andCode: invite.secretCode) {
                    self?.imageView.image = UIImage(ciImage: qrCode)
                }
                
                Globals.recordAnalyticsEvent(eventType: "show_scouting_team_invite_qr", attributes: [AnalyticsParameterItemID:invite.inviteId])
            }
        }
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        //Get a url
        if let invite = invitation, let url = FASTQRCodeManager.createUniversalLink(forInviteId: invite.inviteId, andCode: invite.secretCode) {
            //Show an activity vc
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.saveToCameraRoll]
            activityVC.popoverPresentationController?.sourceView = sender
            
            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if let type = activityType {
                    Globals.recordAnalyticsEvent(eventType: AnalyticsEventShare, attributes: ["activity_type":type.rawValue, "content_type":"scouting_team_invitation","invite_id":invite.inviteId])
                }
                
                if let error = error {
                    CLSNSLogv("Error sharing link to invite: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                }
            }
            
            self.present(activityVC, animated: true, completion: nil)
            
        }
    }
}

//class QrCodeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return QrCodePresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}
//
//class QrCodePresentationController: UIPresentationController {
//    var tapGestureRecognizer: UITapGestureRecognizer!
//    override var frameOfPresentedViewInContainerView: CGRect {
//        let bounds = presentingViewController.view.bounds
//        let size: CGSize
//        size = CGSize(width: min(300, bounds.size.width), height: min(300, bounds.size.height))
//        let origin = CGPoint(x: bounds.midX - (size.width / 2), y: bounds.midY - (size.height / 2))
//        return CGRect(origin: origin, size: size)
//    }
//
//    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
//
//        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
//
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
//
//    }
//
//    override func presentationTransitionWillBegin() {
//
//    }
//
//    @objc func dismiss() {
//        presentedViewController.dismiss(animated: true, completion: nil)
//    }
//}

