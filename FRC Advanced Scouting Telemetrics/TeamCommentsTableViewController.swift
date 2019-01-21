//
//  TeamCommentsTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/9/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSAppSync
import AWSMobileClient

class TeamCommentsTableViewController: UITableViewController {
    
    var eventKey: String?
    var teamKey: String?
    var teamComments: [TeamComment]!
    var isLoaded = false
    
    var queryWatcher: GraphQLQueryWatcher<ListTeamCommentsQuery>?
    
    var currentlyWrittenCommentText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if !RealmController.realmController.syncedRealm.isInWriteTransaction {
//            //Add in a listener
//            commentNotificationToken = teamComments.observe {[weak self] change in
//                switch change {
//                case .update(_, let deletions, let insertions, let modifications):
//                    self?.tableView.beginUpdates()
//
//                    self?.tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.top)
//                    self?.tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.top)
//
//                    self?.tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .fade)
//
//                    self?.tableView.endUpdates()
//                default:
//                    break
//                }
//            }
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(forEventKey eventKey: String, andTeamKey teamKey: String) {
        self.eventKey = eventKey
        self.teamKey = teamKey
        queryWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTeamCommentsQuery(eventKey: eventKey, teamKey: teamKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTeamComments", result: result, error: error) {
                self?.teamComments = result?.data?.listTeamComments?.map({$0!.fragments.teamComment}).sorted {$0.datePosted < $1.datePosted}
                self?.isLoaded = true
                self?.tableView.reloadData()
            } else {
                //TODO: - Show error
            }
        })
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamComments.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == teamComments.count {
            //It is the last row, the add comment row
            let postCommentCell = tableView.dequeueReusableCell(withIdentifier: "postComment")!
            
            let textView = postCommentCell.viewWithTag(1) as! UITextView
            let postButton = postCommentCell.viewWithTag(2) as! UIButton
            
            //Style the text view
            textView.layer.cornerRadius = 5
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 2
            
            textView.text = currentlyWrittenCommentText
            textView.delegate = self
            
            postButton.addTarget(self, action: #selector(postComment(_:)), for: .touchUpInside)
            
            return postCommentCell
        } else {
            //Is a comment row
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "comment")!
            
            let comment = teamComments[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            
            dateFormatter.dateFormat = "EEE dd, HH:mm"
            let date = Date(timeIntervalSince1970: TimeInterval(comment.datePosted))
            let dateString = dateFormatter.string(from: date)
            (commentCell.viewWithTag(1) as! UILabel).text = "\(dateString)\(comment.author != "" ? " by \(comment.author)" : "")"
            
            (commentCell.viewWithTag(2) as! UITextView).text = comment.body
            
            return commentCell
        }
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != teamComments.count {
            //Is a comment row, add the delete action
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] (action, view, completionHandler) in
                //Delete the comment
                Globals.appDelegate.appSyncClient?.perform(mutation: RemoveTeamCommentMutation(userID: AWSMobileClient.sharedInstance().username!, eventKey: (self?.eventKey)!, key: (self?.teamKey)!), resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "RemoveTeamComment", result: result, error: error) {
                        self?.teamComments.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .top)
                    } else {
                        CLSNSLogv("Error deleting comment", getVaList([]))
                    }
                    
                    completionHandler(true)
                })
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil
        }
    }
    
    @objc func postComment(_ sender: UIButton) {
        Globals.appDelegate.appSyncClient?.perform(mutation: AddTeamCommentMutation(userID: AWSMobileClient.sharedInstance().username!, eventKey: eventKey!, teamKey: teamKey!, body: self.currentlyWrittenCommentText, author: UIDevice.current.name), optimisticUpdate: { (transaction) in
            //TODO: - Add optimistic update
        }, conflictResolutionBlock: { (snapshot, taskSource, onCompletion) in
            
        }, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "AddTeamComment", result: result, error: error) {
                self.currentlyWrittenCommentText = ""
                Answers.logCustomEvent(withName: "Posted team comment", customAttributes: nil)
            } else {
                CLSNSLogv("Unable to save new comment", getVaList([]))
                //TODO: - Show error
            }
        })
        
        tableView.insertRows(at: [IndexPath(row: teamComments.count - 1, section: 0)], with: .top)
        tableView.reloadRows(at: [IndexPath(row: teamComments.count, section: 0)], with: .fade)
    }

}

extension TeamCommentsTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        currentlyWrittenCommentText = textView.text
    }
}
