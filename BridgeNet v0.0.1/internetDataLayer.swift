//
//  internetDataLayer.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/17/26.
//

import Foundation
import CoreLocation

struct InternetResource: Identifiable {
    let id = UUID()
    let type: String
    let facility: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let phone: String
    let website: String
    let hours: String
    let appointmentRequired: String
    let hasInternet: Bool
    let hasWifi: Bool
    let hasTraining: Bool
    let latitude: Double
    let longitude: Double
}

class InternetResourceManager {

    // Set whenever a load/search step fails, so the UI can show *why* instead of just an empty list.
    static var lastLoadError: String? = nil

    // Parse the CSV file entirely offline.
    // Columns (0-indexed): 0 Type, 1 Facility, 2 Street Address, 3 City, 4 State,
    // 5 Zip, 6 Phone, 7 Website, 8 Hours, 9 Appointment, 10 Internet, 11 Wifi,
    // 12 Training, 13 Location (contains "(lat, lon)" at the end)
    static func loadResourcesFromCSV() -> [InternetResource] {
        var parsedResources: [InternetResource] = []
        lastLoadError = nil

        // Find the file in your Xcode project bundle
        guard let path = Bundle.main.path(forResource: "internet_resources", ofType: "csv") else {
            lastLoadError = "internet_resources.csv is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find internet_resources.csv in the app bundle.")
            return []
        }
        guard let csvContent = try? String(contentsOfFile: path, encoding: .utf8) else {
            lastLoadError = "internet_resources.csv was found in the bundle but couldn't be read as UTF-8 text."
            print("Could not open internet_resources.csv in the app bundle.")
            return []
        }

        // Break the file into individual rows
        let rows = csvContent.components(separatedBy: "\n")

        // Skip the very first row because it contains column headers
        for row in rows.dropFirst() {
            let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedRow.isEmpty { continue }

            // Clean up rows that contain quote marks around names or addresses
            let columns = parseCSVRow(row)

            // Safety check: Ensure the row has enough columns to extract fields safely
            guard columns.count > 13 else { continue }

            let type = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let facility = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let streetAddress = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let city = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let state = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let zipCode = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let website = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
            let hours = columns[8].trimmingCharacters(in: .whitespacesAndNewlines)
            let appointment = columns[9].trimmingCharacters(in: .whitespacesAndNewlines)
            let hasInternet = columns[10].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
            let hasWifi = columns[11].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
            let hasTraining = columns[12].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
            let locationField = columns[13].trimmingCharacters(in: .whitespacesAndNewlines)

            // The Location column packs the coordinates in as trailing "(lat, lon)" text
            guard let (lat, lon) = extractCoordinates(from: locationField) else { continue }

            guard !streetAddress.isEmpty, !facility.isEmpty else { continue }

            let cleanResource = InternetResource(
                type: type,
                facility: facility,
                address: streetAddress,
                city: city,
                state: state,
                zipCode: zipCode,
                phone: phone,
                website: website,
                hours: hours,
                appointmentRequired: appointment,
                hasInternet: hasInternet,
                hasWifi: hasWifi,
                hasTraining: hasTraining,
                latitude: lat,
                longitude: lon
            )
            parsedResources.append(cleanResource)
        }

        print("Successfully built an offline index of \(parsedResources.count) internet resources.")
        return parsedResources
    }

    // Main search and distance logic mapping your ZIP reference index
    static func findResourcesNear(userZip: String, zipDatabase: [ZipCoordinate]) -> [(resource: InternetResource, milesAway: Double)] {
        let allResources = loadResourcesFromCSV()
        let trimmedZip = userZip.trimmingCharacters(in: .whitespacesAndNewlines)

        // Locate starting position matching user's ZIP code
        guard let targetZip = zipDatabase.first(where: { $0.zipCode == trimmedZip }) else {
            if zipDatabase.isEmpty {
                // loadResourcesFromCSV() may have already set a more specific message; only overwrite if empty
                if lastLoadError == nil {
                    lastLoadError = "chicago_zips.json didn't load, so there's no ZIP database to search against."
                }
            } else {
                lastLoadError = "\"\(trimmedZip)\" may not be a city of Chicago zip code. Please enter a valid 5-digit zip code. Note suburban zip codes like 60007 will not work. Valid zip codes begin with 606, 607, or 608."
            }
            return []
        }

        let startPoint = CLLocation(latitude: targetZip.latitude, longitude: targetZip.longitude)

        let matches = allResources.map { resource -> (InternetResource, Double) in
            let resourcePoint = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
            let distanceInMeters = startPoint.distance(from: resourcePoint)
            let distanceInMiles = distanceInMeters * 0.000621371
            return (resource, distanceInMiles)
        }

        // Sort from closest mileage outward
        return matches.sorted { $0.1 < $1.1 }
    }

    // Pulls "(41.94, -87.81)" style coordinates out of the trailing Location text
    private static func extractCoordinates(from location: String) -> (Double, Double)? {
        guard let openParen = location.lastIndex(of: "("),
              let closeParen = location.lastIndex(of: ")"),
              openParen < closeParen else { return nil }

        let coordsString = location[location.index(after: openParen)..<closeParen]
        let parts = coordsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        guard parts.count == 2, let lat = Double(parts[0]), let lon = Double(parts[1]) else { return nil }
        return (lat, lon)
    }

    // Simple helper parser to handle standard comma-separated data chunks smoothly
    private static func parseCSVRow(_ row: String) -> [String] {
        var tokens: [String] = []
        var currentToken = ""
        var insideQuotes = false

        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                tokens.append(currentToken)
                currentToken = ""
            } else {
                currentToken.append(char)
            }
        }
        tokens.append(currentToken)
        return tokens
    }
}
