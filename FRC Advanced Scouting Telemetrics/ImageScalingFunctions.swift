//
//  ImageScalingFunctions.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreGraphics

//These functions are normally helpers for a shot chart image.

func translatePointToRelativePoint(_ point: CGPoint, withCurrentSize currentSize: CGSize) -> CGPoint {
    let newX = point.x / currentSize.width
    let newY = point.y / currentSize.height
    
    return CGPoint(x: newX, y: newY)
}

func translateRelativePointToPoint(_ relativePoint: CGPoint, toSize newSize: CGSize) -> CGPoint {
    let newX = relativePoint.x * newSize.width
    let newY = relativePoint.y * newSize.height
    
    return CGPoint(x: newX, y: newY)
}

func translatePoint(_ point: CGPoint, fromSize oldSize: CGSize, toSize newSize: CGSize) -> CGPoint {
    return translateRelativePointToPoint(translatePointToRelativePoint(point, withCurrentSize: oldSize), toSize: newSize)
}
