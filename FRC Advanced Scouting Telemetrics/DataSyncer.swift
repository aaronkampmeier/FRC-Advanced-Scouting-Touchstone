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

let CDEMultipeerCloudFileSystemDidImportFilesNotification = "CDEMultipeerCloudFileSystemDidImportFilesNotification"

class DataSyncer: NSObject, CDEPersistentStoreEnsembleDelegate {
	private static var sharedInstance: DataSyncer = DataSyncer()
	
	let fileSystem: CDECloudFileSystem
	let ensemble: CDEPersistentStoreEnsemble
	let multipeerConnection: MultipeerConnection
	
	override init() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		let syncSecret: String
		if let stringValue = NSUserDefaults.standardUserDefaults().stringForKey("SharedSyncSecret") {
			syncSecret = stringValue
		} else {
			NSLog("No sync secret exists, using default.")
			syncSecret = "FRC-4256-FAST-EnsembleSync"
		}
		
		multipeerConnection = MultipeerConnection(syncSecret: syncSecret)
		let rootDir = appDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("EnsembleMultipeerSync", isDirectory: true).path
		
		fileSystem = CDEMultipeerCloudFileSystem(rootDirectory: rootDir, multipeerConnection: multipeerConnection)
		multipeerConnection.fileSystem = (fileSystem as! CDEMultipeerCloudFileSystem)
		ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "MainStore", persistentStoreURL: appDelegate.coreDataURL, managedObjectModelURL: appDelegate.managedObjectModelURL, cloudFileSystem: fileSystem)
		
		super.init()
		
		ensemble.delegate = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataSyncer.didImportFiles), name: CDEMultipeerCloudFileSystemDidImportFilesNotification, object: nil)
	}
	
	static func sharedDataSyncer() -> DataSyncer {
		return sharedInstance
	}
	
	///Attaches local ensemble object to the cloud (shared data store).
	static func begin() {
		NSLog("Starting Data Syncer")
		//Leech the ensemble if it hasn't already been done
		if !sharedDataSyncer().ensemble.leeched {
			NSLog("Leeching ensemble")
			sharedDataSyncer().ensemble.leechPersistentStoreWithCompletion() {error in
				if let error = error {
					NSLog("Unable to leech the persistent store. Error: \(error)")
				} else {
					NSLog("Leech successful")
				}
			}
		}
	}
	
	func didImportFiles() {
		//syncWithCompletion(nil)
		NSLog("Did import files")
	}
	
	///Begins an Ensemble merge. Retrieves files from the other devices and merges them with this one.
	func syncWithCompletion(completion: CDECompletionBlock?) {
		NSLog("Merging")
		ensemble.mergeWithCompletion() {error in
			self.multipeerConnection.syncFilesWithAllPeers()
			if let error = error {NSLog("Error merging: \(error)")} else {NSLog("Merging completed")}
			completion?(error)
		}
	}
	
	func connectedPeers() -> [MCPeerID] {
		return multipeerConnection.session.connectedPeers
	}
	
	//MARK: Ensemble Delegate
	func persistentStoreEnsembleWillImportStore(ensemble: CDEPersistentStoreEnsemble!) {
		NSLog("Ensemble will import store")
	}
	
	func persistentStoreEnsembleDidImportStore(ensemble: CDEPersistentStoreEnsemble!) {
		NSLog("Ensemble did import store")
	}
	
	func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, shouldSaveMergedChangesInManagedObjectContext savingContext: NSManagedObjectContext!, reparationManagedObjectContext reparationContext: NSManagedObjectContext!) -> Bool {
		NSLog("Ensemble should save merged changes")
		return true
	}
	
	func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, didFailToSaveMergedChangesInManagedObjectContext savingContext: NSManagedObjectContext!, error: NSError!, reparationManagedObjectContext reparationContext: NSManagedObjectContext!) -> Bool {
		NSLog("Ensemble did fail to save merged changes. Error: \(error)")
		return false
	}
	
	func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, didSaveMergeChangesWithNotification notification: NSNotification!) {
		NSLog("Ensemble did save merged changes")
		
		//Merge the changes into the main managed object context
		TeamDataManager.managedContext.performBlock() {
			TeamDataManager.managedContext.mergeChangesFromContextDidSaveNotification(notification)
			NSLog("Did merge changes into main context")
		}
	}
	
	func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, didDeleechWithError error: NSError!) {
		NSLog("Did deleech with error: \(error ?? nil)")
	}
	
//	func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [AnyObject]!) -> [AnyObject]! {
//
//	}
}

///For other files to access MCPeerIDs without importing MultipeerConnectivity
typealias FASTPeer = MCPeerID

class MultipeerConnection: NSObject, CDEMultipeerConnection {
	let serviceType = "frc-4256-fast"
	let mySyncSecret: String
	
	private let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	
	private let serviceBrowser: MCNearbyServiceBrowser
	
	let session: MCSession
	
	weak var fileSystem: CDEMultipeerCloudFileSystem?
	
	init(syncSecret: String) {
		mySyncSecret = syncSecret
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["syncSecret":mySyncSecret], serviceType: serviceType)
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
	
	func sendData(data: NSData!, toPeerWithID peerID: protocol<NSCoding, NSCopying, NSObjectProtocol>!) -> Bool {
		let peer = peerID as! MCPeerID
		do {
			try session.sendData(data, toPeers: [peer], withMode: .Reliable)
			return true
		} catch {
			return false
		}
	}
	
	func sendAndDiscardFileAtURL(url: NSURL!, toPeerWithID peerID: protocol<NSCoding, NSCopying, NSObjectProtocol>!) -> Bool {
		NSLog("Sending file")
		let peer = peerID as! MCPeerID
		let progress = session.sendResourceAtURL(url, withName: url.lastPathComponent!, toPeer: peer) {sendError in
			if let error = sendError {
				NSLog("Unable to send file. Error: \(error)")
			}
			
			do {
				try NSFileManager.defaultManager().removeItemAtURL(url)
			} catch {
				NSLog("Unable to delete tmp file. Error: \(error)")
			}
		}
		
		return progress != nil
	}
	
	func syncFilesWithAllPeers() {
		if session.connectedPeers.count > 0 {
			fileSystem?.retrieveFilesFromPeersWithIDs(session.connectedPeers)
		}
	}
}

//MARK: Advertiser Delegate
/** Advertiser Delegate */
extension MultipeerConnection: MCNearbyServiceAdvertiserDelegate {
	func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
		NSLog("Did not start advertising peer: \(error)")
	}
	
	func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
		NSLog("Did receive invitation from peer: \(peerID); \(peerID.displayName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:ReceivedInvitation", object: self, userInfo: ["peer":peerID.displayName, "context":context ?? "none"])
		}
		
		if let context = context {
			let otherPeerSecret = String(NSString(data: context, encoding: NSUTF8StringEncoding) ?? "")
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
	func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
		NSLog("Didn't start browsing: \(error)")
	}
	
	func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("Found peer: \(peerID.displayName)")
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:FoundPeer", object: self, userInfo: ["peer":peerID.displayName, "info":info ?? [:]])
		}
		
		if !peerID.isEqual(myPeerID) && !session.connectedPeers.contains(peerID) {
			//The peer is not me and is not yet connected, check if it has the same sync secret as me
			if info?["syncSecret"] == mySyncSecret {
				//Invite them
				let context = mySyncSecret.dataUsingEncoding(NSUTF8StringEncoding)
				browser.invitePeer(peerID, toSession: session, withContext: context, timeout: 30)
			}
		}
	}
	
	func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("Lost Peer: \(peerID.displayName)")
	}
}

//MARK: Session Delegate
/** Session Delegate */
extension MultipeerConnection: MCSessionDelegate {
	func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
		NSLog("Received Data")
		fileSystem?.receiveData(data, fromPeerWithID: peerID)
	}
	
	func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
		NSLog("Peer: \(peerID.displayName), Did change state: \(state.stringValue())")
		
		dispatch_async(dispatch_get_main_queue()) {
			NSNotificationCenter.defaultCenter().postNotificationName("DataSyncing:DidChangeState", object: self, userInfo: ["peer":peerID as FASTPeer, "state":state.rawValue])
		}
		
		if state == .Connected {
			dispatch_async(dispatch_get_main_queue()) {
				self.syncFilesWithAllPeers()
			}
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
		
		if error != nil {
			NSLog("Error receiving file: \(error)")
			return
		} else {
			fileSystem?.receiveResourceAtURL(localURL, fromPeerWithID: peerID)
		}
	}
	
	func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
		NSLog("Did start receiving resource: \(resourceName)")
	}
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

///For other classes to use instead of importing MultipeerConnectivity and using MCSessionState
typealias SessionState = MCSessionState