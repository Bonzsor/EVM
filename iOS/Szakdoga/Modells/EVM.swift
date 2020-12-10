//
//  EVM.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 10. 15..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import Foundation


class EVM {
    
    private let positives: [[Double]]
    private let negatives: [[Double]]
    private let coverThreshold: Double
    private var marginWeibulls: [WeibullParams] = []
    private var distances: [[Double]] = [[]]
    private var extremeVectors: [Int] = []
    private var distanceType: String
    
    init(positives: [[Double]], negatives: [[Double]], coverThreshold: Double = 0.7, distanceType: String) {
        self.positives = positives
        self.negatives = negatives
        self.coverThreshold = coverThreshold
        self.distanceType = distanceType
    }
    
    func train(printLog: Bool = false){
        self.distances = self.calculateDistanceMatrix(from: self.positives, and: self.negatives)
        self.marginWeibulls = self.fit()
        self.extremeVectors = self.reduce()
        if printLog {
            print("Margin weibulls: ", self.marginWeibulls)
            print("Extreme vector indecies: ", self.extremeVectors)
        }
    }
    
    private func fit() -> [WeibullParams] {
        var weibulls: [WeibullParams] = []
        for distanceVector in self.distances {
            weibulls.append(Weibull.fitHigh(array: distanceVector))
        }
        return weibulls
    }
    
    private func reduce() -> [Int] {
        let N = self.positives.count
        if N <= 1 {
            return [Int](0..<N)
        }
    
        var probabilities: [Set<Int>] = []
        for i in 0..<N {
            var indecies = Set<Int>()
            indecies.insert(i)
            for j in 0..<N {
                if self.calculatePsi(params: self.marginWeibulls[i], distance: self.calculateDistance(from: self.positives[i], to: self.positives[j])) >= self.coverThreshold {
                    indecies.insert(j)
                }
            }
            probabilities.append(indecies)
        }
        
        var evs: [Int] = []
        let universe = Set(0..<N)
        var covered = Set<Int>()
        while covered != universe {
            var maxCover = 0
            var maxIndex = 0
            for (i, set) in probabilities.enumerated() {
                let cover = (set.count - covered.intersection(set).count)
                if cover > maxCover {
                    maxCover = cover
                    maxIndex = i
                }
            }
            evs.append(maxIndex)
            covered = covered.union(probabilities[maxIndex])
        }
        return evs
        
        
    }
    
    public func predict(sample: [Double]) -> [Double] {
        var probabilities: [Double] = []
        for ev in self.extremeVectors {
            probabilities.append(calculatePsi(params: marginWeibulls[ev], distance: calculateDistance(from: sample, to: self.positives[ev])))
        }
        return probabilities
    }
    
    private func calculateDistanceMatrix(from arrayA: [[Double]], and arrayB: [[Double]]) -> [[Double]] {
        var distMatrix: [[Double]] = []
        for indexA in 0..<arrayA.count {
            var distVector:[Double] = []
            for indexB in 0..<arrayB.count {
                distVector.append(self.calculateDistance(from: arrayA[indexA], to: arrayB[indexB]))
            }
            distMatrix.append(distVector)
        }
        return distMatrix
    }
    
    private func calculatePsi(params: WeibullParams, distance: Double) -> Double {
        let power = O.accuratePow(distance / params.lambda, params.kappa)
        return exp(-1 * power)
    }
    
    private func calculateDistance(from arrayA: [Double], to arrayB: [Double]) -> Double {
        switch self.distanceType {
        case "eucledian":
            return self.eucledianDist(from: arrayA, to: arrayB)
        case "cosine":
            return self.cosineDist(from: arrayA, to: arrayB)
        case "jacard":
            return self.jacardDist(from: arrayA, to: arrayB)
        case "L1":
            return self.lOneDist(from: arrayA, to: arrayB)
        default:
            return self.eucledianDist(from: arrayA, to: arrayB)
        }
    }
    
    private func eucledianDist(from arrayA: [Double], to arrayB: [Double]) -> Double {
        var dotProduct: Double = 0
        for i in 0..<arrayA.count {
            dotProduct += O.accuratePow(abs(arrayA[i] - arrayB[i]), 2)
        }
        return dotProduct
    }
    
    private func cosineDist(from arrayA: [Double], to arrayB: [Double]) -> Double {
        var dotProduct: Double = 0
        var normA: Double = 0
        var normB: Double = 0
        for i in 0..<arrayA.count {
            dotProduct += arrayA[i] * arrayB[i]
            normA += O.accuratePow(arrayA[i], 2)
            normB += O.accuratePow(arrayB[i], 2)
        }
        return dotProduct / (normA.squareRoot() * normB.squareRoot())
    }
    
    private func jacardDist(from arrayA: [Double], to arrayB: [Double]) -> Double {
        var num: Double = 0
        var den: Double = 0
        for i in 0..<arrayA.count {
            if arrayA[i] > 0 || arrayB[i] > 0 {
                den += 1
                if arrayA[i] > 0 && arrayB[i] > 0 {
                    num += 1
                }
            }
        }
        return 1 - num / den
    }
    
    private func lOneDist(from arrayA: [Double], to arrayB: [Double]) -> Double {
        var dotProduct: Double = 0
        for i in 0..<arrayA.count {
            dotProduct += abs(arrayA[i] - arrayB[i])
        }
        return dotProduct
    }
    
    
}
