//: Playground - noun: a place where people can play

import UIKit
import YCMatrix


let matrixA = Matrix(fromColumns: [[3,6,2,3]])
let matrixB = Matrix(from: [1,2,3,4,5,6,7,8,9,10], rows: 2, columns: 5)
let matrixC = Matrix(from: [3,4,5,1,2,6,7,8,9,0], rows: 2, columns: 5)

print(matrixB?.isEqual(to: matrixB, tolerance: 0))

print(matrixB?.isEqual(to: matrixC, tolerance: 9))

print(matrixB)

print(matrixB?.i(1, j: 1))
