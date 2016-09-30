//
//  conversion.swift
//  swix
//
//  Created by Scott Sievert on 7/11/14.
//  Copyright (c) 2014 com.scott. All rights reserved.
//

import Foundation
import Accelerate

func matrixToPointer(_ x: ndarray)->UnsafeMutablePointer<Double>{
    // sustains since objc rewrites raw memory!
    return UnsafeMutablePointer<Double>(mutating: x.grid)
}
func matrixToPointer(_ x: [Int])->UnsafeMutablePointer<Int>{
    return UnsafeMutablePointer<Int>(mutating: x)
}

/// use !x to get the address. I tried &x but that doesn't work in beta3.
prefix func ! (x: ndarray) -> UnsafeMutablePointer<Double> {
    return matrixToPointer(x)
}
prefix func ! (x: matrix) -> UnsafeMutablePointer<Double> {
    return matrixToPointer(x.flat)
}

