//
//  Calculation.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import Foundation

struct PFC {
    var protein: Double
    var fat: Double
    var carbohydrate: Double

    var ketoRatio: Double {  // ケトン比の算出
        fat / (protein + carbohydrate)
    }

    var ketoIndex: Double {  // ケトン指数の算出
        (0.9 * fat + 0.46 * protein) / (carbohydrate + 0.1 * fat + 0.58 * protein)
    }
}

struct PFS {
    var protein: Double
    var fat: Double
    var sugar: Double

    var ketoNumber: Double {  // ケトン値の算出
        (0.9 * fat + 0.46 * protein) / (sugar + 0.1 * fat + 0.58 * protein)
    }
}
