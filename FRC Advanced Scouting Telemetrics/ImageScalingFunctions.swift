//
//  ImageScalingFunctions.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreGraphics

struct ImageConstants {
	static let offenseImageStoredSize = CGSize(width: 454, height: 698)
	static let defenseImageStoredSize = CGSize(width: 471, height: 728)
}

func translatePointCoordinateToStoredCordinate(_ point: CGPoint, viewSize: CGSize, storedSize: CGSize) -> CGPoint {
	return translatePoint(point, fromSize: viewSize, toSize: storedSize)
}

func translateStoredCoordinateToPoint(_ storedCoordinate: CGPoint, storedSize: CGSize, viewSize: CGSize) -> CGPoint {
	return translatePoint(storedCoordinate, fromSize: storedSize, toSize: viewSize)
}

func translatePoint(_ point: CGPoint, fromSize oldSize: CGSize, toSize newSize: CGSize) -> CGPoint {
	let xRatio = point.x/oldSize.width
	let newX = xRatio * newSize.width
	
	let yRatio = point.y/oldSize.height
	let newY = yRatio * newSize.height
	
	return CGPoint(x: newX, y: newY)
}
