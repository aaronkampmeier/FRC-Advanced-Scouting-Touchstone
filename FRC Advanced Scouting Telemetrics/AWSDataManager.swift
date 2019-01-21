//
//  AWSDataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/19/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import AWSMobileClient

class AWSDataManager {
    
    
    func signOut() {
        AWSMobileClient.sharedInstance().signOut()
        
        //Show the onboarding
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        Globals.appDelegate.window?.rootViewController = vc
    }
}
