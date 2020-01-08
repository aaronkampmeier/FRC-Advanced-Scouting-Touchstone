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
    
    var scoutTeam: String?
    var eventKey: String?
    var teamKey: String?
    var teamComments: [TeamComment] = []
    var isLoaded = false
    
    var currentlyWrittenCommentText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 55
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(inScoutTeam scoutTeam: String, forEventKey eventKey: String, andTeamKey teamKey: String) {
        self.scoutTeam = scoutTeam
        self.eventKey = eventKey
        self.teamKey = teamKey
        Globals.appSyncClient?.fetch(query: ListTeamCommentsQuery(scoutTeam: scoutTeam, eventKey: eventKey, teamKey: teamKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTeamComments", result: result, error: error) {
                self?.teamComments = result?.data?.listTeamComments?.map({$0!.fragments.teamComment}).sorted {$0.datePosted < $1.datePosted} ?? []
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
            let comment = teamComments[indexPath.row]
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] (action, view, completionHandler) in
                //Delete the comment
                //TODO: Check the parameters for null before making the call
                Globals.appSyncClient?.perform(mutation: RemoveTeamCommentMutation(scoutTeam: self?.scoutTeam ?? "", eventKey: (self?.eventKey) ?? "", key: comment.key), resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "RemoveTeamComment", result: result, error: error) {
                        self?.tableView.beginUpdates()
                        self?.teamComments.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .top)
                        
                        //Remove it from the cache
                        let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Any in
                            do {
                                try transaction.update(query: ListTeamCommentsQuery(scoutTeam: self?.scoutTeam ?? "", eventKey: self?.eventKey ?? "", teamKey: self?.teamKey ?? ""), { (selectionSet) in
                                    if let index = selectionSet.listTeamComments?.firstIndex(where: {$0?.key == result?.data?.removeTeamComment?.key}) {
                                        selectionSet.listTeamComments?.remove(at: index)
                                    }
                                })
                            } catch {
                                CLSNSLogv("Error deleting team comment from cache: \(error)", getVaList([]))
                                Crashlytics.sharedInstance().recordError(error)
                            }
                            
                            return 0
                        })
                        
                        self?.tableView.endUpdates()
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
        let body = self.currentlyWrittenCommentText
        let uuid = UUID().uuidString
        let date = Date().timeIntervalSince1970
        Globals.recordAnalyticsEvent(eventType: "posted_team_comment", attributes: ["eventKey":eventKey!, "teamKey":teamKey!], metrics: ["length":Double(body.count)])
        Globals.appSyncClient?.perform(mutation: AddTeamCommentMutation(scoutTeam: scoutTeam ?? "", eventKey: eventKey!, teamKey: teamKey!, body: body, author: UIDevice.current.name), optimisticUpdate: { (transaction) in
            do {
                try transaction?.update(query: ListTeamCommentsQuery(scoutTeam: self.scoutTeam ?? "", eventKey: self.eventKey!, teamKey: self.teamKey!), { (selectionSet) in
                    selectionSet.listTeamComments?.append(ListTeamCommentsQuery.Data.ListTeamComment(author: UIDevice.current.name, scoutTeam: self.scoutTeam ?? "", authorUserId: AWSMobileClient.default().username!, body: body, datePosted: Int(date), key: uuid, teamKey: self.teamKey ?? "", eventKey: self.eventKey ?? ""))
                })
            } catch {
                CLSNSLogv("Error performing optimistic update: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
        }, conflictResolutionBlock: { (snapshot, taskSource, onCompletion) in
            
        }, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "AddTeamComment", result: result, error: error) {
                
                if let comment = result?.data?.addTeamComment?.fragments.teamComment {
                    
                    //Find the old one
                    if let index = self.teamComments.firstIndex(where: {$0.key == uuid}) {
                        //Replace it
                        self.teamComments.remove(at: index)
                        self.teamComments.insert(comment, at: index)
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    } else {
                        self.teamComments.append(comment)
                    }
                    
                    //Now fix the cache
                    let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Any in
                        do {
                            try transaction.update(query: ListTeamCommentsQuery(scoutTeam: self.scoutTeam ?? "", eventKey: self.eventKey!, teamKey: self.teamKey!), { (selectionSet) in
                                if let index = selectionSet.listTeamComments?.firstIndex(where: { (comment) -> Bool in
                                    return comment?.key == uuid
                                }) {
                                    selectionSet.listTeamComments?.remove(at: index)
                                }
                                
                                //Add in the new team comment
                                selectionSet.listTeamComments?.append(try ListTeamCommentsQuery.Data.ListTeamComment(comment))
                            })
                        } catch {
                            //Didn't work, oof
                            
                        }
                        
                        return 0
                    })
                }
            } else {
                let alert = UIAlertController(title: "Error Saving Team Comment", message: "There was an error saving the team comment, please try again: \(error != nil ? (error as? AWSMobileClientError)?.message ?? "" : "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        
        tableView.beginUpdates()
        teamComments.append(TeamComment(author: UIDevice.current.name, scoutTeam: scoutTeam ?? "", authorUserId: AWSMobileClient.default().username!, body: body, datePosted: Int(date), key: uuid, teamKey: teamKey ?? "", eventKey: eventKey ?? ""))
        tableView.insertRows(at: [IndexPath(row: teamComments.count - 1, section: 0)], with: .top)
        self.currentlyWrittenCommentText = ""
        tableView.endUpdates()
        tableView.reloadRows(at: [IndexPath(row: teamComments.count, section: 0)], with: .fade)
    }
}

extension TeamCommentsTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        currentlyWrittenCommentText = textView.text
    }
}
