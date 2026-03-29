import Foundation
import SwiftData

@Model
final class Trip {
    var startDate: Date
    var endDate: Date
    var distanceTraveledKM: Double
    var fuelUsedLiters: Double
    var fuelCost: Double
    var fuelCurrency: String
    
    init(startDate: Date, endDate: Date, distanceTraveledKM: Double, fuelUsedLiters: Double, fuelCost: Double, fuelCurrency: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.distanceTraveledKM = distanceTraveledKM
        self.fuelUsedLiters = fuelUsedLiters
        self.fuelCost = fuelCost
        self.fuelCurrency = fuelCurrency
    }
}
