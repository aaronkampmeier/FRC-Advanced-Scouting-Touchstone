//
//  ArrayExtension.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

extension Array {
	subscript (safe index: Int) -> Element? {
		return indices.contains(index) ? self[index]: nil
	}
}