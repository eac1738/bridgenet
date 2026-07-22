//
//  SearchPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/21/26.
//

import SwiftUI

struct SearchPage: View {
    @EnvironmentObject private var savedStore: SavedItemsStore

    @State private var searchText: String = ""
    @State private var allResources: [SavedResource] = []
    @State private var hasLoaded = false
    @State private var selectedResource: SavedResource? = nil

    let initialSearch: String
    
    //This will be either filled in with user input or prefilled via the ChatBot when asked.
    init(initialSearch: String = "")
    {
        self.initialSearch = initialSearch
        _searchText = State(initialValue: initialSearch)
    }
    
    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredResults: [SavedResource] {
        guard !trimmedQuery.isEmpty else { return [] }
        return allResources
            .filter {
                $0.title.localizedCaseInsensitiveContains(trimmedQuery) ||
                $0.address.localizedCaseInsensitiveContains(trimmedQuery)
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)

            VStack(spacing: 0) {
                HStack {
                    Text("Search")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }

                searchField

                content
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            loadAllResourcesIfNeeded()
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailSheet(resource: resource)
                .environmentObject(savedStore)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white)
                .accessibilityHidden(true)

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search by name or address")
                        .foregroundColor(.white)
                }
                TextField("", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel("Search by name or address")
                    .foregroundColor(.white)
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.sagegreen.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var content: some View {
        if !hasLoaded {
            Spacer()
            ProgressView("Loading resources…")
                .foregroundStyle(.white)
            Spacer()
        } else if trimmedQuery.isEmpty {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Search all resources")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Find food pantries, affordable housing, internet resources, and more by name or address.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .accessibilityElement(children: .combine)
            Spacer()
        } else if filteredResults.isEmpty {
            Spacer()
            Text("No matches for \"\(trimmedQuery)\"")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
        } else {
            List(filteredResults) { resource in
                Button {
                    selectedResource = resource
                } label: {
                    ResourceRow(resource: resource)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // Loads every offline dataset once (name/address search has no ZIP code
    // to key off of, so this doesn't call the *Manager.findXNear helpers,
    // which require a starting ZIP — it goes straight to the CSV loaders).
    private func loadAllResourcesIfNeeded() {
        guard !hasLoaded else { return }

        let pantries = PantryManager.loadPantriesFromCSV().map { $0.asSavedResource() }
        let housing = HousingManager.loadListingsFromCSV().map { $0.asSavedResource() }
        let internet = InternetResourceManager.loadResourcesFromCSV().map { $0.asSavedResource() }

        // Citywide resources aren't tied to a ZIP code, so they aren't in the
        // CSVs above — pull them in directly so they're just as searchable
        // by name or address as everything the finder views surface.
        let citywideFood = CitywideFoodResources.all
        let citywideHousing = CitywideHousingResources.all
        let citywideInternet = CitywideInternetResources.all

        allResources = pantries + housing + internet + citywideFood + citywideHousing + citywideInternet
        hasLoaded = true
    }
}

#Preview {
    NavigationStack {
        SearchPage()
            .environmentObject(SavedItemsStore())
    }
}
