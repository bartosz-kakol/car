import WidgetKit
import SwiftUI
import ActivityKit

struct TripWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            // lock screen and banner ui
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fuel used")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", context.state.fuelUsedLiters)) L")
                        .font(.headline)
                    
                    Text("Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    Text("\(String(format: "%.2f", context.state.fuelCost)) \(context.attributes.fuelCurrency)")
                        .font(.headline)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", context.state.distanceTraveledKM)) km")
                        .font(.headline)
                    
                    Text("Usage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    Text("\(String(format: "%.1f", context.state.momentaryFuelUsage)) L/100km")
                        .font(.headline)
                }
            }
            .padding()
            
        } dynamicIsland: { context in
            DynamicIsland {
                // expanded ui (when you long press the dynamic island)
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Fuel")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", context.state.fuelUsedLiters)) L")
                            .font(.headline)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("Cost")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", context.state.fuelCost)) \(context.attributes.fuelCurrency)")
                            .font(.headline)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("\(String(format: "%.1f", context.state.distanceTraveledKM)) km")
                        Spacer()
                        Text("\(String(format: "%.1f", context.state.momentaryFuelUsage)) L/100km")
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
            } compactLeading: {
                // compact ui (left side of the island)
                Text("\(String(format: "%.1f", context.state.fuelUsedLiters))L")
                    .font(.caption2)
            } compactTrailing: {
                // compact ui (right side of the island)
                Text("\(String(format: "%.1f", context.state.fuelCost))\(context.attributes.fuelCurrency)")
                    .font(.caption2)
            } minimal: {
                // minimal ui (when multiple activities are active)
                Image(systemName: "fuelpump.fill")
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
        }
    }
}
