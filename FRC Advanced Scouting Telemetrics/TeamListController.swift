//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

///DEPRECATED -- USING TeamListTableViewController and TeamListDetailViewController now

//import UIKit
//import Crashlytics
//import NYTPhotoViewer

//class TeamListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
//	
//	@IBOutlet weak var searchBar: UISearchBar!
//	@IBOutlet weak var teamList: UITableView!
//	
//    @IBOutlet weak var teamListToolbar: UIToolbar!
//	
//	@IBOutlet weak var updateButton: UIBarButtonItem!
//	
//	var searchBase = [TeamCache]()
//    var searchResultTeams = [TeamCache]()
//	var isSearching = false {
//		didSet {
//		if !isSearching {
//			searchBase.removeAll()
//			currentTeamsToDisplay = currentRegionalTeams
//		} else {
//			searchBase = currentTeamsToDisplay
//		}
//		}
//	}
//	
//	var currentlyEditingTeams = false
//	
//	//MARK: - ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//	
//	//MARK: Search Bar
//    //Functions for the search bar delegate
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        //Set that we are searching
//        isSearching = true
//        
//        //Show the cancel button
//        searchBar.showsCancelButton = true
//    }
//    
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        
//    }
//    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        //Clear the previous search results
//        searchResultTeams.removeAll()
//        
//        //Create a predicate
//        var predicate: NSPredicate
//        
//        if searchText.characters.count == 0 {
//            predicate = NSPredicate(value: true)
//        } else {
//            predicate = NSPredicate(format: "teamNumber contains %@", argumentArray: [searchText])
//        }
//        
//        //Take each team and check if it meets the required criteria, then add it to the search results array
//		for teamCache in searchBase {
//			if predicate.evaluateWithObject(teamCache.team) {
//				searchResultTeams.append(teamCache)
//			}
//		}
//		
//		currentTeamsToDisplay = searchResultTeams
//    }
//    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        isSearching = false
//        
//        //Clear the text, dismiss the keyboard, and hide the cancel
//        searchBar.showsCancelButton = false
//        searchBar.text = ""
//        searchBar.endEditing(true)
//    }
//}
