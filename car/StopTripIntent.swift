import Foundation
import AppIntents
import SwiftData

struct StopTripIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop trip"
    static var description = IntentDescription("Stops the current trip and saves all measurements to history.")

    func perform() async throws -> some IntentResult {
        // stop the trip and get the resulting data
        guard let tripData = await OBDManager.shared.stopTrip() else {
            return .result()
        }
        
        // end the dynamic island / lock screen activity
        await LiveActivityManager.shared.endActivity()
        
        // save the trip to swiftdata
        do {
            let container = try ModelContainer(for: Trip.self)
            let context = ModelContext(container)
            
            let newTrip = Trip(
                startDate: tripData.0,
                endDate: tripData.1,
                distanceTraveledKM: tripData.2,
                fuelUsedLiters: tripData.3,
                fuelCost: tripData.4,
                fuelCurrency: tripData.5
            )
            
            context.insert(newTrip)
            try context.save()
        } catch {
            print("failed to save trip from shortcut: \(error)")
        }
        
        return .result()
    }
}
