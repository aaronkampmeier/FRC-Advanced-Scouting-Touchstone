//
//  OfflineSupport.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/14/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import AWSAppSync
import Network

class FASTAppSyncStateChangeHandler: ConnectionStateChangeHandler {
	func stateChanged(networkState: ClientNetworkAccessState) {
		CLSNSLogv("App Sync Connection State Changed: \(networkState)", getVaList([]))
	}
}

class FASTOfflineMutationDelegate: AWSAppSyncOfflineMutationDelegate {
	func mutationCallback(recordIdentifier: String, operationString: String, snapshot: Snapshot?, error: Error?) {
		if let error = error {
			CLSNSLogv("Offline mutation of %@ failed with error: \(error)", getVaList([recordIdentifier]))
			Crashlytics.sharedInstance().recordError(error)
		} else {
			CLSNSLogv("Performed offline mutation %@", getVaList([recordIdentifier]))
		}
	}
}

@available(iOS 12.0, *)
class FASTNetworkManager {
	static let main = FASTNetworkManager()
	let monitor = NWPathMonitor()
	let queue = DispatchQueue.global(qos: .background)
	
	//Key is the cancellable id
	var watchers = [String:(Bool) -> Void]()
	var reconnectUpdates = [() -> Void]()
	
	init() {
		monitor.pathUpdateHandler = {[weak self] path in
			if path.status == .satisfied {
				CLSNSLogv("Network connection state is online", getVaList([]))
				self?.reconnectUpdates.forEach({$0()})
				self?.reconnectUpdates.removeAll()
				
				self?.watchers.forEach({$0.value(true)})
			} else {
				CLSNSLogv("Network connection state is offline", getVaList([]))
				self?.watchers.forEach({$0.value(false)})
			}
		}
		
		monitor.start(queue: queue)
	}
	
	deinit {
		monitor.cancel()
	}
	
	func isOnline() -> Bool {
		switch monitor.currentPath.status {
		case .satisfied:
			return true
		case .requiresConnection:
			return false
		case .unsatisfied:
			return false
		}
	}
	
	func register(updateHandler: @escaping (Bool) -> Void) -> FASTCancellable {
		let id = UUID().uuidString
		watchers[id] = updateHandler
		return FASTCancellable(id: id, cancelHandler: {[weak self] (id) in
			self?.watchers.removeValue(forKey: id)
		})
	}
	
	func registerUpdateOnReconnect(update: @escaping () -> Void) {
		if monitor.currentPath.status == .satisfied {
			update()
		} else {
			reconnectUpdates.append(update)
		}
	}
}

class FASTCancellable {
	private let id: String
	private let cancelHandler: (String) -> Void
	
	init(id: String, cancelHandler: @escaping (String) -> Void) {
		self.id = id
		self.cancelHandler = cancelHandler
	}
	
	func cancel() {
		cancelHandler(id)
	}
}
