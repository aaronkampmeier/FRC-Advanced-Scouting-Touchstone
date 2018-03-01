//
//  CloudImportManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

class CloudEventImportManager {
    fileprivate let realmController = RealmController.realmController
    fileprivate let cloudConnection = CloudData()
    
    fileprivate let completionHandler: (Bool, ImportError?) -> Void
    
    //Pre-existing objects
    fileprivate let currentEvents: Results<Event>
    fileprivate let currentTeams: [Team]
    fileprivate let currentScoutedTeams: Results<ScoutedTeam>
    fileprivate let currentMatches: Results<Match>
    fileprivate let currentScoutedMatchPerformances: Results<ScoutedMatchPerformance>
    fileprivate let currentScoutedMatches: Results<ScoutedMatch>
    fileprivate let frcEvent: FRCEvent
    
    //Created objects (Including objects that were pre-existing but still would have been created were they not)
    fileprivate var eventObject: Event?
    fileprivate var scoutedEventRanker: EventRanker?
    fileprivate var teamObjects: [Team] = []
    fileprivate var teamEventPerformanceObjects: [TeamEventPerformance] = []
    fileprivate var matchObjects: [Match] = []
    fileprivate var teamMatchPerformanceObjects: [TeamMatchPerformance] = []
    
    init(shouldPreload: Bool, forEvent frcEvent: FRCEvent, withCompletionHandler completionHandler: @escaping (Bool, ImportError?) -> Void) {
        if shouldPreload {
            
        }
        
        self.completionHandler = completionHandler
        currentEvents = realmController.generalRealm.objects(Event.self)
        currentTeams = realmController.teamRanking()
        currentScoutedTeams = realmController.syncedRealm.objects(ScoutedTeam.self)
        currentMatches = realmController.generalRealm.objects(Match.self)
        currentScoutedMatchPerformances = realmController.syncedRealm.objects(ScoutedMatchPerformance.self)
        currentScoutedMatches = realmController.syncedRealm.objects(ScoutedMatch.self)
        self.frcEvent = frcEvent
    }
    
    ///Takes an FRCEvent and creates core data objects in the database
    func `import`() {
        
        
        //First make sure the event being added is not already in the database
        if currentEvents.contains(where: {event in
            return event.key == frcEvent.key
        }) {
            throwError(error: .EventAlreadyInDatabase)
            return
        }
        
        CLSNSLogv("Beginning import of event: %@", getVaList([frcEvent.key]))
        
        ///Begin the Write
        realmController.generalRealm.beginWrite()
        realmController.syncedRealm.beginWrite()
        
        //Create an event object
        let event: Event = Event()
        event.key = frcEvent.key
        realmController.generalRealm.add(event, update: true)
        
        //Start loading the teams
        cloudConnection.teams(forEventKey: frcEvent.key, withCompletionHandler: importTeams)
        
        event.code = frcEvent.eventCode
        event.eventType = frcEvent.eventType
        event.eventTypeString = frcEvent.eventTypeString
        event.name = frcEvent.name
        event.year = frcEvent.year
        event.location = frcEvent.locationName
        
        //Create the local one if there is no local object already
        if let eventRanker = realmController.getTeamRanker(forEvent: event) {
            scoutedEventRanker = eventRanker
        } else {
            //No hay uno
            let eventRanker = EventRanker()
            eventRanker.key = event.key
            scoutedEventRanker = eventRanker
            realmController.syncedRealm.add(eventRanker, update: true)
        }
        
        eventObject = event
    }
    
    fileprivate func importTeams(fromTeams teams: [FRCTeam]?) {
        CLSNSLogv("Beginning import of teams from event", getVaList([]))
        if let frcTeams = teams {
            let sortedTeams = frcTeams.sorted {(firstTeam, secondTeam) in
                return firstTeam.teamNumber < secondTeam.teamNumber
            }
            for frcTeam in sortedTeams {
                //Check to make sure the team isn't already in the database
                let team: Team
                if let index = currentTeams.index(where: {team in
                    return team.key == frcTeam.key
                }) {
                    //If it is in the database, use that team and just update its properties if out of date
                    team = currentTeams[index]
                } else {
                    //Create a new team and set its properties
                    team = Team()
                    team.key = frcTeam.key
                    realmController.generalRealm.add(team, update: true)
                }
                
                team.location = frcTeam.stateProv
                team.name = frcTeam.name
                team.nickname = frcTeam.nickname ?? "\(frcTeam.teamNumber)"
                team.rookieYear = frcTeam.rookieYear
                team.teamNumber = frcTeam.teamNumber
                team.website = frcTeam.website
                
                //Check if it already has a local equivalent
                let scoutedTeam: ScoutedTeam
                if let index = currentScoutedTeams.index(where: {localTeam in
                    return localTeam.key == team.key
                }) {
                    scoutedTeam = currentScoutedTeams[index]
                } else {
                    //Doesn't have a local equivalent, make one
                    scoutedTeam = ScoutedTeam()
                    scoutedTeam.key = team.key
                    realmController.syncedRealm.add(scoutedTeam, update: true)
                }
                
                //Add the local team to the local event object's ranked teams
                if !(scoutedTeam.eventRankers.contains(scoutedEventRanker!)) {
                    scoutedEventRanker?.rankedTeams.append(scoutedTeam)
                }
                //Add the local team to the local ranking object
                if !realmController.getGeneralTeamRanker().rankedTeams.contains(scoutedTeam) {
                    realmController.getGeneralTeamRanker().rankedTeams.append(scoutedTeam)
                }
                
                //Now create the TeamEventPerformance object
                let teamEventPerformance = TeamEventPerformance()
                teamEventPerformance.event = eventObject
                teamEventPerformance.team = team
                teamEventPerformance.key = "\(teamEventPerformance.team!.key)_\(teamEventPerformance.event!.key)"
                realmController.generalRealm.add(teamEventPerformance, update: true)
                
                teamEventPerformanceObjects.append(teamEventPerformance)
                
                teamObjects.append(team)
            }
            
            //Now get the matches
            cloudConnection.matches(forEventKey: frcEvent.key, withCompletionHandler: importMatches)
        } else {
            throwError(error: .ErrorLoadingTeams)
        }
    }
    
    fileprivate func importMatches(fromMatches matches: [FRCMatch]?) {
        CLSNSLogv("Beginning import of matches from event", getVaList([]))
        if let frcMatches = matches {
            for frcMatch in frcMatches {
                let match: Match
                if let index = currentMatches.index(where: {match in
                    return match.key == frcMatch.key
                }) {
                    match = currentMatches[index]
                } else {
                    //Create a new match
                    match = Match()
                    match.key = frcMatch.key
                    
                    realmController.generalRealm.add(match, update: true)
                }
                
                match.matchNumber = frcMatch.matchNumber
                switch frcMatch.compLevel {
                case "qm":
                    match.competitionLevel = Match.CompetitionLevel.Qualifier.rawValue
                case "ef":
                    match.competitionLevel = Match.CompetitionLevel.Eliminator.rawValue
                case "sf":
                    match.competitionLevel = Match.CompetitionLevel.SemiFinal.rawValue
                case "qf":
                    match.competitionLevel = Match.CompetitionLevel.QuarterFinal.rawValue
                case "f":
                    match.competitionLevel = Match.CompetitionLevel.Final.rawValue
                default:
                    throwError(error: .InvalidCompetitionLevel)
                    return
                }
                match.setNumber.value = frcMatch.setNumber
                match.time = frcMatch.actualTime
                
                match.event = eventObject
                
                //Create the local match
                let scoutedMatch: ScoutedMatch
                if !currentScoutedMatches.contains(where: {localMatch in
                    return localMatch.key == match.key
                }) {
                    //Does not exist, create it
                    scoutedMatch = ScoutedMatch()
                    scoutedMatch.key = match.key
                    realmController.syncedRealm.add(scoutedMatch, update: true)
                } else {
                    scoutedMatch = match.scouted
                }
                
                let frcAlliances = frcMatch.alliances!
                let blueScore = frcAlliances["blue"]?.score
                let redScore = frcAlliances["red"]?.score
                
                //TBA represents unknown score values as -1 so if the score is -1, then put nil in for the score.
                if blueScore == -1 {
                    scoutedMatch.blueScore.value = nil
                } else {
                    scoutedMatch.blueScore.value = blueScore
                }
                if redScore == -1 {
                    scoutedMatch.redScore.value = nil
                } else {
                    scoutedMatch.redScore.value = redScore
                }
                
                //Set up all the teams in the match
                if let matchAlliances = frcMatch.alliances {
                    for matchAlliance in matchAlliances {
                        let teamStrings = matchAlliance.value.teams
                        for teamString in teamStrings {
                            //Find the TeamEventPerformance that pertains to this team and match
                            let eventPerformance: TeamEventPerformance
                            if let index = teamEventPerformanceObjects.index(where: {eventPerformance in
                                return eventPerformance.team!.key == teamString
                            }) {
                                eventPerformance = teamEventPerformanceObjects[index]
                            } else {
                                //For some reason, this team in the match does was not included in the total teams list of all the teams at this event (TBA's fault). Add the team seperately.
                                cloudConnection.team(withTeamKey: teamString) {(frcTeam) in
                                    if let team = frcTeam {
                                        self.importTeams(fromTeams: [team])
                                    } else {
                                        self.throwError(error: .MatchTeamNotInRoster)
                                        CLSNSLogv("Match (\(frcMatch.key)) team \(teamString) not in roster for event \(self.frcEvent.key)", getVaList([]))
                                    }
                                }
                                //By calling import teams again, it will return back to the matches
                                return
                            }
                            
                            //Create the matchPerformance object
                            let matchPerformance: TeamMatchPerformance
                            matchPerformance = TeamMatchPerformance()
                            matchPerformance.key = "\(match.key)_\(teamString)"
                            realmController.generalRealm.add(matchPerformance, update: true)
                            
                            matchPerformance.match = match
                            matchPerformance.teamEventPerformance = eventPerformance
                            matchPerformance.allianceColor = matchAlliance.key.capitalized
                            matchPerformance.allianceTeam = (teamStrings.index(of: teamString)! + 1) //The array of team strings comes in the correct order from the cloud
                            
                            //Check for a local object
                            if !currentScoutedMatchPerformances.contains(where: {localMatchPerformance in
                                return localMatchPerformance.key == matchPerformance.key
                            }) {
                                //Create a local object
                                let scoutedMatchPerformance = ScoutedMatchPerformance()
                                scoutedMatchPerformance.key = matchPerformance.key
                                realmController.syncedRealm.add(scoutedMatchPerformance, update: true)
                            }
                            
                            teamMatchPerformanceObjects.append(matchPerformance)
                        }
                        
                    }
                } else {
                    //TODO: Send an error saying the alliance data isn't up yet
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"CloudImportNoAllianceData"), object: self)
                }
                
                matchObjects.append(match)
            }
            
            finalize()
        } else {
            //TODO: Send an error saying the match data isn't up yet and to check back later
            throwError(error: .ErrorLoadingMatches)
        }
    }
    
    private func throwError(error: ImportError) {
        realmController.syncedRealm.cancelWrite()
        realmController.generalRealm.cancelWrite()
        completionHandler(false, error)
    }
    
    private func finalize() {
        CLSNSLogv("Finalizing event import", getVaList([]))
        
        do {
            try realmController.syncedRealm.commitWrite()
            try realmController.generalRealm.commitWrite()
        } catch {
            CLSNSLogv("Failed to commit import writes: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdatedTeams"), object: self))
        
        completionHandler(true, nil)
        
        Answers.logCustomEvent(withName: "Imported Event", customAttributes: ["Event Key":frcEvent.key])
    }
    
    enum ImportError: Error {
        case ErrorLoadingTeams
        case ErrorLoadingMatches
        case EventAlreadyInDatabase
        case MatchTeamNotInRoster
        case InvalidCompetitionLevel
        
        var localizedDescription: String {
            get {
                switch self {
                case .ErrorLoadingTeams:
                    return "Error Loading Teams"
                case .ErrorLoadingMatches:
                    return "Error Loading Matches"
                case .EventAlreadyInDatabase:
                    return "Event Already in Database"
                case .MatchTeamNotInRoster:
                    return "Match Team not in Roster"
                case .InvalidCompetitionLevel:
                    return "Invalid Competition Level"
                }
            }
        }
    }
}
