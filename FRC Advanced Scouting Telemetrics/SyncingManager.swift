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
	
	private let serviceType = "frc-4256-scout"
	
	private let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	
	private let serviceBrowser: MCNearbyServiceBrowser
	
	let session: MCSession
	
	var delegate: SyncingManagerDelegate?
	
	override init() {
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
		serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
		session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .Required)
		
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
	
	func sync() -> NSProgress {
		return session.sendResourceAtURL((UIApplication.sharedApplication().delegate as! AppDelegate).coreDataURL, withName: "Database", toPeer: session.connectedPeers.first!, withCompletionHandler: nil)!
	}
}

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
		
		mergeDatabases(fromSourceURL: localURL)
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
		do {
			let teams = dataManager.getTeams()
			//Example COnflict data structuring
//			let mainConflictTitle = "Teams"
//			let conflicts = ["4256":["localDetail":"Weight: 400", "externalDetail":"Weight 350"]]
//			let selectionHandler: ([String:SyncSource]) -> Void
			
			var hasConflict = false
			var conflicts = [String:[String:[String:AnyObject]]]()
			for team in teams {
				//Find all teams with the same number
				let filteredTeams = teams.filter() {
					$0.teamNumber == team.teamNumber
				}
				
				//Check for data conflicts with the teams
				for team in filteredTeams {
					filteredTeams.forEach() {
						if !($0.driverExp!.isEqualToNumber(team.driverExp!) && $0.robotWeight!.isEqualToNumber(team.robotWeight!) && $0.frontImage!.isEqualToData(team.frontImage!) && $0.sideImage!.isEqualToData(team.sideImage!)) && $0.defensesAbleToCross!.isEqualToSet(team.defensesAbleToCross! as Set<NSObject>) {
							hasConflict = true
							conflicts.updateValue(["local":["localObject":filteredTeams[0],"localDetail":"Weight: \(filteredTeams[0].robotWeight)"], "external":["externalObject":filteredTeams[1],"externalDetail":"Weight: \(filteredTeams[1].robotWeight)"]], forKey: "\(team.teamNumber)")
						}
					}
				}
				
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
				
				//Combine the relationships of the teams and make a merged team
				let mergedTeam = filteredTeams.reduce(dataManager.saveTeamNumber(team.teamNumber!)) {(mergedTeam, team) in
					//Combine Regional Performances
					for performance in team.regionalPerformances?.allObjects as! [TeamRegionalPerformance] {
						performance.team = mergedTeam
					}
					
					//Combine defenses able to cross
					var defensesAbleToCross = mergedTeam.defensesAbleToCross?.mutableCopy() as! NSMutableSet
					for defense in team.defensesAbleToCross?.allObjects as! [Defense] {
						defensesAbleToCross.addObject(defense)
					}
					mergedTeam.defensesAbleToCross = (defensesAbleToCross.copy() as! NSSet)
					
					//Draft Board fixes itself upon next call of said function in TeamDataManager
					
					dataManager.deleteTeam(team)
					
					return mergedTeam
				}
				
				//Now merge the defensesAbleToCross in the mergedTeam, not the team performaces, because that will happen from the regional-based merging.
				var defensesAbleToCross = mergedTeam.defensesAbleToCross?.allObjects as! [Defense]
				for defense in defensesAbleToCross {
					var filteredDefenses = defensesAbleToCross.filter() {
						$0.defenseName == defense.defenseName
					}
					
					//Remove one to keep it
					filteredDefenses.removeFirst()
					for defense in filteredDefenses {
						defensesAbleToCross.removeAtIndex(defensesAbleToCross.indexOf(defense)!)
					}
				}
				
				mergedTeam.defensesAbleToCross = NSSet(array: defensesAbleToCross)
			}
		}
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

protocol SyncingManagerDelegate {
}