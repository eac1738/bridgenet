//
//  ResourceDetailSheet.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/21/26.
//

import SwiftUI

struct ResourceDetailSheet: View {
    let resource: SavedResource

    @EnvironmentObject private var savedStore: SavedItemsStore
    @Environment(\.dismiss) private var dismiss

    private var isSaved: Bool {
        savedStore.isSaved(id: resource.id)
    }

    private var telURL: URL? {
        let digits = resource.phone.filter { $0.isNumber }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }

    private var websiteURL: URL? {
        guard let website = resource.website, !website.isEmpty else { return nil }
        if website.lowercased().hasPrefix("http://") || website.lowercased().hasPrefix("https://") {
            return URL(string: website)
        }
        return URL(string: "https://\(website)")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(.sagegreen)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        if let milesAway = resource.milesAway {
                            Label("\(String(format: "%.1f", milesAway)) miles away", systemImage: "location.fill")
                                .font(.subheadline)
                                .foregroundStyle(.bluegreen)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(icon: "mappin.and.ellipse", label: "Address", value: resource.address)

                            if !resource.phone.isEmpty {
                                if let telURL {
                                    Link(destination: telURL) {
                                        DetailRow(icon: "phone.fill", label: "Phone", value: resource.phone, valueColor: .blue)
                                    }
                                    .accessibilityHint("Double tap to call")
                                } else {
                                    DetailRow(icon: "phone.fill", label: "Phone", value: resource.phone)
                                }
                            }

                            if let websiteURL {
                                Link(destination: websiteURL) {
                                    DetailRow(icon: "globe", label: "Website", value: "Visit official page", valueColor: .blue)
                                }
                                .accessibilityHint("Opens the official page in Safari")
                            }

                            ForEach(resource.details, id: \.self) { line in
                                DetailRow(icon: "info.circle", label: "", value: line)
                            }
                        }

                        Spacer(minLength: 12)

                        saveButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle(resource.category.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .foregroundColor(.bluegreen)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(resource.category.color.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: resource.category.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(resource.category.color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(resource.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.bluegreen)
                if let subtitle = resource.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.bluegreen.opacity(0.7))
                }
                if resource.isCitywide {
                    Text("AVAILABLE TO ALL CHICAGO RESIDENTS")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.6)))
                        .foregroundStyle(resource.category.color)
                        .accessibilityLabel("Citywide resource, available to all Chicago residents")
                }
            }
            Spacer()
        }
    }

    private var saveButton: some View {
        Button {
            savedStore.toggleSave(resource)
        } label: {
            Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .foregroundStyle(.white)
        }
        .buttonStyle(.borderedProminent)
        .tint(resource.category.color)
        .accessibilityLabel(isSaved ? "Remove from saved" : "Save this resource")
        .accessibilityHint(isSaved ? "Double tap to remove from your saved list" : "Double tap to add to your saved list")
    }
}

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.bluegreen)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                if !label.isEmpty {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.bluegreen)
                }
                Text(value)
                    .font(.body)
                    .foregroundStyle(valueColor)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ResourceDetailSheet(
        resource: SavedResource(
            id: "preview",
            category: .food,
            title: "Sample Pantry",
            subtitle: nil,
            address: "123 Main St, Chicago, IL",
            phone: "(312) 555-0100",
            milesAway: 1.4,
            details: [],
            savedDate: Date()
        )
    )
    .environmentObject(SavedItemsStore())
}
