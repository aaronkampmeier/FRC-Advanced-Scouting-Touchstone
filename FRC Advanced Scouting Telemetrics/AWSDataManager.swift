//
//  AWSDataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/19/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import AWSMobileClient
import AWSAppSync
import AWSS3

class AWSDataManager {
    
    
    func signOut() {
        AWSMobileClient.sharedInstance().signOut()
        
        //Show the onboarding
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        Globals.appDelegate.window?.rootViewController = vc
    }
}

class FASTAppSyncStateChangeHandler: ConnectionStateChangeHandler {
    func stateChanged(networkState: ClientNetworkAccessState) {
        CLSNSLogv("App Sync Connection State Changed: \(networkState)", getVaList([]))
    }
}
