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
    
    let teamManager = TeamDataManager()
    
    var teams = [Team]()
    var searchResultTeams = [Team]()
    var isSearching = false
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        teams = teamManager.getTeams()
        
    }
    
    func addTeamFromNotification(notification:NSNotification) {
        teams = teamManager.getTeams()
        teamList.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResultTeams.count
        } else {
            return teams.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var teamDataArray = [Team]()
        
        //If there are search results, then display those
        if isSearching {
            teamDataArray = searchResultTeams
        } else {
            teamDataArray = teams
        }
        
        let cell = teamList.dequeueReusableCellWithIdentifier("Cell")
        
        cell!.textLabel?.text = "Team \(teamDataArray[indexPath.row].valueForKey("teamNumber") as! String)"
        
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
        
        let teamSelected = teamDataArray[indexPath.row]
        
        teamNumberLabel.text = teamSelected.teamNumber
        
        weightLabel.text = "Weight: \(teamSelected.robotWeight!) lbs"
        
        driverExpLabel.text = "Driver Exp: \(teamSelected.driverExp!) yrs"
        
        //Populate the images, if there are images
        if let image = teamSelected.frontImage {
            frontImageView.image = UIImage(data: image)
        } else {
            frontImageView.image = nil
        }
        if let image = teamSelected.sideImage {
            sideImageView.image = UIImage(data: image)
        } else {
            sideImageView.image = nil
        }
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
    //
    
    //Functions for the search bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //Set that we are searching
        isSearching = true
        
        //Show the cancel button
        searchBar.showsCancelButton = true
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
    
    //Functionality for the Segemtned Control
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
    }
}