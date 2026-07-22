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

    // 2. Live counts pulled from the same offline CSVs the finder views use,
    // so the category cards show real numbers instead of placeholders.
    @State private var foodCount: Int = 0
    @State private var housingCount: Int = 0
    @State private var internetCount: Int = 0

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)
            VStack {
                HStack {
                    Text("BridgeNet")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    NavigationLink(value: Route.accessibility) {
                        Image(systemName: "accessibility")
                            .font(.system(size: 40))
                            .padding(.trailing, 20)
                            .foregroundStyle(.lightblue)
                            .accessibilityLabel("Accessibility Options")
                    }
                }
                HStack {
                    Text("Chicago resource navigator")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .fontWeight(.light)
                        .padding(.leading, 30)
                        .accessibilityLabel("Chicago resource navigator")
                    Spacer()
                }
                HStack {
                    Text("Works offline - No Wi-Fi needed")
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.leading, 18)
                        .padding(.trailing, 82)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.lightblue)
                                .opacity(0.50)
                        }
                        .accessibilityLabel("Works offline, No Wi-Fi needed")
                }
                HStack {
                    Text("BROWSE BY CATEGORY")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .padding(.leading, 30)
                        .foregroundStyle(.offwhite)
                        .padding(.top, 2)
                        .padding(.bottom, 1)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
                HStack {
                    // 2. Transformed the raw button execution into a cleaner page navigation handler
                    NavigationLink(destination: FoodPantryFinderView()) {
                        CategoryCard(iconName: "cart.fill.badge.plus", category: "Food", resources: foodCount, iconColor: .olivegreen)
                    }
                    .padding(3)
                    .buttonStyle(.plain) // Prevents SwiftUI from turning your entire custom card blue
                    
                    CategoryCard(iconName: "ellipsis.circle.fill", category: "Utilities", resources: 198, iconColor: .brown)
                }
                HStack {
                    NavigationLink(destination: InternetResourceFinderView()) {
                        CategoryCard(iconName: "wifi", category: "Internet", resources: internetCount, iconColor: .blue)
                    }
                    .padding(3)
                    .buttonStyle(.plain) // Prevents SwiftUI from turning your entire custom card blue
                    NavigationLink(destination: AffordableHousingFinderView()) {
                        CategoryCard(iconName: "house.fill", category: "Housing", resources: housingCount, iconColor: .bluegreen)
                    }
                    .buttonStyle(.plain) // Prevents SwiftUI from turning your entire custom card blue
                }
                HStack {
                    CategoryCard(iconName: "bandage.fill", category: "Health", resources: 125, iconColor: .red)
                        .padding(3)
                    CategoryCard(iconName: "map.fill", category: "Navigation", resources: 210, iconColor: .bluegray)
                }
                HStack {
                    CategoryCard(iconName: "bag.fill.badge.plus", category: "Jobs", resources: 150, iconColor: .purple)
                        .padding(3)
                    CategoryCard(iconName: "doc.text.fill", category: "Legal", resources: 107, iconColor: .redorange)
                }
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            loadResourceCounts()
        }
    }

    // Reuses each data layer's existing CSV loader purely for its count —
    // same offline files the finder views and Search page already read.
    private func loadResourceCounts() {
        foodCount = PantryManager.loadPantriesFromCSV().count
        housingCount = HousingManager.loadListingsFromCSV().count
        internetCount = InternetResourceManager.loadResourcesFromCSV().count
    }
}

// 4. A clean secondary screen that encapsulates the offline calculation UI
struct FoodPantryFinderView: View {
    @EnvironmentObject private var savedStore: SavedItemsStore
    // Set when arriving from Chat with a zip code already in hand, so the
    // search runs immediately instead of waiting for the person to retype it.
    var initialZip: String? = nil
    @State private var inputZip: String = ""
    @State private var nearbyPantries: [(pantry: Pantry, milesAway: Double)] = []
    @State private var errorMessage: String? = nil
    @State private var hasSearched = false
    @State private var selectedResource: SavedResource? = nil

    private func performSearch() {
        let completeZipDB = loadZipDatabase()
        nearbyPantries = PantryManager.findPantriesNear(userZip: inputZip, zipDatabase: completeZipDB)
        errorMessage = PantryManager.lastLoadError
        hasSearched = true
    }

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
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)
            VStack {
                Text("Find Food Assistance Nearby")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.top)
                
                TextField(
                    text: $inputZip,
                    prompt: Text("Enter 5-Digit Chicago ZIP Code").foregroundStyle(.black.opacity(0.7))
                ) {
                    Text("ZIP Code Input") // Accessibility label
                }
                    .keyboardType(.numberPad)
                    .padding(12) // Inner spacing for text
                    .background(Color.sagegreen) // Custom background color
                    .foregroundStyle(.black) // Custom text color
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Mimics rounded border
                    .padding() // Outer spacing
                    .accessibilityLabel("Enter 5-Digit Chicago ZIP Code")
                    .accessibilityHint("Input your 5-digit ZIP code for Chicago")
                
                Button("Find Closest Options") {
                    performSearch()
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
                
                if hasSearched {
                    List {
                        Section {
                            ForEach(CitywideFoodResources.all) { resource in
                                Button {
                                    selectedResource = resource
                                } label: {
                                    ResourceRow(resource: resource)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("Available to All Chicago Residents")
                                .foregroundStyle(.white)
                                .accessibilityAddTraits(.isHeader)
                        }

                        if !nearbyPantries.isEmpty {
                            Section {
                                ForEach(nearbyPantries, id: \.pantry.id) { item in
                                    let resource = item.pantry.asSavedResource(milesAway: item.milesAway)
                                    Button {
                                        selectedResource = resource
                                    } label: {
                                        ResourceRow(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            } header: {
                                Text("Near ZIP \(inputZip)")
                                    .foregroundStyle(.white)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Food Navigator")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedResource) { resource in
                ResourceDetailSheet(resource: resource)
                    .environmentObject(savedStore)
            }
            .onAppear {
                guard !hasSearched, let initialZip else { return }
                inputZip = initialZip
                performSearch()
            }
        }
    }
}


// 5. A clean secondary screen that encapsulates the offline housing search UI
struct AffordableHousingFinderView: View {
    @EnvironmentObject private var savedStore: SavedItemsStore
    // Set when arriving from Chat with a zip code already in hand, so the
    // search runs immediately instead of waiting for the person to retype it.
    var initialZip: String? = nil
    @State private var inputZip: String = ""
    @State private var nearbyListings: [(listing: HousingListing, milesAway: Double)] = []
    @State private var errorMessage: String? = nil
    @State private var hasSearched = false
    @State private var selectedResource: SavedResource? = nil

    private func performSearch() {
        let completeZipDB = loadZipDatabase()
        nearbyListings = HousingManager.findHousingNear(userZip: inputZip, zipDatabase: completeZipDB)
        errorMessage = HousingManager.lastLoadError
        hasSearched = true
    }

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
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)
            VStack {
                Text("Find Affordable Housing Nearby")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                    .foregroundStyle(.white)
                
                TextField(
                    text: $inputZip,
                    prompt: Text("Enter 5-Digit Chicago ZIP Code").foregroundStyle(.black.opacity(0.7))
                ) {
                    Text("ZIP Code Input") // Accessibility label
                }
                .keyboardType(.numberPad)
                .padding(12) // Inner spacing for text
                .background(Color.sagegreen) // Custom background color
                .foregroundStyle(.black) // Custom text color
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Mimics rounded border
                .padding() // Outer spacing
                .accessibilityLabel("Enter 5-Digit Chicago ZIP Code")
                .accessibilityHint("Input your 5-digit ZIP code for Chicago")
                
                Button("Calculate Closest Options") {
                    performSearch()
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
                
                if hasSearched {
                    List {
                        Section {
                            ForEach(CitywideHousingResources.all) { resource in
                                Button {
                                    selectedResource = resource
                                } label: {
                                    ResourceRow(resource: resource)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("Available to All Chicago Residents")
                                .foregroundStyle(.white)
                                .accessibilityAddTraits(.isHeader)
                        }

                        if !nearbyListings.isEmpty {
                            Section {
                                ForEach(nearbyListings, id: \.listing.id) { item in
                                    let resource = item.listing.asSavedResource(milesAway: item.milesAway)
                                    Button {
                                        selectedResource = resource
                                    } label: {
                                        ResourceRow(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            } header: {
                                Text("Near ZIP \(inputZip)")
                                    .foregroundStyle(.white)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Housing Navigator")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedResource) { resource in
                ResourceDetailSheet(resource: resource)
                    .environmentObject(savedStore)
            }
            .onAppear {
                guard !hasSearched, let initialZip else { return }
                inputZip = initialZip
                performSearch()
            }
        }
    }
}


// 6. A clean secondary screen that encapsulates the offline internet resource search UI
struct InternetResourceFinderView: View {
    @EnvironmentObject private var savedStore: SavedItemsStore
    // Set when arriving from Chat with a zip code already in hand, so the
    // search runs immediately instead of waiting for the person to retype it.
    var initialZip: String? = nil
    @State private var inputZip: String = ""
    @State private var nearbyResources: [(resource: InternetResource, milesAway: Double)] = []
    @State private var errorMessage: String? = nil
    @State private var hasSearched = false
    @State private var selectedResource: SavedResource? = nil

    private func performSearch() {
        let completeZipDB = loadZipDatabase()
        nearbyResources = InternetResourceManager.findResourcesNear(userZip: inputZip, zipDatabase: completeZipDB)
        errorMessage = InternetResourceManager.lastLoadError
        hasSearched = true
    }

    // Helper function to load your bundled chicago_zips.json file completely offline
    private func loadZipDatabase() -> [ZipCoordinate] {
        guard let url = Bundle.main.url(forResource: "chicago_zips", withExtension: "json") else {
            InternetResourceManager.lastLoadError = "chicago_zips.json is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find chicago_zips.json in the app bundle.")
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            InternetResourceManager.lastLoadError = "chicago_zips.json was found but couldn't be read."
            return []
        }
        guard let decoded = try? JSONDecoder().decode([ZipCoordinate].self, from: data) else {
            InternetResourceManager.lastLoadError = "chicago_zips.json was found but failed to decode — check that its JSON is well-formed."
            return []
        }
        return decoded
    }

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)
            VStack {
                Text("Find Internet Resources Nearby")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                
                TextField(
                    text: $inputZip,
                    prompt: Text("Enter 5-Digit Chicago ZIP Code").foregroundStyle(.black.opacity(0.7))
                ) {
                    Text("ZIP Code Input") // Accessibility label
                }
                .keyboardType(.numberPad)
                .padding(12) // Inner spacing for text
                .background(Color.sagegreen) // Custom background color
                .foregroundStyle(.black) // Custom text color
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Mimics rounded border
                .padding() // Outer spacing
                .accessibilityLabel("Enter 5-Digit Chicago ZIP Code")
                .accessibilityHint("Input your 5-digit ZIP code for Chicago")
                
                Button("Calculate Closest Options") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .accessibilityLabel("Calculate Closest Options")
                .accessibilityHint("Finds the closest options for your ZIP code")
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if hasSearched && nearbyResources.isEmpty {
                    Text("No results. Double-check the ZIP code and try again.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                if hasSearched {
                    List {
                        Section {
                            ForEach(CitywideInternetResources.all) { resource in
                                Button {
                                    selectedResource = resource
                                } label: {
                                    ResourceRow(resource: resource)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("Available to All Chicago Residents")
                                .foregroundStyle(.white)
                                .accessibilityAddTraits(.isHeader)
                        }

                        if !nearbyResources.isEmpty {
                            Section {
                                ForEach(nearbyResources, id: \.resource.id) { item in
                                    let resource = item.resource.asSavedResource(milesAway: item.milesAway)
                                    Button {
                                        selectedResource = resource
                                    } label: {
                                        ResourceRow(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            } header: {
                                Text("Near ZIP \(inputZip)")
                                    .foregroundStyle(.white)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Internet Navigator")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedResource) { resource in
                ResourceDetailSheet(resource: resource)
                    .environmentObject(savedStore)
            }
            .onAppear {
                guard !hasSearched, let initialZip else { return }
                inputZip = initialZip
                performSearch()
            }
        }
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
                .fill(Color.sagegreen)
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
            .environmentObject(SavedItemsStore())
    }
}
