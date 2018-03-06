//
//  CloudReloadingManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics

typealias CloudReloadingCompletionHandler = (Bool) -> Void

class CloudReloadingManager {
    let eventToReload: Event
    
    let completionHandler: CloudReloadingCompletionHandler
    let cloudConnection = CloudData()
    let realmController = RealmController.realmController
    
    init(eventToReload: Event, completionHandler: @escaping CloudReloadingCompletionHandler) {
        self.eventToReload = eventToReload
        self.completionHandler = completionHandler
    }
    
    func reload() {
        //To reload, it removes the event and then calls a CloudImportManager to re-import it
        cloudConnection.event(forKey: eventToReload.key, withCompletionHandler: reloadEvent)
        realmController.delete(object: eventToReload)
    }
    
    private func reloadEvent(frcEvent: FRCEvent?) {
        if let frcEvent = frcEvent {
            CLSNSLogv("Beginning event reload", getVaList([]))
            CloudEventImportManager(shouldPreload: false, forEvent: frcEvent) {(successful, importError) in
                self.completionHandler(successful)
                
                CLSNSLogv("Finished re-imported (reloaded) cloud event: \(frcEvent.key), withError: \(String(describing: importError))", getVaList([]))
            }
                .import()
        }
    }
}
