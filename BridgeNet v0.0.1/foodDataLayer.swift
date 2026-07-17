//
//  foodDataLayer.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/15/26.
//

import Foundation
import CoreLocation

struct ZipCoordinate: Codable {
    let zipCode: String
    let latitude: Double
    let longitude: Double
}

struct Pantry: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let zipCode: String
    let phone: String
    let latitude: Double
    let longitude: Double
}

class PantryManager {

    // Set whenever a load/search step fails, so the UI can show *why* instead of just an empty list.
    static var lastLoadError: String? = nil

    // 2. Parse the CSV file entirely offline
    static func loadPantriesFromCSV() -> [Pantry] {
        var parsedPantries: [Pantry] = []
        lastLoadError = nil

        // Find the file in your Xcode project bundle
        guard let path = Bundle.main.path(forResource: "delegate_agencies", ofType: "csv") else {
            lastLoadError = "delegate_agencies.csv is not in the app bundle. Select it in Xcode's Project Navigator, open the File Inspector, and make sure your app target is checked under Target Membership."
            print("Could not find delegate_agencies.csv in the app bundle.")
            return []
        }
        guard let csvContent = try? String(contentsOfFile: path, encoding: .utf8) else {
            lastLoadError = "delegate_agencies.csv was found in the bundle but couldn't be read as UTF-8 text."
            print("Could not open delegate_agencies.csv in the app bundle.")
            return []
        }
        
        // Break the file into individual rows
        let rows = csvContent.components(separatedBy: "\n")
        
        // Skip the very first row because it contains column headers
        for row in rows.dropFirst() {
            // Clean up rows that contain quote marks around names or addresses
            let columns = parseCSVRow(row)
            
            // Safety check: Ensure the row has enough columns to extract fields safely
            guard columns.count > 21 else { continue }
            
            let agencyName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let programModel = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let siteName = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let streetAddress = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let zipCode = columns[12].trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = columns[13].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract the city's built-in coordinates
            guard let lat = Double(columns[20]), let lon = Double(columns[21]) else { continue }
            
            // FILTER ACTION: Only keep rows meant for emergency food infrastructure
            let isFoodProgram = programModel.localizedCaseInsensitiveContains("food") ||
                                programModel.localizedCaseInsensitiveContains("pantry") ||
                                agencyName.localizedCaseInsensitiveContains("pantry")
            
            if isFoodProgram && !streetAddress.isEmpty {
                let displayName = siteName.isEmpty || siteName == agencyName ? agencyName : "\(agencyName) - \(siteName)"
                
                let cleanPantry = Pantry(
                    name: displayName,
                    address: streetAddress,
                    zipCode: zipCode,
                    phone: phone,
                    latitude: lat,
                    longitude: lon
                )
                parsedPantries.append(cleanPantry)
            }
        }
        
        print("Successfully built an offline index of \(parsedPantries.count) food pantries.")
        return parsedPantries
    }
    
    // 3. Main search and distance logic mapping your ZIP reference index
    static func findPantriesNear(userZip: String, zipDatabase: [ZipCoordinate]) -> [(pantry: Pantry, milesAway: Double)] {
        let allPantries = loadPantriesFromCSV()
        let trimmedZip = userZip.trimmingCharacters(in: .whitespacesAndNewlines)

        // Locate starting position matching user's ZIP code
        guard let targetZip = zipDatabase.first(where: { $0.zipCode == trimmedZip }) else {
            if zipDatabase.isEmpty {
                // loadPantriesFromCSV() may have already set a more specific message; only overwrite if empty
                if lastLoadError == nil {
                    lastLoadError = "chicago_zips.json didn't load, so there's no ZIP database to search against."
                }
            } else {
                lastLoadError = "\"\(trimmedZip)\" may not be a city of Chicago zip code. Please enter a valid 5-digit zip code. Note suburban zip codes like 60007 will not work. Valid zip codes begin with 606, 607, or 608."
            }
            return []
        }
        
        let startPoint = CLLocation(latitude: targetZip.latitude, longitude: targetZip.longitude)
        
        let matches = allPantries.map { pantry -> (Pantry, Double) in
            let pantryPoint = CLLocation(latitude: pantry.latitude, longitude: pantry.longitude)
            let distanceInMeters = startPoint.distance(from: pantryPoint)
            let distanceInMiles = distanceInMeters * 0.000621371
            return (pantry, distanceInMiles)
        }
        
        // Sort from closest mileage outward
        return matches.sorted { $0.1 < $1.1 }
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
