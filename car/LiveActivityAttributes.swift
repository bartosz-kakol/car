import Foundation
import ActivityKit

struct TripActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var fuelUsedLiters: Double
        var fuelCost: Double
        var distanceTraveledKM: Double
        var momentaryFuelUsage: Double
    }

    var startDate: Date
    var fuelCurrency: String
}
