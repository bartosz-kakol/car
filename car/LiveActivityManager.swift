import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<TripActivityAttributes>?

    func startActivity(startDate: Date, currency: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = TripActivityAttributes(startDate: startDate, fuelCurrency: currency)
        let initialState = TripActivityAttributes.ContentState(
            fuelUsedLiters: 0.0,
            fuelCost: 0.0,
            distanceTraveledKM: 0.0,
            momentaryFuelUsage: 0.0
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("failed to start live activity: \(error)")
        }
    }

    func updateActivity(fuelUsedLiters: Double, fuelCost: Double, distanceTraveledKM: Double, momentaryFuelUsage: Double) {
        Task {
            let updatedState = TripActivityAttributes.ContentState(
                fuelUsedLiters: fuelUsedLiters,
                fuelCost: fuelCost,
                distanceTraveledKM: distanceTraveledKM,
                momentaryFuelUsage: momentaryFuelUsage
            )
            let content = ActivityContent(state: updatedState, staleDate: nil)
            await currentActivity?.update(content)
        }
    }

    func endActivity() async {
        guard let activity = currentActivity else { return }
        let finalState = activity.content.state
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        await activity.end(finalContent, dismissalPolicy: .default)
        currentActivity = nil
    }
}
