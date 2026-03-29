import Foundation
import SwiftOBD2
import Combine

@Observable
class OBDManager {
    static let shared = OBDManager()

    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case failed
    }

    var connectionState: ConnectionState = .disconnected
    var momentaryFuelUsage: Double = 0.0 // L/100km
    var distanceTraveledKM: Double = 0.0 // km
    var fuelUsedLiters: Double = 0.0 // Liters
    var fuelCost: Double = 0.0
    var fuelCurrency: String = ""
    
    var tripStartDate: Date?
    
    private var obdService: OBDService?
    private var updateTimer: Timer?
    private var lastUpdateTime: Date?
    private var currentFuelPrice: Double = 0.0
    
    func connect(fuelPrice: Double, currency: String) async {
        self.currentFuelPrice = fuelPrice
        self.fuelCurrency = currency
        self.connectionState = .connecting
        
        self.obdService = OBDService(connectionType: .bluetooth)
        
        do {
            let testCommand = OBDCommand.mode1(.rpm)
            _ = try await obdService?.sendCommand(testCommand)
            
            await MainActor.run {
                self.connectionState = .connected
                self.startTrip()
            }
        } catch {
            await MainActor.run { self.connectionState = .failed }
        }
    }
    
    private func startTrip() {
        tripStartDate = Date()
        lastUpdateTime = Date()
        distanceTraveledKM = 0.0
        fuelUsedLiters = 0.0
        fuelCost = 0.0
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchDataAndUpdate()
            }
        }
    }
    
    private func fetchDataAndUpdate() async {
        guard let obdService = obdService else { return }
        
        do {
            let speedCommand = OBDCommand.mode1(.speed)
            let fuelRateCommand = OBDCommand.mode1(.fuelRate)
            
            let speedResult = try await obdService.sendCommand(speedCommand)
            let fuelRateResult = try await obdService.sendCommand(fuelRateCommand)
            
            var speedKmH = 0.0
            var fuelRateLh = 0.0
            
            switch speedResult {
            case .success(.measurementResult(let measurement)):
                speedKmH = measurement.value
            case .success(.stringResult(let str)):
                speedKmH = Double(str) ?? 0.0
            case .success, .failure:
                break
            }
            
            switch fuelRateResult {
            case .success(.measurementResult(let measurement)):
                fuelRateLh = measurement.value
            case .success(.stringResult(let str)):
                fuelRateLh = Double(str) ?? 0.0
            case .success, .failure:
                break
            }
            
            await MainActor.run {
                self.updateCalculations(speedKmH: speedKmH, fuelRateLh: fuelRateLh)
            }
        } catch {
            print("[!!!] error fetching OBD data: \(error.localizedDescription)")
        }
    }
    
    private func updateCalculations(speedKmH: Double, fuelRateLh: Double) {
        let now = Date()
        guard let lastTime = lastUpdateTime else {
            lastUpdateTime = now
            return
        }
        
        let timeDeltaSeconds = now.timeIntervalSince(lastTime)
        let timeDeltaHours = timeDeltaSeconds / 3600.0
        
        let distanceDelta = speedKmH * timeDeltaHours
        let fuelDelta = fuelRateLh * timeDeltaHours
        
        distanceTraveledKM += distanceDelta
        fuelUsedLiters += fuelDelta
        fuelCost = fuelUsedLiters * currentFuelPrice
        
        if speedKmH > 0 {
            momentaryFuelUsage = (fuelRateLh / speedKmH) * 100.0
        } else {
            momentaryFuelUsage = 0.0
        }
        
        lastUpdateTime = now
    }
    
    func stopTrip() -> (Date, Date, Double, Double, Double, String)? {
        updateTimer?.invalidate()
        updateTimer = nil
        
        obdService = nil
        connectionState = .disconnected
        
        guard let start = tripStartDate else { return nil }
        return (start, Date(), distanceTraveledKM, fuelUsedLiters, fuelCost, fuelCurrency)
    }
}
