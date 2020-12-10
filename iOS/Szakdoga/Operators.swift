//
//  Operators.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 10. 15..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import Foundation
import Accelerate

struct O {
    static func lnArray(with x: [Double]) -> [Double] {
        var y = [Double](repeating: 0.0, count: x.count)
        var N = Int32(x.count)
        vvlog(&y, x, &N)
        return y
    }
    
    static func powArray(with array: [Double], power: Double) -> [Double] {
        return array.map({(element: Double) in return self.accuratePow(element, power)})
    }
    
    static func multiplyArrays(_ array1: [Double], _ array2: [Double]) -> [Double] {
        return zip(array1, array2).map{ $0 * $1 }
    }
    
    static func getMean(from x: [Double]) -> Double {
        var value:Double = 0.0
        vDSP_meanvD(x, 1, &value, vDSP_Length(x.count))
        return value
    }
    
    static func accuratePow(_ x: Double, _ power: Double) -> Double {
        var y = [0.0]
        let powers = [power]
        var N = Int32(1)
        vvpow(&y, [x], powers, &N)
        return y[0]
    }
}
