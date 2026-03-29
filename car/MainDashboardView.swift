import SwiftUI

struct MainDashboardView: View {
    @State private var obdManager = OBDManager.shared
    @AppStorage("fuelPrice") private var fuelPrice: Double = 1.50
    @AppStorage("fuelCurrency") private var fuelCurrency: String = "USD"
    @State private var showingHistory = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if obdManager.connectionState == .failed {
                    Text("Failed to connect to the car.")
                        .foregroundColor(.red)
                    Button("Try again") {
                        Task { await obdManager.connect(fuelPrice: fuelPrice, currency: fuelCurrency) }
                    }
                    .buttonStyle(.borderedProminent)
                } else if obdManager.connectionState == .connecting {
                    ProgressView("Connecting to obd adapter...")
                } else if obdManager.connectionState == .connected {
                    dashboardContent
                } else {
                    Text("Disconnected.")
                        .foregroundColor(.secondary)
                    Button("Connect") {
                        Task { await obdManager.connect(fuelPrice: fuelPrice, currency: fuelCurrency) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .navigationDestination(isPresented: $showingHistory) {
                TripHistoryView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                if obdManager.connectionState == .disconnected {
                    Task { await obdManager.connect(fuelPrice: fuelPrice, currency: fuelCurrency) }
                }
            }
        }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        VStack(spacing: 50) {
            VStack(spacing: 12) {
                Text(String(format: "%.2f L", obdManager.fuelUsedLiters))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("Fuel used")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Text(String(format: "%.2f %@", obdManager.fuelCost, obdManager.fuelCurrency))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("Fuel cost")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.horizontal)
            
            HStack(spacing: 60) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f", obdManager.momentaryFuelUsage))
                        .font(.title.bold())
                    Text("L/100km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text(String(format: "%.1f", obdManager.distanceTraveledKM))
                        .font(.title.bold())
                    Text("km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
