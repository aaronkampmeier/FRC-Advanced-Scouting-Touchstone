//
//  ImageScalingFunctions.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreGraphics

func translatePointToRelativePoint(point: CGPoint, withCurrentSize currentSize: CGSize) -> CGPoint {
    let newX = point.x / currentSize.width
    let newY = point.y / currentSize.height
    
    return CGPoint(x: newX, y: newY)
}

func translateRelativePointToPoint(relativePoint: CGPoint, toSize newSize: CGSize) -> CGPoint {
    let newX = relativePoint.x * newSize.width
    let newY = relativePoint.y * newSize.height
    
    return CGPoint(x: newX, y: newY)
}

func translatePoint(point: CGPoint, fromSize oldSize: CGSize, toSize newSize: CGSize) -> CGPoint {
    return translateRelativePointToPoint(relativePoint: translatePointToRelativePoint(point: point, withCurrentSize: oldSize), toSize: newSize)
}
