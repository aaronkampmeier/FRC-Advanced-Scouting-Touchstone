//
//  Stopwatch.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/21/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

class Stopwatch {
	fileprivate var startTime: Date?
	fileprivate var furthestTime: TimeInterval = 0
	
	var elapsedTime: TimeInterval {
		if let start = startTime {
			return -start.timeIntervalSinceNow
		} else {
			return furthestTime
		}
	}
	
	var elapsedTimeAsString: String {
		return String(format: "%02d:%02d.%d", Int(elapsedTime / 60), Int(elapsedTime.truncatingRemainder(dividingBy: 60)), Int((elapsedTime * 10).truncatingRemainder(dividingBy: 10)))
	}
	
	var isRunning: Bool {
		return startTime != nil
	}
	
	func start() {
		startTime = Date()
        furthestTime = 0
	}
	
	func stop() {
		furthestTime = elapsedTime
		startTime = nil
	}
}
