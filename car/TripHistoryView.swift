import SwiftUI
import SwiftData

struct TripHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]

    var body: some View {
        List {
            ForEach(trips) { trip in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .shortened)) - \(trip.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance: \(String(format: "%.1f", trip.distanceTraveledKM)) km")
                            Text("Fuel: \(String(format: "%.2f", trip.fuelUsedLiters)) L")
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Cost: \(String(format: "%.2f", trip.fuelCost)) \(trip.fuelCurrency)")
                                .bold()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteTrips)
        }
        .navigationTitle("Trip history")
        .overlay {
            if trips.isEmpty {
                Text("No trips recorded yet.")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func deleteTrips(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
    }
}
