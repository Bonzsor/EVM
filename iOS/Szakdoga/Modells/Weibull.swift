//
//  Weibull.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 10. 15..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import Foundation

struct WeibullParams {
    let kappa: Double
    let lambda: Double
}

class Weibull {
//    static func weibullFit(array: [Double]) -> WeibullParams{
//        var kappa: Double = 1
//        let lnX = O.lnArray(with: array)
//        var kt1 = kappa
//        let iterations = 100
//        let epsilon: Double = 1e-6
//
//        for _ in 0...iterations {
//            let xPowKappa = O.powArray(with: array, power: kappa)
//            let xPowKappaLnX = O.multiplyArrays(xPowKappa, lnX)
//            let ff = xPowKappa.reduce(0, +)
//            let fg = xPowKappaLnX.reduce(0, +)
//            let f = ff / fg - O.getMean(from: lnX) - (1/kappa)
//
//            // Calculate second derivative
//
//            let ffPrime = O.multiplyArrays(xPowKappaLnX, lnX).reduce(0, +)
//            let fgPrime = ff
//            let fPrime = (ffPrime/fg - (ff/fg * fgPrime/fg) + (1/(kappa*kappa)))
//
//            // Newton-Raphson method
//
//            kappa -= f/fPrime
//
//            if f.isNaN {
//                return WeibullParams(kappa: Double.nan, lambda: Double.nan)
//            }
//            if abs(kappa-kt1) < epsilon {
//                break
//            }
//            kt1 = kappa
//        }
//
//        let lambda = pow(O.getMean(from: O.powArray(with: array, power: kappa)), 1/kappa)
//        return WeibullParams(kappa: kappa, lambda: lambda)
//    }
    
    
    static func fitHigh(array: [Double]) -> WeibullParams {
        let fittingSize: Int = array.count
        var sortedArray = array.sorted {
            $0 > $1
        }
        let smallScore = sortedArray[fittingSize - 1]
        let translateAmount = 1
        sortedArray = sortedArray.map{$0 + Double(translateAmount) - smallScore}
        return weibullFit(array: sortedArray)
    }
    
    private static func weibullFit(array: [Double]) -> WeibullParams {
        let FULL_PRECISION_MIN: Double = 2.225073858507201e-307
        let FULL_PRECISION_MAX: Double = 1.797693134862315e+308
        var variable: [Double] = []
        var x0: [Double] = []

        var maxVal: Double = -1000000000
        var minVal: Double = 1000000000
        
        let inputData = O.lnArray(with: array)
        
        
        for element in inputData {
            maxVal = element > maxVal ? element : maxVal
            minVal = element < minVal ? element : minVal
        }
        
        let range: Double = maxVal - minVal
        
        for element in inputData {
            x0.append((element - maxVal) / range)
        }
        
        let mean: Double = O.getMean(from: x0)
        var myStd: Double = 0
        
        for element in x0 {
            variable.append(element - mean)
        }
        
        for element in variable {
            myStd += element * element
        }
        
        myStd /= (Double(array.count) - 1)
        myStd = myStd.squareRoot()
        
        var sigmahat: Double = (6.squareRoot() * myStd) / Double.pi
        var upper: Double
        var lower: Double
        
        if self.weibullScaleLikelihood(sigmahat, x0, mean) > 0 {
            upper = sigmahat
            lower = 0.5 * upper
            
            while self.weibullScaleLikelihood(lower, x0, mean) > 0 {
                upper = lower
                lower = 0.5 * upper
                if lower < FULL_PRECISION_MIN {
                    print("error: MLE in wbfit Failed to converge leading for underflow in root finding")
                }
            }
        } else {
            lower = sigmahat
            upper = 2.0 * lower
            
            while self.weibullScaleLikelihood(upper, x0, mean) < 0 {
                lower = upper
                upper = 2 * lower
                if upper > FULL_PRECISION_MAX {
                    print("error: MLE in wbfit Failed to converge leading for overflow in root finding")
                }
            }
        }
        
        sigmahat = wdfzero(sigmahat: sigmahat, lower: lower, upper: upper, x0: x0, mean: mean)
        
        var sum: Double = 0
        for element in x0 {
            sum += exp(element / sigmahat)
        }
        
        sum /= Double(array.count)
            
        let muHat: Double = log(sum) * sigmahat
        return WeibullParams(kappa: 1 / (range * sigmahat), lambda: exp((range * muHat) + maxVal))
    }
    
    static private func weibullScaleLikelihood(_ sigma: Double, _ x: [Double], _ xbar: Double) -> Double {
        var sumxw: Double = 0
        var sumw: Double = 0
        
        for i in 0..<x.count {
            let wLocal: Double = exp(x[i] / sigma)
            sumxw += wLocal * x[i]
            sumw += wLocal
        }
        
        return sigma + xbar - (sumxw / sumw)
    }
    
    static private func wdfzero(sigmahat: Double, lower: Double, upper: Double, x0: [Double], mean: Double) -> Double {
        let tol: Double = 1.000000000000000e-006
        var a = upper
        var b = lower
        var c: Double = 0
        var d: Double = 0
        var e: Double = 0
        var p: Double? = nil
        var q: Double? = nil
         
        var fa = weibullScaleLikelihood(upper, x0, mean)
        var fb = weibullScaleLikelihood(lower, x0, mean)
        var fc = fb
        
        if fa == 0 {
            return upper
        } else if fb == 0 {
            return lower
        }

        
        while fb != 0 && !fb.isNaN {
            if (fb > 0) == (fc > 0) {
                c = a
                fc = fa
                d = a - b
                e = d
            }
            
            var absFb: Double = abs(fb)
            let absFc: Double = abs(fc)
            if absFc < absFb {
                a = b
                b = c
                c = a
                fa = fb
                fb = fc
                fc = fa
            }
            let m: Double = 0.5 * (c - b)
            let absM: Double = abs(m)
            let absB: Double = abs(b)
            let absE: Double = abs(e)
            let absFa: Double = abs(fa)
            absFb = abs(fb)
            
            let tolerance = 2 * tol * ((absB > 1) ? absB : 1)
            if !(absM <= tolerance && fb == 0) && (absM <= tolerance || fb == 0) {
                break;
            }
            
            
              
            if !(absE < tolerance && absFa <= absFb) && (absE < tolerance || absFa <= absFb) {
                d = m
                e = m
            } else {

                var r: Double
                let s: Double = fb / fa

                if a == c {
                    p = 2 * m * s
                    q = 1 - s
                } else {
                    q = fa / fc
                    r = fb / fc
                    p = s * (2 * m * q! * (q! - r) - (b - a) * (r - 1))
                    q = (q! - 1) * (r - 1) * (s - 1)
                  }

                if p! > 0 {
                    q = -1 * q!
                } else {
                    p = -1 * p!
                }
            }
            
            
            if p != nil && q != nil {
                let absToleranceQ: Double = abs(tolerance * q!)
                let absEQ: Double = abs(0.5 * e * q!)
                if ((2 * p! < 3 * m * q! - absToleranceQ) && (p! < absEQ)) || !((2 * p! < 3 * m * q! - absToleranceQ) || (p! < absEQ)) {
                    e = d
                    d = p! / q!
                  }
                else {
                    d = m
                    e = m
                  }
            } else {
              d = m
              e = m
            }
            
            a = b
            fa = fb

            if abs(d) > tolerance {
                b = b + d
            } else if b > c {
                b = b - tolerance
            } else {
                b = b + tolerance
            }

            fb = weibullScaleLikelihood(b, x0, mean)
        }
        return b
    }
}
