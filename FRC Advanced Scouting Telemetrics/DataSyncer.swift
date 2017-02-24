//
//  DataSyncer.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 4/2/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Ensembles
import Crashlytics

let CDEMultipeerCloudFileSystemDidImportFilesNotification = "CDEMultipeerCloudFileSystemDidImportFilesNotification"
let DSTransferNumberChanged = "DSTransferNumberChanged"

class DataSyncer: NSObject, CDEPersistentStoreEnsembleDelegate {
	fileprivate static var sharedInstance: DataSyncer = DataSyncer()
    
	static func sharedDataSyncer() -> DataSyncer {
		return sharedInstance
	}
    
	let fileSystem: CDECloudFileSystem
	let ensemble: CDEPersistentStoreEnsemble
	let multipeerConnection: MultipeerConnection
	
	override init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		let syncSecret: String
		if let stringValue = UserDefaults.standard.string(forKey: "SharedSyncSecret") {
			syncSecret = stringValue
		} else {
			NSLog("No sync secret exists, using default.")
			syncSecret = "FRC-4256-FAST-EnsembleSync"
		}
		
		multipeerConnection = MultipeerConnection(syncSecret: syncSecret)
		let rootDir = appDelegate.applicationDocumentsDirectory.appendingPathComponent("EnsembleMultipeerSyncV2", isDirectory: true).path
		
		fileSystem = CDEMultipeerCloudFileSystem(rootDirectory: rootDir, multipeerConnection: multipeerConnection)
		multipeerConnection.fileSystem = (fileSystem as! CDEMultipeerCloudFileSystem)
		ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "FASTStore", persistentStore: appDelegate.localPersistentStoreURL, managedObjectModelURL: appDelegate.managedObjectModelURL, cloudFileSystem: fileSystem)
		
		super.init()
		
		ensemble.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(DataSyncer.didImportFiles), name: NSNotification.Name(rawValue: CDEMultipeerCloudFileSystemDidImportFilesNotification), object: nil)
		NotificationCenter.default.addObserver(forName: NSNotification.Name.CDEMonitoredManagedObjectContextDidSave, object: nil, queue: nil) {notification in
			self.syncWithCompletion() {error in
				if let error = error {NSLog("Commit-Sync failed with error: \(error)")} else {NSLog("Commit-Sync completed")}
			}
		}
		Timer.scheduledTimer(timeInterval: 5 * 60, target: self, selector: #selector(DataSyncer.autoSync(_:)), userInfo: nil, repeats: true)
	}
	
	///Attaches local ensemble object to the cloud (shared data store).
	static func begin() {
		NSLog("Starting Data Syncer")
		//Leech the ensemble if it hasn't already been done
		if !sharedDataSyncer().ensemble.isLeeched {
			NSLog("Leeching ensemble")
			sharedDataSyncer().ensemble.leechPersistentStore() {error in
				if let error = error {
					NSLog("Unable to leech the persistent store. Error: \(error)")
				} else {
					NSLog("Leech successful")
				}
			}
		} else {
			NSLog("Already leeched")
		}
	}
	
	func disconnectFromCloud() {
		NSLog("Disconnecting")
		ensemble.deleechPersistentStore() {error in
			if let error = error {NSLog("Deleech failed with error: \(error)")} else {NSLog("Deleech Successful")}
		}
	}
	
	@objc private func didImportFiles() {
		//syncWithCompletion(nil)
		NSLog("Did import files")
		multipeerConnection.syncFilesWithAllPeers()
	}
	
	@objc private func autoSync(_ timer: Timer) {
		if !connectedPeers().isEmpty {
			syncWithCompletion() {error in
				if let error = error {NSLog("Auto-Sync failed with error: \(error)")} else {NSLog("Auto-Sync completed")}
			}
		}
	}
	
	///Begins an Ensemble merge. Retrieves files from the other devices and merges them with this one.
	func syncWithCompletion(_ completion: CDECompletionBlock?) {
		NSLog("Syncing Files")
		self.multipeerConnection.syncFilesWithAllPeers()
		
		//Wait one second before syncing to allow for remote files to download
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			NSLog("Merging")
			self.ensemble.merge() {error in
				if let error = error {NSLog("Error merging: \(error)")} else {NSLog("Merging completed")}
				completion?(error)
			}
		}
	}
	
	func connectedPeers() -> [MCPeerID] {
		return multipeerConnection.session.connectedPeers
	}
	
	func attemptToFixDeelechError() {
		DataSyncer.begin()
	}
	
	//MARK: Ensemble Delegate
	func persistentStoreEnsembleWillImportStore(_ ensemble: CDEPersistentStoreEnsemble!) {
		NSLog("Ensemble will import store")
	}
	
	func persistentStoreEnsembleDidImportStore(_ ensemble: CDEPersistentStoreEnsemble!) {
		NSLog("Ensemble did import store")
	}
	
	func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, shouldSaveMergedChangesIn savingContext: NSManagedObjectContext!, reparationManagedObjectContext reparationContext: NSManagedObjectContext!) -> Bool {
		NSLog("Ensemble should save merged changes")
		return true
	}
	
	func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, didFailToSaveMergedChangesIn savingContext: NSManagedObjectContext!, error: Error!, reparationManagedObjectContext reparationContext: NSManagedObjectContext!) -> Bool {
		CLSNSLogv("Ensemble did fail to save merged changes. Error: \(error)", getVaList([]))
		let alert = UIAlertController(title: "Save Failed", message: "The save and sync failed.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		(UIApplication.shared.delegate as! AppDelegate).presentViewControllerOnTop(alert, animated: true)
		
//		savingContext.performBlockAndWait() {
//			for object in savingContext.updatedObjects {
//				switch object {
//				case is Match:
//					var defenses = object.valueForKey("redDefenses")
//					do {
//						try object.validateValue(&defenses, forKey: "redDefenses")
//					} catch {
//						reparationContext.performBlockAndWait() {
//							reparationContext.objectWithID(object.objectID).setValue(nil, forKey: "redDefenses")
//						}
//					}
//				default:
//					break
//				}
//			}
//		}
		
		Crashlytics.sharedInstance().recordError(error)
		return false
	}
	
	func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, didSaveMergeChangesWith notification: Notification!) {
		NSLog("Ensemble did save merged changes")
		
		//Merge the changes into the main managed object context
		DataManager.managedContext.perform() {
			DataManager.managedContext.mergeChanges(fromContextDidSave: notification)
			NSLog("Did merge changes into main context")
			NotificationCenter.default.post(name: Notification.Name(rawValue: "DataSyncer:NewChangesMerged"), object: self)
		}
	}
	
	func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, didDeleechWithError error: Error!) {
		let alert = UIAlertController(title: "Sync Error: Deleech", message: "There was an internal data integrity error which forced your app to disconnect from the shared cloud of data.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Attempt to Fix", style: .default, handler: {_ in self.attemptToFixDeelechError()}))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		(UIApplication.shared.delegate as! AppDelegate).presentViewControllerOnTop(alert, animated: true)
		
		CLSNSLogv("Did deleech with error: \(error)", getVaList([]))
		Crashlytics.sharedInstance().recordError(error)
	}
    
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [Any]!) -> [Any]! {
        NSLog("Setting global identifiers")
        var globalIdentifiers = [Any]()
        for anyObject in objects {
            switch anyObject {
            case is LocalTeamRanking:
                globalIdentifiers.append("LocalTeamRanking" as NSString)
                
            //Universals
            case is Team:
                let object = anyObject as! Team
                globalIdentifiers.append(NSString(string: "Universal:\(object.key!)"))
            case is Event:
                let object = anyObject as! Event
                globalIdentifiers.append(NSString(string: "Universal:\(object.key!)"))
            case is TeamEventPerformance:
                let object = anyObject as! TeamEventPerformance
                globalIdentifiers.append(NSString(string: "EventPerformance:\(object.team.value(forKey: "key")!):\((object.event).value(forKey: "key")!)"))
            case is Match:
                let object = anyObject as! Match
                globalIdentifiers.append(NSString(string: "Universal:\(object.key!)"))
            case is TeamMatchPerformance:
                let object = anyObject as! TeamMatchPerformance
                globalIdentifiers.append(NSString(string: "Universal:\(object.key!)"))
                
            //Locals
            case is LocalTeam:
                let object = anyObject as! LocalTeam
                globalIdentifiers.append(NSString(string: "Local:\(object.key!)"))
            case is LocalEvent:
                let object = anyObject as! LocalEvent
                globalIdentifiers.append(NSString(string: "Local:\(object.key!)"))
            case is LocalMatchPerformance:
                let object = anyObject as! LocalMatchPerformance
                globalIdentifiers.append(NSString(string: "Local:\(object.key!)"))
            case is LocalMatch:
                let object = anyObject as! LocalMatch
                globalIdentifiers.append(NSString(string: "Local:\(object.key!)"))
            case is Defending:
                globalIdentifiers.append(UUID().uuidString)
            case is FuelLoading:
                globalIdentifiers.append(UUID().uuidString)
            case is FuelScoring:
                globalIdentifiers.append(UUID().uuidString)
            case is GearLoading:
                globalIdentifiers.append(UUID().uuidString)
            case is GearMounting:
                globalIdentifiers.append(UUID().uuidString)
            case is TimeMarker:
                globalIdentifiers.append(UUID().uuidString)
            default:
                globalIdentifiers.append(NSNull())
            }
        }
        return globalIdentifiers
    }
}

//For other files to access MCPeerIDs without importing MultipeerConnectivity
typealias FASTPeer = MCPeerID

class MultipeerConnection: NSObject, CDEMultipeerConnection {
	let serviceType = "frc-4256-fast"
	let mySyncSecret: String
	
	let myPeerID = MCPeerID(displayName: UIDevice.current.name)
	
	fileprivate let serviceAdvertiser: MCNearbyServiceAdvertiser
	fileprivate let serviceBrowser: MCNearbyServiceBrowser
	
	let session: MCSession
	
	var currentFileTransfers = [String:(Progress, FASTPeer)]() {
		didSet {
			let oldKeys = Set(oldValue.keys)
			let newKeys = Set(currentFileTransfers.keys)
			let updatedKeys = oldKeys.symmetricDifference(newKeys)
			NotificationCenter.default.post(name: Notification.Name(rawValue: DSTransferNumberChanged), object: self, userInfo: ["UpdatedKeys":Array(updatedKeys)])
		}
	}
	
	weak var fileSystem: CDEMultipeerCloudFileSystem?
	
	init(syncSecret: String) {
		mySyncSecret = syncSecret
		session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["syncSecret":mySyncSecret], serviceType: serviceType)
		serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
		
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
	
	func send(_ data: Data!, toPeerWithID peerID: NSCoding & NSCopying & NSObjectProtocol) -> Bool {
		let peer = peerID as! MCPeerID
		do {
			try session.send(data, toPeers: [peer], with: .reliable)
			return true
		} catch {
			return false
		}
	}
	
	func sendAndDiscardFile(at url: URL!, toPeerWithID peerID: NSCoding & NSCopying & NSObjectProtocol) -> Bool {
		NSLog("Sending file")
		let peer = peerID as! MCPeerID
		let progress = session.sendResource(at: url, withName: url.lastPathComponent, toPeer: peer) {sendError in
			if let error = sendError {
				NSLog("Unable to send file. Error: \(error)")
			}
			
			do {
				try FileManager.default.removeItem(at: url)
			} catch {
				NSLog("Unable to delete tmp file. Error: \(error)")
			}
		}
		
		return progress != nil
	}
	
	func syncFilesWithAllPeers() {
		if session.connectedPeers.count > 0 {
			fileSystem?.retrieveFilesFromPeers(withIDs: session.connectedPeers)
		}
	}
}

//MARK: Advertiser Delegate
/** Advertiser Delegate */
extension MultipeerConnection: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("Did not start advertising peer: \(error)")
	}
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("Did receive invitation from peer: \(peerID); \(peerID.displayName)")
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name(rawValue: "DataSyncing:ReceivedInvitation"), object: self, userInfo: ["peer":peerID.displayName, "context": context])
		}
		
		if let context = context {
			let otherPeerSecret = String(NSString(data: context, encoding: String.Encoding.utf8.rawValue) ?? "")
			if otherPeerSecret == mySyncSecret {
				NSLog("Accepting invite from \(peerID.displayName).")
				invitationHandler(true, session)
			} else {
				NSLog("Rejecting invite from \(peerID.displayName), because it has a different sync secret.")
				invitationHandler(false, session)
			}
		} else {
			invitationHandler(false, session)
		}
	}
}

//MARK: Browser Delegate
/** Browser Delegate */
extension MultipeerConnection: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("Didn't start browsing: \(error)")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("Found peer: \(peerID.displayName)")
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name(rawValue: "DataSyncing:FoundPeer"), object: self, userInfo: ["peer":peerID.displayName, "info":info ?? [:]])
		}
		
		if !peerID.isEqual(self.myPeerID) && !session.connectedPeers.contains(peerID) {
			//The peer is not me and is not yet connected, check if it has the same sync secret as me
			if info?["syncSecret"] == mySyncSecret {
				//Invite them
				let context = mySyncSecret.data(using: String.Encoding.utf8)
				browser.invitePeer(peerID, to: session, withContext: context, timeout: 30)
			}
		}
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("Lost Peer: \(peerID.displayName)")
	}
}

//MARK: Session Delegate
/** Session Delegate */
extension MultipeerConnection: MCSessionDelegate {
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		CLSNSLogv("Received Data", getVaList([]))
		fileSystem?.receive(data, fromPeerWithID: peerID)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		CLSNSLogv("Peer: \(peerID.displayName), Did change state: \(state)", getVaList([]))
		
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name(rawValue: "DataSyncing:DidChangeState"), object: self, userInfo: ["peer":peerID as FASTPeer, "state":state.rawValue])
		}
		
		if state == .connected {
			DispatchQueue.main.async {
				DataSyncer.sharedDataSyncer().syncWithCompletion(nil)
			}
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("Received Stream")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
		CLSNSLogv("Did finish receiving resource: \(resourceName)", getVaList([]))
		currentFileTransfers.removeValue(forKey: resourceName)
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name(rawValue: "DataSyncing:DidFinishReceiving"), object: self, userInfo: ["peer": peerID.displayName, "url":localURL, "name":resourceName])
		}
		
		if error != nil {
			CLSNSLogv("Error receiving file: \(error)", getVaList([]))
			return
		} else {
			fileSystem?.receiveResource(at: localURL, fromPeerWithID: peerID)
		}
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		CLSNSLogv("Did start receiving resource: \(resourceName)", getVaList([]))
		currentFileTransfers[resourceName] = (progress, peerID)
	}
}

extension MCSessionState: CustomStringConvertible {
	func stringValue() -> String {
		switch self {
		case .notConnected:
			return "Not Connected"
		case .connecting:
			return "Connecting"
		case .connected:
			return "Connected"
		}
	}
	
	public var description: String {
		return self.stringValue()
	}
}

///For other classes to use instead of importing MultipeerConnectivity and using MCSessionState
typealias SessionState = MCSessionState
