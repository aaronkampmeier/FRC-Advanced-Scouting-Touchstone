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
        
        realmController.generalRealm.beginWrite()
        realmController.syncedRealm.beginWrite()
        
        let eventKey = eventToReload.key
        realmController.delete(object: eventToReload)
        cloudConnection.event(forKey: eventKey, withCompletionHandler: reloadEvent)
    }
    
    private func reloadEvent(frcEvent: FRCEvent?) {
        if let frcEvent = frcEvent {
            CLSNSLogv("Beginning event reload", getVaList([]))
            CloudEventImportManager(shouldPreload: false, shouldEnterWrite: false, forEvent: frcEvent) {(successful, importError) in
                if let importError = importError {
                    RealmController.realmController.syncedRealm.cancelWrite()
                    RealmController.realmController.generalRealm.cancelWrite()
                    
                    self.completionHandler(false)
                    
                    CLSNSLogv("Cancelled reloading writes because of error: \(importError)", getVaList([]))
                } else {
                    do {
                        try RealmController.realmController.syncedRealm.commitWrite()
                        try RealmController.realmController.generalRealm.commitWrite()
                        
                        self.completionHandler(successful)
                        
                        CLSNSLogv("Finished re-imported (reloaded) cloud event: \(frcEvent.key), withError: \(String(describing: importError))", getVaList([]))
                    } catch {
                        CLSNSLogv("Failed to commit reloading writes with error: \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                        self.completionHandler(false)
                    }
                }
                
            }
                .import()
        } else {
            //Did not return an frc event
            RealmController.realmController.syncedRealm.cancelWrite()
            RealmController.realmController.generalRealm.cancelWrite()
            
            self.completionHandler(false)
        }
    }
}
