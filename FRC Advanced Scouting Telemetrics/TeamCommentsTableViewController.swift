//
//  TeamCommentsTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/9/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import RealmSwift

protocol NotesDataSource {
    func currentTeamContext() -> Team
}

class TeamCommentsTableViewController: UITableViewController {
    
    var dataSource: NotesDataSource?
    
    var teamComments: List<TeamComment>!
    var commentNotificationToken: NotificationToken?
    var isLoaded = false
    
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
        
        load()
        
        if !RealmController.realmController.syncedRealm.isInWriteTransaction {
            //Add in a listener
            commentNotificationToken = teamComments.observe {[weak self] change in
                switch change {
                case .update(_, let deletions, let insertions, let modifications):
                    self?.tableView.beginUpdates()
                    
                    self?.tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.top)
                    self?.tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.top)
                    
                    self?.tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .fade)
                    
                    self?.tableView.endUpdates()
                default:
                    break
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        commentNotificationToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load() {
        if let team = dataSource?.currentTeamContext() {
            teamComments = team.scouted.comments
            isLoaded = true
            self.tableView.reloadData()
        } else {
            isLoaded = false
        }
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
            (commentCell.viewWithTag(1) as! UILabel).text = dateFormatter.string(from: comment.datePosted)
            
            (commentCell.viewWithTag(2) as! UITextView).text = comment.bodyText
            
            return commentCell
        }
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != teamComments.count {
            //Is a comment row, add the delete action
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completionHandler) in
                //Delete the comment
                
                if RealmController.realmController.syncedRealm.isInWriteTransaction {
                    let commentToDelete = self.teamComments[indexPath.row]
                    self.teamComments.remove(at: indexPath.row)
                    RealmController.realmController.syncedRealm.delete(commentToDelete)
                } else {
                    RealmController.realmController.syncedRealm.beginWrite()
                    
                    let commentToDelete = self.teamComments[indexPath.row]
                    self.teamComments.remove(at: indexPath.row)
                    RealmController.realmController.syncedRealm.delete(commentToDelete)
                    
                    do {
                        try RealmController.realmController.syncedRealm.commitWrite(withoutNotifying: self.commentNotificationToken == nil ? [] : [self.commentNotificationToken!])
                    } catch {
                        CLSNSLogv("Error deleting comment: \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    }
                }
                
                completionHandler(true)
                
                tableView.deleteRows(at: [indexPath], with: .top)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil
        }
    }
    
    @objc func postComment(_ sender: UIButton) {
        let comment = TeamComment()
        comment.bodyText = self.currentlyWrittenCommentText
        comment.datePosted = Date()
        
        if RealmController.realmController.syncedRealm.isInWriteTransaction {
            RealmController.realmController.syncedRealm.add(comment)
            teamComments.append(comment)
        } else {
            RealmController.realmController.syncedRealm.beginWrite()
            
            RealmController.realmController.syncedRealm.add(comment)
            teamComments.append(comment)
            
            do {
                if let token = commentNotificationToken {
                    try RealmController.realmController.syncedRealm.commitWrite(withoutNotifying: [token])
                } else {
                    try RealmController.realmController.syncedRealm.commitWrite()
                }
            } catch {
                CLSNSLogv("Unable to save new comment with error: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
        }
        
        currentlyWrittenCommentText = ""
        
        tableView.insertRows(at: [IndexPath(row: teamComments.count - 1, section: 0)], with: .top)
        tableView.reloadRows(at: [IndexPath(row: teamComments.count, section: 0)], with: .fade)
    }

}

extension TeamCommentsTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        currentlyWrittenCommentText = textView.text
    }
}
