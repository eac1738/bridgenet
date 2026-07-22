//
//  housingDataLayer.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/16/26.
//

import Foundation
import CoreLocation

struct HousingListing: Identifiable {
    let id = UUID()
    let propertyName: String
    let propertyType: String
    let address: String
    let zipCode: String
    let phone: String
    let managementCompany: String
    let units: String
    let latitude: Double
    let longitude: Double
}

class HousingManager {

    // Set whenever a load/search step fails, so the UI can show *why* instead of just an empty list.
    static var lastLoadError: String? = nil

    // Parse the CSV file entirely offline.
    // Columns (0-indexed): 0 Community Area Name, 1 Community Area Number, 2 Property Type,
    // 3 Property Name, 4 Address, 5 Zip Code, 6 Phone Number, 7 Management Company,
    // 8 Units, 9 X Coordinate, 10 Y Coordinate, 11 Latitude, 12 Longitude, 13 Location
    static func loadListingsFromCSV() -> [HousingListing] {
        var parsedListings: [HousingListing] = []
        lastLoadError = nil

        // Find the file in your Xcode project bundle
        guard let path = Bundle.main.path(forResource: "afforadable_rentable_housing", ofType: "csv") else {
            lastLoadError = "afforadable_rentable_housing.csv is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find afforadable_rentable_housing.csv in the app bundle.")
            return []
        }
        guard let csvContent = try? String(contentsOfFile: path, encoding: .utf8) else {
            lastLoadError = "afforadable_rentable_housing.csv was found in the bundle but couldn't be read as UTF-8 text."
            print("Could not open afforadable_rentable_housing.csv in the app bundle.")
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
            guard columns.count > 12 else { continue }

            let propertyType = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let propertyName = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let streetAddress = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let zipCode = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let managementCompany = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
            let units = columns[8].trimmingCharacters(in: .whitespacesAndNewlines)

            // Extract the listing's built-in coordinates
            guard let lat = Double(columns[11].trimmingCharacters(in: .whitespacesAndNewlines)),
                  let lon = Double(columns[12].trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }

            guard !streetAddress.isEmpty, !propertyName.isEmpty else { continue }

            let cleanListing = HousingListing(
                propertyName: propertyName,
                propertyType: propertyType,
                address: streetAddress,
                zipCode: zipCode,
                phone: phone,
                managementCompany: managementCompany,
                units: units,
                latitude: lat,
                longitude: lon
            )
            parsedListings.append(cleanListing)
        }

        print("Successfully built an offline index of \(parsedListings.count) affordable housing listings.")
        return parsedListings
    }

    // Main search and distance logic mapping your ZIP reference index
    static func findHousingNear(userZip: String, zipDatabase: [ZipCoordinate], maxDistance: Double? = nil) -> [(listing: HousingListing, milesAway: Double)] {
        let allListings = loadListingsFromCSV()
        let trimmedZip = userZip.trimmingCharacters(in: .whitespacesAndNewlines)

        // Locate starting position matching user's ZIP code
        guard let targetZip = zipDatabase.first(where: { $0.zipCode == trimmedZip }) else {
            if zipDatabase.isEmpty {
                // loadListingsFromCSV() may have already set a more specific message; only overwrite if empty
                if lastLoadError == nil {
                    lastLoadError = "chicago_zips.json didn't load, so there's no ZIP database to search against."
                }
            } else {
                lastLoadError = "\"\(trimmedZip)\" may not be a city of Chicago zip code. Please enter a valid 5-digit zip code. Note suburban zip codes like 60007 will not work. Valid zip codes begin with 606, 607, or 608."
            }
            return []
        }

        let startPoint = CLLocation(latitude: targetZip.latitude, longitude: targetZip.longitude)

        let matches = allListings.map { listing -> (HousingListing, Double) in
            let listingPoint = CLLocation(latitude: listing.latitude, longitude: listing.longitude)
            let distanceInMeters = startPoint.distance(from: listingPoint)
            let distanceInMiles = distanceInMeters * 0.000621371
            return (listing, distanceInMiles)
        }

        // Sort from closest mileage outward
        let sorted = matches.sorted { $0.1 < $1.1 }
        if let maxDistance = maxDistance
        {
            return sorted.filter{$0.1 <= maxDistance}
        }
        return sorted
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
