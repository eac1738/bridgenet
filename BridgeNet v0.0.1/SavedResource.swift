//
//  SavedResource.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/21/26.
//

import SwiftUI
import Combine

enum ResourceCategory: String, Codable, CaseIterable {
    case food
    case housing
    case internet

    var displayName: String {
        switch self {
        case .food: return "Food Pantry"
        case .housing: return "Affordable Housing"
        case .internet: return "Internet Resource"
        }
    }

    // Plural label used for Saved page section headers
    var sectionTitle: String {
        switch self {
        case .food: return "Food"
        case .housing: return "Housing"
        case .internet: return "Internet"
        }
    }

    var iconName: String {
        switch self {
        case .food: return "cart.fill.badge.plus"
        case .housing: return "house.fill"
        case .internet: return "wifi"
        }
    }

    var color: Color {
        switch self {
        case .food: return .olivegreen
        case .housing: return .bluegreen
        case .internet: return .blue
        }
    }
}

// A normalized, save-friendly representation shared by all three resource types
// (Pantry, HousingListing, InternetResource) so a single detail popup and a single
// Saved page can display and persist any of them.
struct SavedResource: Identifiable, Codable, Equatable {
    let id: String
    let category: ResourceCategory
    let title: String
    let subtitle: String?
    let address: String
    let phone: String
    let milesAway: Double?
    let details: [String]
    let savedDate: Date
    let website: String?
    let isCitywideResource: Bool?

    // Convenience initializer with defaults for website/isCitywideResource so
    // existing call sites (Pantry/HousingListing/InternetResource conversions)
    // don't need to pass them.
    init(
        id: String,
        category: ResourceCategory,
        title: String,
        subtitle: String?,
        address: String,
        phone: String,
        milesAway: Double?,
        details: [String],
        savedDate: Date,
        website: String? = nil,
        isCitywideResource: Bool? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.address = address
        self.phone = phone
        self.milesAway = milesAway
        self.details = details
        self.savedDate = savedDate
        self.website = website
        self.isCitywideResource = isCitywideResource
    }

    // Optional properties decode to nil automatically when the key is missing,
    // so adding website/isCitywideResource here doesn't break decoding of
    // SavedResource JSON that was already persisted to UserDefaults before
    // these fields existed.
    var isCitywide: Bool {
        isCitywideResource == true
    }

    // A stable id built from category + title + address so the same physical
    // resource is recognized as "already saved" even after the CSVs are
    // re-parsed (which happens on every search and assigns fresh random UUIDs
    // to the underlying Pantry / HousingListing / InternetResource rows).
    static func makeID(category: ResourceCategory, title: String, address: String) -> String {
        "\(category.rawValue)|\(title)|\(address)"
    }
}

// MARK: - Conversion helpers from each data layer's model into a SavedResource

extension Pantry {
    func asSavedResource(milesAway: Double? = nil) -> SavedResource {
        SavedResource(
            id: SavedResource.makeID(category: .food, title: name, address: address),
            category: .food,
            title: name,
            subtitle: nil,
            address: address,
            phone: phone,
            milesAway: milesAway,
            details: [],
            savedDate: Date()
        )
    }
}

extension HousingListing {
    func asSavedResource(milesAway: Double? = nil) -> SavedResource {
        var details: [String] = []
        if !units.isEmpty { details.append("\(units) unit(s)") }
        if !managementCompany.isEmpty { details.append("Managed by \(managementCompany)") }

        return SavedResource(
            id: SavedResource.makeID(category: .housing, title: propertyName, address: address),
            category: .housing,
            title: propertyName,
            subtitle: propertyType.isEmpty ? nil : propertyType,
            address: address,
            phone: phone,
            milesAway: milesAway,
            details: details,
            savedDate: Date()
        )
    }
}

extension InternetResource {
    func asSavedResource(milesAway: Double? = nil) -> SavedResource {
        var details: [String] = []
        if !hours.isEmpty { details.append("Hours: \(hours)") }
        if !appointmentRequired.isEmpty { details.append("Appointment: \(appointmentRequired)") }
        if hasWifi { details.append("Wi-Fi available") }
        if hasInternet { details.append("Public internet access") }
        if hasTraining { details.append("Digital skills training offered") }

        return SavedResource(
            id: SavedResource.makeID(category: .internet, title: facility, address: address),
            category: .internet,
            title: facility,
            subtitle: type.isEmpty ? nil : type,
            address: address,
            phone: phone,
            milesAway: milesAway,
            details: details,
            savedDate: Date(),
            website: website.isEmpty ? nil : website
        )
    }
}

// MARK: - Persisted store of everything the user has saved, offline-friendly (UserDefaults)

final class SavedItemsStore: ObservableObject {
    @Published private(set) var savedItems: [SavedResource] = []

    private let storageKey = "BridgeNet.savedResources"

    init() {
        load()
    }

    func isSaved(id: String) -> Bool {
        savedItems.contains { $0.id == id }
    }

    func toggleSave(_ resource: SavedResource) {
        if let index = savedItems.firstIndex(where: { $0.id == resource.id }) {
            savedItems.remove(at: index)
        } else {
            savedItems.append(resource)
        }
        persist()
    }

    func remove(_ resource: SavedResource) {
        savedItems.removeAll { $0.id == resource.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(savedItems) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SavedResource].self, from: data) else { return }
        savedItems = decoded
    }
}
