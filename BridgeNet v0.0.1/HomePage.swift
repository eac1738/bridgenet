//
//  HomePage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI

struct HomePage: View {
    // 1. Storage properties to handle user inputs and sorted arrays safely across screens
    @State private var inputZip: String = ""
    @State private var nearbyPantries: [(pantry: Pantry, milesAway: Double)] = []

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.offwhite)
            VStack {
                HStack {
                    Text("BridgeNet")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    NavigationLink(value: Route.accessibility) {
                        Image(systemName: "accessibility")
                            .font(.system(size: 35))
                            .padding(.trailing, 20)
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Accessibility Options")
                    }
                }
                HStack {
                    Text("Chicago resource navigator")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .padding(.leading, 30)
                    Spacer()
                }
                HStack {
                    Text("Works offline - No Wi-Fi needed")
                        .font(.system(size: 17))
                        .foregroundStyle(.bluegreen)
                        .fontWeight(.semibold)
                        .padding(.leading, 18)
                        .padding(.trailing, 82)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.sagegreen)
                                .opacity(0.50)
                        }
                        .accessibilityLabel("Works offline, No Wi-Fi needed")
                }
                HStack {
                    Text("BROWSE BY CATEGORY")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .padding(.leading, 30)
                        .foregroundStyle(.darkgray)
                        .padding(.top, 2)
                        .padding(.bottom, 1)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
                HStack {
                    // 2. Transformed the raw button execution into a cleaner page navigation handler
                    NavigationLink(destination: FoodPantryFinderView()) {
                        CategoryCard(iconName: "cart.fill.badge.plus", category: "Food", resources: 12, iconColor: .olivegreen)
                    }
                    .padding(3)
                    .buttonStyle(.plain) // Prevents SwiftUI from turning your entire custom card blue
                    
                    CategoryCard(iconName: "ellipsis.circle.fill", category: "Utilities", resources: 10, iconColor: .brown)
                }
                HStack {
                    CategoryCard(iconName: "wifi", category: "Internet", resources: 12, iconColor: .blue)
                        .padding(3)
                    NavigationLink(destination: AffordableHousingFinderView()) {
                        CategoryCard(iconName: "house.fill", category: "Housing", resources: 10, iconColor: .bluegreen)
                    }
                    .buttonStyle(.plain) // Prevents SwiftUI from turning your entire custom card blue
                }
                HStack {
                    CategoryCard(iconName: "bandage.fill", category: "Health", resources: 12, iconColor: .red)
                        .padding(3)
                    CategoryCard(iconName: "map.fill", category: "Navigation", resources: 10, iconColor: .bluegray)
                }
                HStack {
                    CategoryCard(iconName: "bag.fill.badge.plus", category: "Jobs", resources: 12, iconColor: .purple)
                        .padding(3)
                    CategoryCard(iconName: "doc.text.fill", category: "Legal", resources: 10, iconColor: .redorange)
                }
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// 4. A clean secondary screen that encapsulates the offline calculation UI
struct FoodPantryFinderView: View {
    @State private var inputZip: String = ""
    @State private var nearbyPantries: [(pantry: Pantry, milesAway: Double)] = []
    @State private var errorMessage: String? = nil
    @State private var hasSearched = false
    
    // 1. Helper function to load your bundled chicago_zips.json file completely offline
    private func loadZipDatabase() -> [ZipCoordinate] {
        guard let url = Bundle.main.url(forResource: "chicago_zips", withExtension: "json") else {
            PantryManager.lastLoadError = "chicago_zips.json is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find chicago_zips.json in the app bundle.")
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            PantryManager.lastLoadError = "chicago_zips.json was found but couldn't be read."
            return []
        }
        guard let decoded = try? JSONDecoder().decode([ZipCoordinate].self, from: data) else {
            PantryManager.lastLoadError = "chicago_zips.json was found but failed to decode — check that its JSON is well-formed."
            return []
        }
        return decoded
    }
    
    var body: some View {
        VStack {
            Text("Find Food Infrastructure Nearby")
                .font(.title2)
                .bold()
                .padding(.top)
            
            TextField("Enter 5-Digit Chicago ZIP Code", text: $inputZip)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .padding()
                .accessibilityLabel("Enter 5-Digit Chicago ZIP Code")
            
            Button("Calculate Closest Options") {
                // 2. Load the complete JSON file of Chicago coordinates
                let completeZipDB = loadZipDatabase()
                
                // 3. Execute the mileage calculation against the 98 indexed pantries
                nearbyPantries = PantryManager.findPantriesNear(userZip: inputZip, zipDatabase: completeZipDB)
                errorMessage = PantryManager.lastLoadError
                hasSearched = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.olivegreen)
            .accessibilityLabel("Calculate Closest Options")
            .accessibilityHint("Finds the closest options for your ZIP code")

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if hasSearched && nearbyPantries.isEmpty {
                Text("No results. Double-check the ZIP code and try again.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            List(nearbyPantries, id: \.pantry.id) { item in
                let accessibilitySummary = "\(item.pantry.name), \(item.pantry.address), \(item.pantry.phone.isEmpty ? "" : item.pantry.phone + ", ") \(String(format: "%.1f", item.milesAway)) miles away"
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.pantry.name)
                            .font(.headline)
                        Text(item.pantry.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !item.pantry.phone.isEmpty {
                            Text(item.pantry.phone)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                    Text(String(format: "%.1f mi", item.milesAway))
                        .bold()
                        .foregroundColor(.olivegreen)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilitySummary)
            }
        }
        .navigationTitle("Food Navigator")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// 5. A clean secondary screen that encapsulates the offline housing search UI
struct AffordableHousingFinderView: View {
    @State private var inputZip: String = ""
    @State private var nearbyListings: [(listing: HousingListing, milesAway: Double)] = []
    @State private var errorMessage: String? = nil
    @State private var hasSearched = false

    // Helper function to load your bundled chicago_zips.json file completely offline
    private func loadZipDatabase() -> [ZipCoordinate] {
        guard let url = Bundle.main.url(forResource: "chicago_zips", withExtension: "json") else {
            HousingManager.lastLoadError = "chicago_zips.json is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find chicago_zips.json in the app bundle.")
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            HousingManager.lastLoadError = "chicago_zips.json was found but couldn't be read."
            return []
        }
        guard let decoded = try? JSONDecoder().decode([ZipCoordinate].self, from: data) else {
            HousingManager.lastLoadError = "chicago_zips.json was found but failed to decode — check that its JSON is well-formed."
            return []
        }
        return decoded
    }

    var body: some View {
        VStack {
            Text("Find Affordable Housing Nearby")
                .font(.title2)
                .bold()
                .padding(.top)

            TextField("Enter 5-Digit Chicago ZIP Code", text: $inputZip)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .padding()
                .accessibilityLabel("Enter 5-Digit Chicago ZIP Code")

            Button("Calculate Closest Options") {
                // Load the complete JSON file of Chicago coordinates
                let completeZipDB = loadZipDatabase()

                // Execute the mileage calculation against the indexed listings
                nearbyListings = HousingManager.findHousingNear(userZip: inputZip, zipDatabase: completeZipDB)
                errorMessage = HousingManager.lastLoadError
                hasSearched = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.bluegreen)
            .accessibilityLabel("Calculate Closest Options")
            .accessibilityHint("Finds the closest options for your ZIP code")

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if hasSearched && nearbyListings.isEmpty {
                Text("No results. Double-check the ZIP code and try again.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            List(nearbyListings, id: \.listing.id) { item in
                let accessibilitySummary = "\(item.listing.propertyName), \(item.listing.address), \(item.listing.phone.isEmpty ? "" : item.listing.phone + ", ") \(String(format: "%.1f", item.milesAway)) miles away"
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.listing.propertyName)
                            .font(.headline)
                        Text(item.listing.propertyType)
                            .font(.caption)
                            .foregroundColor(.bluegreen)
                        Text(item.listing.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !item.listing.units.isEmpty {
                            Text("\(item.listing.units) unit(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if !item.listing.phone.isEmpty {
                            Text(item.listing.phone)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                    Text(String(format: "%.1f mi", item.milesAway))
                        .bold()
                        .foregroundColor(.bluegreen)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilitySummary)
            }
        }
        .navigationTitle("Housing Navigator")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct CategoryCard: View {
    let iconName: String
    let category: String
    var resources: Int
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 35, height: 35)
                    .foregroundStyle(iconColor)
                    .opacity(0.25)
                    .accessibilityHidden(true)
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .accessibilityHidden(true)
            }
            Text(category)
                .fontWeight(.bold)
                .font(.system(size: 20))
                .padding(.top, 5)
                .foregroundStyle(.black)

            Text("\(resources) resources")
                .fontWeight(.light)
                .font(.system(size: 15))
                .foregroundStyle(.black)
        }
        .frame(width: 150, height: 120, alignment: .leading)
        .padding(.leading, 18)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category), \(resources) resources")
        .accessibilityHint("Double tap to open \(category) resources")
    }
}

#Preview {
    NavigationStack {
        HomePage()
    }
}

