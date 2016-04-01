//
//  SyncingManager.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/2/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

class SyncingManager: NSObject {
	let dataManager = TeamDataManager()
	var mergeStage: MergeStage = MergeStage.Started
	var mergeManager: MergeManager?
	
	let serviceType = "frc-4256-scout"
	
	private let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	
	private let serviceBrowser: MCNearbyServiceBrowser
	
	let session: MCSession
	
	override init() {
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
		serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
		session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .None)
		
		super.init()
		
		serviceAdvertiser.delegate = self
		serviceAdvertiser.startAdvertisingPeer()
		
		serviceBrowser.delegate = self
		serviceBrowser.startBrowsingForPeers()
		
		session.delegate = self
	}
	
	deinit {
		session.disconnect()
		
		serviceAdvertiser.stopAdvertisingPeer()
		serviceBrowser.stopBrowsingForPeers()
	}
	
	func returnServiceBrowser() -> MCNearbyServiceBrowser {
		return serviceBrowser
	}
	
	func returnServiceAdvertiser() -> MCNearbyServiceAdvertiser {
		return serviceAdvertiser
	}
	
	func getServiceBrowserViewController() -> MCBrowserViewController {
		let vc = MCBrowserViewController(browser: serviceBrowser, session: session)
		vc.delegate = self
		vc.maximumNumberOfPeers = 2
		return vc
	}
	
/**
	Sends the local database over to the other device to be merged.
*/
	func sync() -> NSProgress {
		return session.sendResourceAtURL((UIApplication.sharedApplication().delegate as! AppDelegate).coreDataURL, withName: "Database", toPeer: session.connectedPeers.first!, withCompletionHandler: nil)!
	}
}

/** Advertiser Delegate */
extension SyncingManager: MCNearbyServiceAdvertiserDelegate {
	func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
		NSLog("Did not start advertising peer: \(error)")
	}
	
	func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
		NSLog("Did receive invitation from peer: \(peerID); \(peerID.displayName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:ReceivedInvitation", object: self, userInfo: ["peer":peerID.displayName, "context":context ?? "none"])
		}
		invitationHandler(true, session)
	}
}

/** Browser Delegate */
extension SyncingManager: MCNearbyServiceBrowserDelegate {
	func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
		NSLog("Didn't start browsing: \(error)")
	}
	
	func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("Found peer: \(peerID.displayName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:FoundPeer", object: self, userInfo: ["peer":peerID.displayName, "info":info ?? [:]])
		}
		
//		NSLog("Inviting Peer: \(peerID.displayName)")
//		browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 10)
	}
	
	func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("Lost Peer: \(peerID.displayName)")
	}
	
	
}

/** Session Delegate */
extension SyncingManager: MCSessionDelegate {
	func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
		NSLog("Received Data: \(data)")
	}
	
	func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
		NSLog("Peer: \(peerID.displayName), Did change state: \(state.stringValue())")
		
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:DidChangeState", object: self, userInfo: ["peer":peerID.displayName, "state":state.rawValue])
		}
	}
	
	func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("Received Stream")
	}
	
	func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
		NSLog("Did finish receiving resource: \(resourceName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:DidFinishReceiving", object: self, userInfo: ["peer": peerID.displayName, "url":localURL, "name":resourceName])
		}
		
		//Create a manager to manage the merge
		mergeManager = MergeManager(foreignDatabaseURL: localURL)
		do {
			try mergeManager?.merge()
		} catch {
			NSLog("Unable to merge the databases.")
			NSNotificationCenter.defaultCenter().postNotificationName("MergeFailed", object: mergeManager, userInfo: ["error":(error as! MergeManager.MergeError).description])
		}
	}
	
	func mergeDatabases(fromSourceURL sourceURL: NSURL) {
		do {
			//Get some helper constants
			let model = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectModel
			let destinationURL = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataURL
			let options = [
				NSMigratePersistentStoresAutomaticallyOption: true,
				NSInferMappingModelAutomaticallyOption: true,
				NSSQLitePragmasOption: ["journal_mode":"DELETE"],
			]
			
			//Prepare for the merge by setting up the persistent stores in their own coordinators
			let foreignPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
			let foreignPersistentStore = try foreignPersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sourceURL, options: options)
			let foreignObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			foreignObjectContext.persistentStoreCoordinator = foreignPersistentStoreCoordinator
//			let localPersistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
//			let localPersistentStore = localPersistentStoreCoordinator.persistentStores.first!
//			let localManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
			
			//Remove the defenses from the foreign database
			do {
				let defenses = try foreignObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Defense")) as! [Defense]
				for defense in defenses {
					foreignObjectContext.deleteObject(defense)
				}
				try foreignObjectContext.save()
			} catch {
				NSLog("Unable to clear defenses from foreign database. Remedy this manually.")
			}
			
			do {
				try foreignPersistentStoreCoordinator.migratePersistentStore(foreignPersistentStore, toURL: destinationURL, options: options, withType: NSSQLiteStoreType)
			} catch {
				NSLog("Unable to merge databases. Error: \(error)")
			}
		} catch {
			NSLog("Merge Failed. Error: \(error)")
		}
		NSLog("Finished with attempted merge")
		
		//Remove the recently received database from the filesystem
//		do {
//			try NSFileManager.defaultManager().removeItemAtURL(sourceURL)
//		} catch {
//			NSLog("Unable to delete the foreign database")
//		}
		
		TeamDataManager().commitChanges()
		
		//Now, fix all the duplicate entities
		//Clear the managed object context
		TeamDataManager.managedContext.reset()
		mergeStage = .Started
		mergeData(conflictResolutions: nil)
	}
	
	enum MergeStage: Int {
		case Started
		case Teams
		case Regionals
		case Matches
		case MatchPerformances
		case RegionalPerformances
	}
	
	func mergeData(conflictResolutions resolutions: [String:AnyObject]?) {
		/*
		//Draft board will fix itself on next run
		//Fix the defenses
		/*do {
		let defenseNames = ["Portcullis", "Cheval de Frise", "Moat", "Ramparts", "Drawbridge", "Sally Port", "Rock Wall", "Rough Terrain", "Low Bar"]
		//Fetch all the defenses
		let defenses = dataManager.getAllDefenses()
		for defenseName in defenseNames {
		let filteredDefenses = defenses.filter() {
		return $0.defenseName == defenseName
		}
		
		if filteredDefenses.count > 1 {
		//More than one of a defense, transfer all of one defenses relationships to the other
		
		}
		}
		}*/
		
		switch mergeStage {
		case .Started:
			//First merge all the teams
			mergeTeams(conflictResolution: resolutions as! [String:Team])
		case .Teams:
			break
		default:
			break
		}
		
		//Fix the regionals
		do {
			var regionals = dataManager.getAllRegionals()
			for regional in regionals {
				let filteredRegionals = regionals.filter() {
					return $0.name == regional.name
				}
				
				let mergedRegional = filteredRegionals.reduce(dataManager.addRegional(regionalNumber: (filteredRegionals.first?.regionalNumber!.integerValue)!, withName: (filteredRegionals.first?.name)!)) {(mergedRegional, regional) in
					for match in regional.matches?.allObjects as! [Match] {
						match.regional = mergedRegional
					}
					for regionalPerformance in regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance] {
						regionalPerformance.regional = mergedRegional
					}
					return mergedRegional
				}
				
				//Delete the previous, unmerged, regionals
				//And Remove all of the extracted regionals from the array of unmerged regionals
				for regional in filteredRegionals {
					dataManager.delete(Regional: regional)
					regionals.removeAtIndex(regionals.indexOf(regional)!)
				}
				
				//Now combine the matches
				let matchesInMergedRegional = mergedRegional.matches?.allObjects as! [Match]
				for match in matchesInMergedRegional {
					let filteredMatches = matchesInMergedRegional.filter() {
						return $0.matchNumber ==  match.matchNumber
					}
					
					let m = try dataManager.createNewMatch(match.matchNumber!.integerValue, inRegional: mergedRegional)
					let mergedMatch = filteredMatches.reduce(m) {(mergedMatch, match) in
						//Combine all the team performances into the merged match
						for teamPerformance in match.teamPerformances?.allObjects as! [TeamMatchPerformance] {
							teamPerformance.match = mergedMatch
						}
						
						do {
							//Combine all the breached defenses
							let redDefensesBreached = mergedMatch.redDefensesBreached?.mutableCopy() as! NSMutableSet
							for redBreachedDefense in match.redDefensesBreached?.allObjects as! [Defense] {
								redDefensesBreached.addObject(redBreachedDefense)
							}
							let newBlueBreached = mergedMatch.blueDefensesBreached?.mutableCopy() as! NSMutableSet
							for blueBreached in match.blueDefensesBreached?.allObjects as! [Defense] {
								newBlueBreached.addObject(blueBreached)
							}
							mergedMatch.redDefensesBreached = (redDefensesBreached.copy() as! NSSet)
							mergedMatch.blueDefensesBreached = (newBlueBreached.copy() as! NSSet)
							
							//Combine the defenses
							let newDefenses = mergedMatch.defenses?.mutableCopy() as! NSMutableSet
							for defense in match.defenses?.allObjects as! [Defense] {
								newDefenses.addObject(defense)
							}
							mergedMatch.defenses = (newDefenses.copy() as! NSSet)
							
							//Now merge the defenses
							var mergedRedBreached = mergedMatch.redDefensesBreached?.allObjects as! [Defense]
							for breachedDefense in mergedRedBreached {
								var filteredRedBreached = mergedRedBreached.filter() {
									return $0.defenseName == breachedDefense.defenseName
								}
								
								//Remove the first defense from the filtered to keep it in the mergedRedBreached
								filteredRedBreached.removeAtIndex(0)
								for defense in filteredRedBreached {
									mergedRedBreached.removeAtIndex(mergedRedBreached.indexOf(defense)!)
								}
							}
							var mergedBlueBreached = mergedMatch.blueDefensesBreached?.allObjects as! [Defense]
							for breachedDefense in mergedBlueBreached {
								var filteredBlueBreached = mergedBlueBreached.filter() {
									return $0.defenseName == breachedDefense.defenseName
								}
								
								//Remove the first defense from the filtered to keep it in the mergedBlueBreached
								filteredBlueBreached.removeAtIndex(0)
								for defense in filteredBlueBreached {
									mergedBlueBreached.removeAtIndex(mergedBlueBreached.indexOf(defense)!)
								}
							}
							//Set them back
							mergedMatch.redDefensesBreached = NSSet(array: mergedRedBreached)
							mergedMatch.blueDefensesBreached = NSSet(array: mergedBlueBreached)
							
							var mergedDefenses = mergedMatch.defenses?.mutableCopy() as! NSMutableSet
							for defense in mergedDefenses {
								var filteredDefenses = mergedDefenses.filter() {
									return $0.defenseName == defense.defenseName
								}
								
								filteredDefenses.removeAtIndex(0)
								for defense in filteredDefenses {
									mergedDefenses.removeObject(defense)
								}
							}
							if mergedDefenses.count > 4 {
								mergedDefenses = NSMutableSet(array: mergedDefenses.dropLast(mergedDefenses.count-4).filter(){_ in return true})
							}
							mergedMatch.defenses = mergedDefenses.copy() as! NSSet
						}
						
						dataManager.deleteMatch(match)
						
						return mergedMatch
					}
					
					//Now merge the match performances
					do {
						let combinedMatchPerformances = mergedMatch.teamPerformances?.allObjects as! [TeamMatchPerformance]
						for matchPerformance in combinedMatchPerformances {
							let filteredMatchPerformances = combinedMatchPerformances.filter() {
								return $0.allianceColor == matchPerformance.allianceColor && $0.allianceTeam == matchPerformance.allianceTeam
							}
							
							var teamIsSame = false
							//First check if the team is the same for that alliance color and team
							filteredMatchPerformances.forEach() { performance in
								//teamIsSame = performance.regionalPerformance?.team
							}
						}
					}
				}
			}
		} catch {
			NSLog("Unable to completely fix all duplicates and syncing conflicts (base: regionals): \(error)")
		}
*/
	}
	
	func mergeTeams(conflictResolution resolution: [String:Team]?) {
//		do {
//			let teams = dataManager.getTeams()
			//Example COnflict data structuring
//			let mainConflictTitle = "Teams"
//			let conflicts = ["4256":["localDetail":"Weight: 400", "externalDetail":"Weight 350"]]
//			let selectionHandler: ([String:SyncSource]) -> Void
			
//			var hasConflict = false
//			var conflicts = [String:[String:[String:AnyObject]]]()
//			for team in teams {
//				//Find all teams with the same number
//				let filteredTeams = teams.filter() {
//					$0.teamNumber == team.teamNumber
//				}
//				
//				//Check for data conflicts with the teams
//				for team in filteredTeams {
//					filteredTeams.forEach() {
//						if !($0.driverExp!.isEqualToNumber(team.driverExp!) && $0.robotWeight!.isEqualToNumber(team.robotWeight!) && $0.frontImage!.isEqualToData(team.frontImage!) && $0.sideImage!.isEqualToData(team.sideImage!)) && $0.defensesAbleToCross!.isEqualToSet(team.defensesAbleToCross! as Set<NSObject>) {
//							hasConflict = true
//							conflicts.updateValue(["local":["localObject":filteredTeams[0],"localDetail":"Weight: \(filteredTeams[0].robotWeight)"], "external":["externalObject":filteredTeams[1],"externalDetail":"Weight: \(filteredTeams[1].robotWeight)"]], forKey: "\(team.teamNumber)")
//						}
//					}
//				}
			
//				if hasConflict {
//					//First check if there is a resolution for it
//					if resolution != nil {
//						//There is a resolution, implement it
//						filteredTeams = [resolution[""]]
//					} else {
//						//Post a conflict notification
//						dispatch_async(dispatch_get_main_queue()) {
//							NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:MergeConflict", object: self, userInfo: ["conflictTitle":"Teams", "conflicts":conflicts])
//					}
//						
//						//Exit this merge
//						return
//					}
//				}
//				
//				//Combine the relationships of the teams and make a merged team
//				let mergedTeam = filteredTeams.reduce(dataManager.saveTeamNumber(team.teamNumber!)) {(mergedTeam, team) in
//					//Combine Regional Performances
//					for performance in team.regionalPerformances?.allObjects as! [TeamRegionalPerformance] {
//						performance.team = mergedTeam
//					}
//					
//					//Combine defenses able to cross
//					var defensesAbleToCross = mergedTeam.defensesAbleToCross?.mutableCopy() as! NSMutableSet
//					for defense in team.defensesAbleToCross?.allObjects as! [Defense] {
//						defensesAbleToCross.addObject(defense)
//					}
//					mergedTeam.defensesAbleToCross = (defensesAbleToCross.copy() as! NSSet)
//					
//					//Draft Board fixes itself upon next call of said function in TeamDataManager
//					
//					dataManager.deleteTeam(team)
//					
//					return mergedTeam
//				}
//			
//				//Now merge the defensesAbleToCross in the mergedTeam, not the team performaces, because that will happen from the regional-based merging.
//				var defensesAbleToCross = mergedTeam.defensesAbleToCross?.allObjects as! [Defense]
//				for defense in defensesAbleToCross {
//					var filteredDefenses = defensesAbleToCross.filter() {
//						$0.defenseName == defense.defenseName
//					}
//					
//					//Remove one to keep it
//					filteredDefenses.removeFirst()
//					for defense in filteredDefenses {
//						defensesAbleToCross.removeAtIndex(defensesAbleToCross.indexOf(defense)!)
//					}
//				}
//				
//				mergedTeam.defensesAbleToCross = NSSet(array: defensesAbleToCross)
//			}
//		}
	}
	
	func teamConflictsResolved(resolvedConflicts: [String:SyncSource]) {
		
	}
	
	enum ConflictResolvedHandler {
		case Team(([String:SyncSource]) -> Void)
	}
	
	enum SyncSource {
		case Local
		case External
	}
	
	func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
		NSLog("Did start receiving resource: \(resourceName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:DidStartReceiving", object: self, userInfo: ["peer":peerID.displayName, "name":resourceName, "progress":progress])
		}
	}
}

/** BrowserVC Delegate */
extension SyncingManager: MCBrowserViewControllerDelegate {
	func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
		browserViewController.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
		browserViewController.dismissViewControllerAnimated(true, completion: nil)
	}
	
//	func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
//		//For now just display everyone
//		NSLog("Should display: \(peerID.displayName)?")
//		return true
//	}
}

extension MCSessionState {
	func stringValue() -> String {
		switch self {
		case .NotConnected:
			return "Not Connected"
		case .Connecting:
			return "Connecting"
		case .Connected:
			return "Connected"
		}
	}
}

typealias SessionState = MCSessionState

class MergeManager {
	let foreignDatabaseURL: NSURL
	let localDatabaseURL: NSURL
	let options = [
		NSMigratePersistentStoresAutomaticallyOption: true,
		NSInferMappingModelAutomaticallyOption: true,
		NSSQLitePragmasOption: ["journal_mode":"DELETE"],
		]
	let model = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectModel
	let managedObjectContext: NSManagedObjectContext
	
	let dataManager = TeamDataManager()
	var conflictManager: ConflictManager?
	var conflicts = [Conflict]()
	
	convenience init(foreignDatabaseURL foreignURL: NSURL) {
		let destinationURL = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataURL
		
		self.init(fromURL: foreignURL, intoURL: destinationURL)
	}
	
	init(fromURL foreignURL: NSURL, intoURL localURL: NSURL) {
		foreignDatabaseURL = foreignURL
		localDatabaseURL = localURL
		
		managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	}
	
	func merge() throws {
		//First merge the databases
		do {
			//Prepare for the merge by setting up the persistent stores in their own coordinators
			let foreignPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
			let foreignPersistentStore = try foreignPersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: foreignDatabaseURL, options: options)
			let foreignObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			foreignObjectContext.persistentStoreCoordinator = foreignPersistentStoreCoordinator
			
			//Remove the defenses from the foreign database
//			do {
//				let defenses = try foreignObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Defense")) as! [Defense]
//				for defense in defenses {
//					foreignObjectContext.deleteObject(defense)
//				}
//				try foreignObjectContext.save()
//			} catch {
//				NSLog("Unable to clear defenses from foreign database. Remedy this manually.")
//			}
			
			do {
				try foreignPersistentStoreCoordinator.migratePersistentStore(foreignPersistentStore, toURL: localDatabaseURL, options: options, withType: NSSQLiteStoreType)
				//Succesful, so clear the managed object context
				//managedObjectContext.reset()
			} catch {
				NSLog("Unable to merge databases. Error: \(error)")
				throw MergeError.UnableToMigratePersistentStore
			}
		} catch {
			NSLog("Merge Failed. Error: \(error)")
			throw MergeError.UnableToAddStoreToForeignCoordinator
		}
		NSLog("Finished with attempted database merge")
		
		//First check for conflicts
		checkForConflicts()
		//Then resolve them
		resolveConflicts()
	}
	
	func registerConflictManager(notification: NSNotification) {
		conflictManager = (notification.object as! ConflictManager)
	}
	
	func resolveConflicts() {
		if let manager = conflictManager {
			let conflictingConflicts = conflicts.filter() {$0.priority == ConflictPriority.High && $0.doesConflict}
			if conflictingConflicts.count > 0  {
				manager.conflictManager(resolveConflicts: conflicts) {_ in
					self.mergeManagedObjects()
				}
			} else {
				mergeManagedObjects()
			}
		} else {
			NSTimer(timeInterval: 0.01, target: self, selector: "recheckResolvingConflicts:", userInfo: nil, repeats: false)
		}
	}
	
	func recheckResolvingConflicts(timer: NSTimer) {
		resolveConflicts()
	}
	
	func checkForConflicts() {
		NSNotificationCenter.defaultCenter().addObserverForName("Registering for conflict manager", object: nil, queue: nil, usingBlock: registerConflictManager)
		NSNotificationCenter.defaultCenter().postNotificationName("Registration needed for conflict manager", object: self)
		
		let entityNames = ["DraftBoard", "Team", "Defense", "TeamRegionalPerformance", "Regional", "AutonomousCycle", "TeamMatchPerformance", "Shot", "DefenseCrossTime", "Match", "TimeMarker"]
		
		for entityName in entityNames {
			switch entityName {
			case "Team":
				let teams = fetchManagedbjects("Team", type: Team.self)
				for team in teams {
					//Find other teams with that same team number
					let sameTeams = teams.filter() {$0.teamNumber == team.teamNumber}
					let secondIndex: Int
					if sameTeams.count > 1 {secondIndex = 1} else {secondIndex = 0}
					findConflicts(firstObject: sameTeams[0], secondObject: sameTeams[secondIndex])
				}
			case "Match":
				let matches = fetchManagedbjects("Match", type: Match.self)
				for match in matches {
					let sameMatches = matches.filter() {$0.matchNumber! == match.matchNumber! && $0.regional!.regionalNumber! == match.regional!.regionalNumber!}
					let secondIndex: Int
					if sameMatches.count > 1 {secondIndex = 1} else {secondIndex = 0}
					findConflicts(firstObject: sameMatches[0], secondObject: sameMatches[secondIndex])
				}
			case "TeamMatchPerformance":
				let matchPerformances = fetchManagedbjects("TeamMatchPerformance", type: TeamMatchPerformance.self)
				for performance in matchPerformances {
					let samePerformances = matchPerformances.filter() {
						if !($0.match?.matchNumber == performance.match?.matchNumber && $0.match?.regional?.regionalNumber == performance.match?.regional?.regionalNumber) {
							return false
						} else if !($0.allianceColor == performance.allianceColor && $0.allianceTeam == performance.allianceTeam) {
							return false
						} else {
							return true
						}
					}
					
					let secondIndex: Int
					if samePerformances.count > 1 {secondIndex = 1} else {secondIndex = 0}
					findConflicts(firstObject: samePerformances[0], secondObject: samePerformances[secondIndex])
				}
			default:
				break
			}
		}
	}
	
	func findConflicts<T:NSManagedObject>(firstObject genericFirst: T, secondObject genericSecond: T) {
		var newConflicts = [Conflict]()
		switch T.self {
		case is Team.Type:
			do {
				let first = genericFirst as! Team
				let second = genericSecond as! Team
				assert(first.teamNumber! == second.teamNumber!, "Finding conflicts between: Team \(first.teamNumber!) and Team \(second.teamNumber). It is not possible to check for conflicts between teams of different team numbers.")
				
				newConflicts.append(Conflict(title: "Drive Train", description: "", identifier: "Team:\(first.teamNumber!):DriveTrain", priority: .Medium, localValue: first.driveTrain ?? 0, foreignValue: second.driveTrain ?? 0))
				newConflicts.append(Conflict(title: "Front Image", description: "", identifier: "Team:\(first.teamNumber!):FrontImage", priority: .Medium, localValue: first.frontImage ?? 0, foreignValue: second.frontImage ?? 0))
				newConflicts.append(Conflict(title: "Side Image", description: "", identifier: "Team:\(first.teamNumber!):SideImage", priority: .Medium, localValue: first.sideImage ?? 0, foreignValue: second.sideImage ?? 0))
				newConflicts.append(Conflict(title: "Autonomous Defenses Able to Cross", description: "", identifier: "Team:\(first.teamNumber!):AutonomousDefensesAbleToCross", priority: .High, localValue: first.autonomousDefensesAbleToCross ?? 0, foreignValue: second.autonomousDefensesAbleToCross ?? 0))
				newConflicts.append(Conflict(title: "Defenses Able to Cross", description: "", identifier: "Team:\(first.teamNumber!):DefensesAbleToCross", priority: .High, localValue: first.defensesAbleToCross ?? 0, foreignValue: second.defensesAbleToCross ?? 0))
			}
		case is Match.Type:
			do {
				let first = genericFirst as! Match
				let second = genericSecond as! Match
				assert((first.matchNumber?.isEqualToNumber(second.matchNumber!))! && first.regional!.regionalNumber!.isEqualToNumber(second.regional!.regionalNumber!), "Match numbers/regionals aren't the same, can't find conflicts.")
				
//				//Find the teams participating in each match
//				let firstTeams: [Team] = (first.teamPerformances?.allObjects as! [TeamMatchPerformance]).map() {team in
//					return (team.regionalPerformance?.team)!
//				}
//				let secondTeams: [Team] = (second.teamPerformances?.allObjects as! [TeamMatchPerformance]).map() {team in
//					return (team.regionalPerformance?.team)!
//				}
				
				let conflictIDPrefix = "Match:\(first.regional!.regionalNumber!):\(first.matchNumber!)"
				newConflicts.append(Conflict(title: "Blue Defenses", description: "", identifier: "\(conflictIDPrefix):BlueDefenses", priority: .Medium, localValue: first.blueDefenses ?? 0, foreignValue: second.blueDefenses ?? 0))
				newConflicts.append(Conflict(title: "Red Defenses", description: "", identifier: "\(conflictIDPrefix):RedDefenses", priority: .Medium, localValue: first.redDefenses ?? 0, foreignValue: second.redDefenses ?? 0))
			}
		case is TeamMatchPerformance.Type:
			do {
				let first = genericFirst as! TeamMatchPerformance
				let second = genericSecond as! TeamMatchPerformance
				assert(first.match?.regional?.regionalNumber == second.match?.regional?.regionalNumber && first.match?.matchNumber == second.match?.matchNumber && first.allianceColor == second.allianceColor && first.allianceTeam == second.allianceTeam, "The TeamMatchPerformances don't line up.")
				
				let conflictIDPrefix = "TeamMatchPerformance:\((first.match?.regional?.regionalNumber)!):\((first.match?.matchNumber)!):\(first.allianceColor!).\(first.allianceTeam!)"
				newConflicts.append(Conflict(title: "Match Performance Data", description: "", identifier: "\(conflictIDPrefix):Data", priority: .High, localValue: first, foreignValue: second))
			}
		default:
			break
		}
		
		//Try to solve ones that aren't complex or even conflicting here
		for conflict in newConflicts {
			if !conflict.doesConflict {
				conflict.resolution = conflict.payload1
			} else if conflict.payload1.equalToOther(0) && !conflict.payload2.equalToOther(0) {
				conflict.resolution = conflict.payload2
			} else if !conflict.payload1.equalToOther(0) && conflict.payload2.equalToOther(0) {
				conflict.resolution = conflict.payload1
			}
		}
		
		switch T.self {
		case is Match.Type:
			//Resolve the medium level conflicts
			for conflict in newConflicts.filter({$0.priority == ConflictPriority.Medium && $0.resolution == nil}) {
				let firstDefenses = conflict.payload1 as? NSSet
				let secondDefenses = conflict.payload2 as? NSSet
				
				if firstDefenses?.count > secondDefenses?.count {
					conflict.resolution = firstDefenses
				} else {
					conflict.resolution = secondDefenses
				}
			}
		case is TeamMatchPerformance.Type:
		//Try to find a resolution
			let first = genericFirst as! TeamMatchPerformance
			let second = genericSecond as! TeamMatchPerformance
			let conflict = newConflicts.first!
			
			if first.timeMarkers?.count > second.timeMarkers?.count {
				conflict.resolution = first
			} else if second.timeMarkers?.count > first.timeMarkers?.count {
				conflict.resolution = second
			}
			
		default:
			break
		}
		
		conflicts.appendContentsOf(newConflicts)
	}
	
	///Merges all managed objects in the new combined persistent store.
	func mergeManagedObjects() {
		//Start with the teams
		var teams = fetchManagedbjects("Team", type: Team.self)
		for team in teams {
			//Find other teams with that same team number
			let sameTeams = teams.filter() {$0.teamNumber == team.teamNumber}
			let mergedTeam = sameTeams.reduceToFirst(mergeTwo)
			//Remove those teams so they don't get remerged
			for team in sameTeams {
				teams.removeAtIndex(teams.indexOf(team)!)
			}
		}
		
		//Then the regional performances
		var regionalPerformances = fetchManagedbjects("TeamRegionalPerformance", type: TeamRegionalPerformance.self)
		for performance in regionalPerformances {
			let samePerformances = regionalPerformances.filter() {$0.regional! == performance.regional! && $0.team! == performance.team!}
			let mergedPerformance = samePerformances.reduceToFirst(mergeTwo)
			for performance in samePerformances {
				regionalPerformances.removeAtIndex(regionalPerformances.indexOf(performance)!)
			}
		}
		
		//Next, the Regionals
		var regionals = fetchManagedbjects("Regional", type: Regional.self)
		for regional in regionals {
			let sameRegionals = regionals.filter() {$0.regionalNumber == regional.regionalNumber}
			let mergedRegional = sameRegionals.reduceToFirst(mergeTwo)
			for regional in sameRegionals {
				regionals.removeAtIndex(regionals.indexOf(regional)!)
			}
		}
		
		//Finally the Matches
		var matches = fetchManagedbjects("Match", type: Match.self)
		for match in matches {
			let sameMatches = matches.filter() {$0.matchNumber! == match.matchNumber! && $0.regional!.regionalNumber! == match.regional!.regionalNumber!}
			let mergedMatch = sameMatches.reduceToFirst(mergeTwo)
			for match in sameMatches {
				matches.removeAtIndex(matches.indexOf(match)!)
			}
		}
		
		//And then the match performances
		var matchPerformances = fetchManagedbjects("TeamMatchPerformance", type: TeamMatchPerformance.self)
		for performance in matchPerformances {
			let samePerformances = matchPerformances.filter() {
				if !($0.match?.matchNumber == performance.match?.matchNumber && $0.match?.regional?.regionalNumber == performance.match?.regional?.regionalNumber) {
					return false
				} else if !($0.allianceColor == performance.allianceColor && $0.allianceTeam == performance.allianceTeam) {
					return false
				} else {
					return true
				}
			}
			let mergedPerformance = samePerformances.reduceToFirst(mergeTwo)
			for performance in samePerformances {
				matchPerformances.removeAtIndex(matchPerformances.indexOf(performance)!)
			}
		}
		
		//Present an alert saying it is finished
		let alert = UIAlertController(title: "Merge Finished", message: "The merge has completed and it is now required to quit the app fully and re-launch it. Please do so now.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Quit App", style: .Default) {_ in
			fatalError("Shutting down app to complete merge.")
		})
		NSNotificationCenter.defaultCenter().postNotificationName("MergeManager:MergeCompleted", object: self, userInfo: ["alertToPresent":alert])
	}
	
	private func mergeTwo<T:NSManagedObject>(genericFirst: T, genericSecond: T) -> T {
		switch T.self {
		case is Team.Type:
			let mergedTeam: Team
			do {
				let first = genericFirst as! Team
				let second = genericSecond as! Team
				mergedTeam = dataManager.saveTeamNumber(first.teamNumber!)
				
				//First merge the driver experiences
				mergedTeam.driverExp = first.driverExp ~? second.driverExp // ~? is an operator defined in Globals.swift
				mergedTeam.height = first.height ~? second.height
				mergedTeam.robotWeight = first.robotWeight ~? second.robotWeight
				mergedTeam.visionTrackingRating = first.visionTrackingRating ~? second.visionTrackingRating
				
				mergedTeam.notes = "\(first.notes)\n\(second.notes)"
				
				//Now merge stuff with conflicts
				mergedTeam.driveTrain = (conflictWithID("Team:\(first.teamNumber!):DriveTrain")!.resolution as? String) ?? ""
				mergedTeam.frontImage = (conflictWithID("Team:\(first.teamNumber!):FrontImage")!.resolution as? NSData)
				mergedTeam.sideImage = (conflictWithID("Team:\(first.teamNumber!):SideImage")!.resolution as? NSData)
				mergedTeam.defensesAbleToCross = (conflictWithID("Team:\(first.teamNumber!):DefensesAbleToCross")?.resolution as? NSSet)
				mergedTeam.autonomousDefensesAbleToCross = (conflictWithID("Team:\(first.teamNumber!):AutonomousDefensesAbleToCross")?.resolution as? NSSet)
				mergedTeam.regionalPerformances = first.regionalPerformances + second.regionalPerformances
				
				dataManager.delete(first, second)
			}
			return mergedTeam as! T
		case is TeamRegionalPerformance.Type:
			let mergedPerformance: TeamRegionalPerformance
			do {
				let first = genericFirst as! TeamRegionalPerformance
				let second = genericSecond as! TeamRegionalPerformance
				mergedPerformance = TeamRegionalPerformance(entity: NSEntityDescription.entityForName("TeamRegionalPerformance", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: managedObjectContext)
				
				assert(first.team! == second.team! && first.regional! == second.regional!, "While merging Team Regional Performances, two objects to be merged were from different teams. It is not possible to merge those.")
				mergedPerformance.team = first.team //Should be that first and second's team relationships are the same
				mergedPerformance.matchPerformances = first.matchPerformances + second.matchPerformances
				mergedPerformance.regional = first.regional //Should be that first and second's regional relationships are the same
				
				dataManager.delete(first, second)
			}
			return mergedPerformance as! T
		case is Regional.Type:
			let mergedRegional: Regional
			do {
				let first = genericFirst as! Regional
				let second = genericSecond as! Regional
				mergedRegional = Regional(entity: NSEntityDescription.entityForName("Regional", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: managedObjectContext)
				assert((first.regionalNumber?.equalToOther(second.regionalNumber!))!, "First regional number is not equal to second egional number. Cannot merge.")
				
				mergedRegional.name = first.name ~? second.name
				mergedRegional.regionalNumber = first.regionalNumber //Should be the same for first and second
				mergedRegional.matches = first.matches + second.matches
				mergedRegional.teamRegionalPerformances = first.teamRegionalPerformances + second.teamRegionalPerformances
				
				dataManager.delete(first, second)
			}
			return mergedRegional as! T
		case is Match.Type:
			let mergedMatch: Match
			do {
				let first = genericFirst as! Match
				let second = genericSecond as! Match
				
				mergedMatch = Match(entity: NSEntityDescription.entityForName("Match", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: managedObjectContext)
				
				mergedMatch.blueCapturedTower = first.blueCapturedTower ~? second.blueCapturedTower
				mergedMatch.blueFinalScore = first.blueFinalScore ~? second.blueFinalScore
				mergedMatch.blueRankingPoints = first.blueRankingPoints ~? second.blueRankingPoints
				mergedMatch.matchNumber = first.matchNumber //First and second should be the same
				mergedMatch.redCapturedTower = first.redCapturedTower ~? second.redCapturedTower
				mergedMatch.redFinalScore = first.redFinalScore ~? second.redFinalScore
				mergedMatch.redRankingPoints = first.redRankingPoints ~? second.redRankingPoints
				
				let conflictIDPrefix = "Match:\(first.regional!.regionalNumber!):\(first.matchNumber!)"
				mergedMatch.blueDefenses = conflictWithID("\(conflictIDPrefix):BlueDefenses")?.resolution as! NSSet
				mergedMatch.blueDefensesBreached = first.blueDefensesBreached + second.blueDefensesBreached
				mergedMatch.redDefenses = conflictWithID("\(conflictIDPrefix):RedDefenses")?.resolution as! NSSet
				mergedMatch.redDefensesBreached = first.redDefensesBreached + second.redDefensesBreached
				mergedMatch.regional = first.regional //Should be the same
				mergedMatch.teamPerformances = first.teamPerformances + second.teamPerformances
				
				dataManager.delete(first, second)
			}
			return mergedMatch as! T
		case is TeamMatchPerformance.Type:
			let mergedPerformance: TeamMatchPerformance
			do {
				let first = genericFirst as! TeamMatchPerformance
				let second = genericSecond as! TeamMatchPerformance
				
				let id = "TeamMatchPerformance:\((first.match?.regional?.regionalNumber)!):\((first.match?.matchNumber)!):\(first.allianceColor!).\(first.allianceTeam!):Data"
				let resolvedPerformance = conflictWithID(id)?.resolution as? TeamMatchPerformance
				
				if let performance = resolvedPerformance {
					mergedPerformance = performance
					switch performance {
					case first:
						dataManager.delete(second)
					case second:
						dataManager.delete(first)
					default:
						assertionFailure("Merged Match Performance was neither first nor second.")
					}
				} else {
					fatalError("No conflict resolution for Match Performance: \(id)")
				}
			}
			return mergedPerformance as! T
		default:
			return genericFirst
		}
	}
	
	func conflictWithID(identifier: String) -> Conflict? {
		return conflicts.filter(){$0.identifier == identifier}.first
	}
	
	func fetchManagedbjects<S:NSManagedObject>(entity: String, type: S.Type) -> [S]{
		let fetchRequest = NSFetchRequest(entityName: entity)
		do {
			let results = try managedObjectContext.executeFetchRequest(fetchRequest)
			return results as! [S]
		} catch {
			NSLog("Unable to fetch managed objects")
			return [S]()
		}
	}
	
	enum ConflictPriority {
		case High //These need to be handled by the user on the UI i.e. Matches in a regional
		case Medium //These can't be implicitly dealt with but the manager can roughly merge them
		case Low //These can be dealt with by the manager i.e. Averaging total scores
		case Backend //These need to be resolved by the MergeManager usually because they deal with objects that the user has no knowledge of (TeamRegionalPerformances, DraftBoards, etc.). These usually rely on other High priority conflicts to be resolved.
	}
	
	class Conflict {
		let title: String
		let description: String
		let identifier: String
		let payload1: Payload
		let payload2: Payload
		var doesConflict: Bool {
			get {
				
				if payload1.equalToOther(0) && !payload2.equalToOther(0) {
					return false
				} else if payload2.equalToOther(0) && !payload1.equalToOther(0) {
					return false
				} else {
					return !payload1.equalToOther(payload2)
				}
			}
		}
		var resolution: Payload?
		var priority: MergeManager.ConflictPriority
		
		init(title: String, description: String, identifier: String, priority: MergeManager.ConflictPriority, localValue: Payload, foreignValue: Payload) {
			self.title = title
			self.description = description
			self.identifier = identifier
			self.priority = priority
			payload1 = localValue
			payload2 = foreignValue
		}
	}
	
	enum MergeError: ErrorType {
		case UnableToMigratePersistentStore
		case UnableToAddStoreToForeignCoordinator
		
		var description: String {
			switch self {
			case .UnableToMigratePersistentStore:
				return "Unable to migrate persistent store"
			case .UnableToAddStoreToForeignCoordinator:
				return "Unable to add persistent store to coordinator"
			}
		}
	}
	
	
}

private extension Array {
	func reduceToFirst(reduceTwo: (first: Element, other: Element) -> Element) -> Element? {
		if self.count <= 1 {
			return self.first
		} else {
			var first = self.first!
			var newArray = self
			newArray.removeFirst()
			
			for thing in newArray {
				first = reduceTwo(first: self.first!, other: thing)
			}
			
			return first
		}
	}
}

protocol Payload: CustomStringConvertible {
	func equalToOther(other: Payload) -> Bool
}

extension Double: Payload {
	func equalToOther(other: Payload) -> Bool {
		let otherDouble: Double = other as! Double
		
		return self == otherDouble
	}
}

extension Int: Payload {
	func equalToOther(other: Payload) -> Bool {
		let otherInt = other as! Int
		
		return self == otherInt
	}
}

extension Array: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is Array {
			let otherArray = other as! [Element]
			
			if self.count != otherArray.count {return false} else {
				var isEqual = true
				for thing in self {
					var oneThatEquals = false
					for otherThing in otherArray {
						if (otherThing as! AnyObject) === (thing as! AnyObject) {oneThatEquals = true}
					}
					if !oneThatEquals {
						isEqual = false
					}
				}
				
				if isEqual {return true} else {return false}
			}
		} else {
			return false
		}
	}
}

extension String: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is String {
			let otherString = other as! String
			return self == otherString
		} else {
			return false
		}
	}
	
	public var description: String {
		get {
			return self
		}
	}
}

extension NSNumber: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is NSNumber {
			let otherNumber = other as! NSNumber
			return self.isEqualToNumber(otherNumber)
		} else {
			return false
		}
	}
}

extension NSData: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is NSData {
			let otherData = other as! NSData
			return self.isEqualToData(otherData)
		} else {
			return false
		}
	}
}

extension NSSet: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is NSSet {
			let otherSet = other as! NSSet
			let isEqual = self.isEqualToSet(otherSet as! Set<NSObject>)
			
			return isEqual
		} else {
			return false
		}
	}
}

//extension Match: Payload {
//	func equalToOther(other: Payload) -> Bool {
//		if other.self is Match.Type {
//			return (other as! NSManagedObject) == self
//		} else {
//			return false
//		}
//	}
//}

extension NSManagedObject: Payload {
	func equalToOther(other: Payload) -> Bool {
		if other.self is NSManagedObject {
			let otherObject = other as! NSManagedObject
			if otherObject == self {
				return true
			} else {
				if self is TeamMatchPerformance && otherObject is TeamMatchPerformance {
					let selfPerformance = self as! TeamMatchPerformance
					let otherPerformance = otherObject as! TeamMatchPerformance
					
					if selfPerformance.timeMarkers?.count == otherPerformance.timeMarkers?.count {
						return true
					} else {
						return false
					}
				} else {
					return false
				}
			}
		} else {
			return false
		}
	}
}

protocol ConflictManager {
	func conflictManager(resolveConflicts conflicts: [MergeManager.Conflict], completionHandler: [MergeManager.Conflict] -> Void)
}