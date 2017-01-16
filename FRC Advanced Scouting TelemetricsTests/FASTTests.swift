//
//  FASTTests.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/2/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import XCTest
//@testable import FRC_Advanced_Scouting_Touchstone
import YCMatrix

class FASTTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.measure {
            let matrixA = Matrix(from: [3,0,0,0,-1,1,0,0,3,-2,-1,0,1,-2,6,2], rows: 4, columns: 4)
            let matrixB = Matrix(from: [5,6,4,2], rows: 4, columns: 1)
            let matrixX = forwardSubstitute(matrixA: matrixA, matrixB: matrixB)
            
            print(matrixX!)
            let correctMatrixX = Matrix(from: [5/3,23/3,-43/3,305/6], rows: 4, columns: 1)
            XCTAssert((matrixX?.isEqual(to: correctMatrixX, tolerance: 1))!)
        }
        do {
            let matrixA = Matrix(from: [4,-1,2,3,0,-2,7,-4,0,0,6,5,0,0,0,3], rows: 4, columns: 4)
            let matrixB = Matrix(from: [20,-7,4,6], rows: 4, columns: 1)
            let matrixX = backwardSubstitute(matrixA: matrixA, matrixB: matrixB)
            
            print(matrixX!)
            let correctMatrixX = Matrix(from: [3,-4,-1,2], rows: 4, columns: 1)
            XCTAssert((matrixX?.isEqual(to: correctMatrixX, tolerance: 1))!)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

func forwardSubstitute(matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    for i in 0..<matrixA.rows {
        let sigmaValue = sigma(initialIncrementerValue: 0, topIncrementValue: Int(i)-1, function: {matrixA.i(i, j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let bValue = matrixB.i(i, j: 0)
        let xValueAtI = (bValue - sigmaValue) / matrixA.i(i, j: i)
        
        matrixX?.setValue(xValueAtI, row: i, column: 0)
    }
    
    return matrixX
}

func backwardSubstitute(matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    let backwardsArray = (Int(matrixA.rows)-1) ..= 0
    
    for i in backwardsArray {
        let sigmaValue = sigma(initialIncrementerValue: Int(i) + 1, topIncrementValue: Int(matrixA.rows) - 1, function: {matrixA.i(Int32(i), j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let xValueAtI = (matrixB.i(Int32(i), j: 0) - sigmaValue) / matrixA.i(Int32(i), j: Int32(i))
        matrixX?.setValue(xValueAtI, row: Int32(i), column: 0)
    }
    
    return matrixX
}

//An operator that takes an upper bound and a lower bound and returns an array with all the values from the upper bound to the lower bound. It's the inverse of ... operator
infix operator ..=
func ..=(lhs: Int, rhs: Int) -> [Int] {
    if lhs == rhs {
        return [rhs]
    } else {
        return [lhs] + ((lhs-1)..=rhs)
    }
}

func sigma(initialIncrementerValue: Int, topIncrementValue: Int, function: (Int) -> Double) -> Double {
    if initialIncrementerValue == topIncrementValue {
        return function(initialIncrementerValue)
    } else if initialIncrementerValue > topIncrementValue {
        return 0
    } else {
        return function(initialIncrementerValue) + sigma(initialIncrementerValue: initialIncrementerValue + 1, topIncrementValue: topIncrementValue, function: function)
    }
}
