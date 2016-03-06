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
			let foreignPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)//(UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
			let foreignPersistentStore = try foreignPersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sourceURL, options: options)
			let foreignObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			foreignObjectContext.persistentStoreCoordinator = foreignPersistentStoreCoordinator
			let localPersistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
			let localPersistentStore = localPersistentStoreCoordinator.persistentStores.first!
			let localManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
			
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
		do {
			try NSFileManager.defaultManager().removeItemAtURL(sourceURL)
		} catch {
			NSLog("Unable to delete the foreign database")
		}
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