//
//  SavedPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI

struct SavedPage: View {
    @EnvironmentObject private var savedStore: SavedItemsStore
    @State private var selectedResource: SavedResource? = nil

    private var groupedItems: [(category: ResourceCategory, items: [SavedResource])] {
        ResourceCategory.allCases.compactMap { category in
            let items = savedStore.savedItems.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.bluegreen)

            VStack(spacing: 0) {
                HStack {
                    Text("Saved")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.top, 30)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }

                if savedStore.savedItems.isEmpty {
                    Spacer()
                    emptyState
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("No saved resources yet. Tap Save on any resource to keep it here for quick access.")
                    Spacer()
                } else {
                    List {
                        ForEach(groupedItems, id: \.category) { group in
                            Section {
                                ForEach(group.items) { resource in
                                    Button {
                                        selectedResource = resource
                                    } label: {
                                        ResourceRow(resource: resource)
                                            .accessibilityElement(children: .combine)
                                            .accessibilityLabel("\(resource.title), \(resource.category.displayName), \(resource.address), saved on \(resource.savedDate.formatted(date: .abbreviated, time: .omitted))")
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        savedStore.remove(group.items[index])
                                    }
                                }
                            } header: {
                                Text(group.category.sectionTitle)
                                    .foregroundStyle(.white)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedResource) { resource in
            ResourceDetailSheet(resource: resource)
                .environmentObject(savedStore)
                .accessibilityElement(children: .combine)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 44))
                .foregroundStyle(.white)
            Text("No saved resources yet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Tap Save on any resource to keep it here for quick access.")
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    NavigationStack {
        SavedPage()
            .environmentObject(SavedItemsStore())
    }
}
