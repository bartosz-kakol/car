import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("fuelPrice") private var fuelPrice: Double = 6.50
    @AppStorage("fuelCurrency") private var fuelCurrency: String = "PLN"
    
    @State private var priceString: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Fuel price")) {
                    HStack {
                        Text("Price per liter")
                        Spacer()
                        TextField("1.50", text: $priceString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: priceString) { oldValue, newValue in
                                // parse the string with comma or dot as decimal separator
                                let normalizedString = newValue.replacingOccurrences(of: ",", with: ".")
                                if let newPrice = Double(normalizedString) {
                                    fuelPrice = newPrice
                                }
                            }
                    }
                    
                    HStack {
                        Text("Currency")
                        Spacer()
                        TextField("USD", text: $fuelCurrency)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                priceString = String(format: "%.2f", fuelPrice)
            }
        }
    }
}
