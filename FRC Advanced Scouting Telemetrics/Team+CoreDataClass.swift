//
//  Team+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


public class Team: NSManagedObject {
    
    lazy var cachedLocal: LocalTeam = {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdatedTeams"), object: nil, queue: nil) {_ in self.cachedLocal = self.local()}
        return self.local()
    }()
}