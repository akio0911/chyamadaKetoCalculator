//
//  Calculation.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import Foundation

struct Nutrient {
    var protein: Double
    var fat: Double
    var carbohydrate: Double?
    var sugar: Double?

    init(protein: Double, fat: Double, carbohydrate: Double) {
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
        self.sugar = nil
    }

    init(protein: Double, fat: Double, sugar: Double) {
        self.protein = protein
        self.fat = fat
        self.carbohydrate = nil
        self.sugar = sugar
    }

    func ketoRatio() -> Double {  // ケトン比の算出
        guard let carbohydrate = carbohydrate else {
            fatalError()
        }
        return fat / (protein + carbohydrate)
    }

    func ketoIndex() -> Double {  // ケトン指数の算出
        guard let carbohydrate = carbohydrate else {
            fatalError()
        }

        return (0.9 * fat + 0.46 * protein) / (carbohydrate + 0.1 * fat + 0.58 * protein)
    }

    func ketoNumber() -> Double {  // ケトン値の算出
        guard let sugar = sugar else {
            fatalError()
        }

        return  (0.9 * fat + 0.46 * protein) / (sugar + 0.1 * fat + 0.58 * protein)
    }
}
