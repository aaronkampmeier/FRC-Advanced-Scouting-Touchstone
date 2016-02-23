//
//  Stopwatch.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/21/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

class Stopwatch {
	private var startTime: NSDate?
	
	var elapsedTime: NSTimeInterval {
		if let start = startTime {
			return -start.timeIntervalSinceNow
		} else {
			return 0
		}
	}
	
	var elapsedTimeAsString: String {
		return String(format: "%02d:%02d.%d", Int(elapsedTime / 60), Int(elapsedTime % 60), Int(elapsedTime * 10 % 10))
	}
	
	var isRunning: Bool {
		return startTime != nil
	}
	
	func start() {
		startTime = NSDate()
	}
	
	func stop() {
		startTime = nil
	}
}