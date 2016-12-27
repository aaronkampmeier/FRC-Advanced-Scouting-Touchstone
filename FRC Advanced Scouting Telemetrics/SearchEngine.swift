//
//  SearchEngine.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/26/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

class TeamSearchEngine {
    let dataManager = DataManager()
    
    let event: Event?
    let teams: [Team]
    let localTeams: [LocalTeam] //Important that teams and local teams are kept in same order
    
    private var searchResults: [Team] = []
    private var localSearchResults: [LocalTeam] = []
    
    init(forEvent event: Event? = nil) {
        self.event = event
        teams = dataManager.localTeamRanking(forEvent: event)
        localTeams = UniversalToLocalConversion<Team,LocalTeam>(universalObjects: teams).convertToLocal()
    }
    
    func update(forSearchString searchString: String) {
        //Create the predicate
        let predicate = NSPredicate(format: "teamNumber like %a OR name like[cd] %a OR nickname LIKE[cd] %a OR location LIKE[cd] %a OR website LIKE[cd] %a OR rookieYear LIKE %a", argumentArray: [searchString])
        
        searchResults = teams.filter() {predicate.evaluate(with: $0)}
        
        //Now search the local objects
        let localPredicate = NSPredicate(format: "notes CONTAINS[cd] %a OR robotHeight LIKE %a OR robotWeight LIKE %a", argumentArray: [searchString])
        
        localSearchResults = localTeams.filter() {localPredicate.evaluate(with: $0)}
        
        //TODO: Now sift through the two and come up with a singular list of search results of type [Team]
    }
}
