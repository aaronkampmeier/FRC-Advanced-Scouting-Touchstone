//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var teamTable: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var teamList: UITableView!
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var driverExpLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var editTeamsButton: UIBarButtonItem!
    @IBOutlet weak var teamListToolbar: UIToolbar!
    @IBOutlet weak var statsButton: UIBarButtonItem!
    
    let teamManager = TeamDataManager()
    var adjustsForToolbarInsets: UIEdgeInsets? = nil
    
    var teams = [Team]()
    var searchResultTeams = [Team]()
    var isSearching = false
    var teamSelected: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add responder for notification about a new team
        NSNotificationCenter.defaultCenter().addObserverForName("New Team", object: nil, queue: nil, usingBlock: addTeamFromNotification)
        
        teamList.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        
        //Set the labels' default text
        weightLabel.text = ""
        driverExpLabel.text = ""
        
        //Hide the search bar's cancel button
        searchBar.showsCancelButton = false
        
        do {
            teams = try teamManager.getDraftBoard()
        } catch {
            NSLog("Unable to get the teams: \(error)")
        }
        
        //Allow the teams to be selected even during editing
        teamList.allowsSelectionDuringEditing = true
        
        //Prevent the bottom table view cells from being covered by the toolbar
        adjustsForToolbarInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(teamListToolbar.frame), right: 0)
        
        //Set the stats button to not selectable since there is no team selected
        statsButton.enabled = false
    }
    
    func addTeamFromNotification(notification:NSNotification) {
        do {
            teams = try teamManager.getDraftBoard()
        } catch {
            NSLog("Unable to get the teams: \(error)")
        }
        teamList.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResultTeams.count
        } else {
            return teams.count
        }
    }
    
    /*<---- CELL FOR ROW AT INDEX PATH---->*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var teamDataArray = [Team]()
        
        //If there are search results, then display those
        if isSearching {
            teamDataArray = searchResultTeams
        } else {
            teamDataArray = teams
        }
        
        //Testing with new rankedCell
        /*
        let cell = teamList.dequeueReusableCellWithIdentifier("rankedCell")
        
        let team = teamDataArray[indexPath.row]
        
        let rankLabel: UILabel = cell?.contentView.viewWithTag(10) as! UILabel
        let imageView: UIImageView = cell?.contentView.viewWithTag(2) as! UIImageView
        let teamLabel: UILabel = cell?.contentView.viewWithTag(3) as! UILabel
        
        rankLabel.text = "1."
        imageView.image = UIImage(named: "FRC-Logo")
        teamLabel.text = "Team \(team.teamNumber)"
        */
        
        
        let cell = teamList.dequeueReusableCellWithIdentifier("Cell")
        
        let team = teamDataArray[indexPath.row]
        
        if editing {
            cell!.textLabel?.text = "\(team.teamNumber!)"
        } else {
            cell!.textLabel?.text = "Team \(team.teamNumber!)"
        }
        
        if let image = team.frontImage {
            cell!.imageView?.image = UIImage(data: image)
        } else {
            cell!.imageView?.image = UIImage(named: "FRC-Logo")
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Check if we are searching or not
        var teamDataArray = [Team]()
        if isSearching {
            teamDataArray = searchResultTeams
        } else {
            teamDataArray = teams
        }
        
        teamSelected = teamDataArray[indexPath.row]
        
        teamNumberLabel.text = teamSelected!.teamNumber
        
        weightLabel.text = "Weight: \(teamSelected!.robotWeight!) lbs"
        
        driverExpLabel.text = "Driver Exp: \(teamSelected!.driverExp!) yrs"
        
        //Populate the images, if there are images
        if let image = teamSelected!.frontImage {
            frontImageView.image = UIImage(data: image)
        } else {
            frontImageView.image = nil
        }
        if let image = teamSelected!.sideImage {
            sideImageView.image = UIImage(data: image)
        } else {
            sideImageView.image = nil
        }
        
        //Set the stats button to be selectable
        statsButton.enabled = true
    }
    
    
    //Two functions to allow deletion of Teams from the Table View
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //Remove the team and reload the table
            teamManager.deleteTeam(teams[indexPath.row])
            teams.removeAtIndex(indexPath.row)
            teamList.reloadData()
        }
    }
    
    //Team List TableView Functions for editing:
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return .None
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //Move the team in the array and in Core Data
        let movedTeam = teams[sourceIndexPath.row]
        teams.removeAtIndex(sourceIndexPath.row)
        teams.insert(movedTeam, atIndex: destinationIndexPath.row)
        
        do {
            try teamManager.moveTeam(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        } catch {
            NSLog("Unable to save team move: \(error)")
        }
    }
    //
    
    //Functions for the search bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //Set that we are searching
        isSearching = true
        
        //Show the cancel button
        searchBar.showsCancelButton = true
        
        //Give beginning data
        searchResultTeams = teams
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //Clear the previous search results
        searchResultTeams.removeAll()
        
        //Create a predicate
        var predicate: NSPredicate
        
        if searchText.characters.count == 0 {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "teamNumber contains %@", argumentArray: [searchText])
        }
        
        //Take each team and check if it meets the required criteria, then add it to the search results array
        for team in teams {
            if predicate.evaluateWithObject(team) {
                searchResultTeams.append(team)
            }
        }
        
        teamList.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false
        
        //Clear the text, dismiss the keyboard, and hide the cancel
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
        
        //Reload the team list table
        teamList.reloadData()
    }
    //
    
    //Function for setting the editing of the teams
    @IBAction func editTeamsPressed(sender: UIBarButtonItem) {
        teamList.beginUpdates()
        //When the edit button is pressed...
        if self.editing {
            //Stop editing
            self.setEditing(false, animated: true)
            //Change the label back
            editTeamsButton.title = "Edit Teams"
            //Hide the teamList's toolbar
            teamListToolbar.hidden = true
            
            //Undo the scrolling insets
            teamList.contentInset = UIEdgeInsetsZero
            teamList.scrollIndicatorInsets = UIEdgeInsetsZero
            
            for indexPath in teamList.indexPathsForVisibleRows! {
                let cell = teamList.cellForRowAtIndexPath(indexPath)
                
                var teamsArray = [Team]()
                if isSearching {
                    teamsArray = searchResultTeams
                } else {
                    teamsArray = teams
                }
                
                cell!.textLabel?.text = "Team \(teamsArray[indexPath.row].teamNumber!)"
            }
        } else {
            self.setEditing(true, animated: true)
            editTeamsButton.title = "Finish Editing"
            
            teamListToolbar.hidden = false
            
            //Fix the scrolling so the toolbar doesn't hide any cells
            teamList.contentInset = adjustsForToolbarInsets!
            teamList.scrollIndicatorInsets = adjustsForToolbarInsets!
            
            for indexPath in teamList.indexPathsForVisibleRows! {
                let cell = teamList.cellForRowAtIndexPath(indexPath)
                
                var teamsArray = [Team]()
                if isSearching {
                    teamsArray = searchResultTeams
                } else {
                    teamsArray = teams
                }
                
                cell!.textLabel?.text = "\(teamsArray[indexPath.row].teamNumber!)"
            }
        }
        teamList.endUpdates()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        teamList.setEditing(editing, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "statsSegue" {
            let destinationVC = segue.destinationViewController as! StatsVC
            
            destinationVC.team = teamSelected!
        }
    }
    
    //Functionality for the Segemtned Control
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
    }
}