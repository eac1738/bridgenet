//
//  ResourceRow.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/21/26.
//

import SwiftUI

// A single resource row, reused by SearchPage and SavedPage so both list
// food, housing, and internet results with the same look and the same
// "already saved" indicator.
struct ResourceRow: View {
    let resource: SavedResource

    @EnvironmentObject private var savedStore: SavedItemsStore

    private var isSaved: Bool {
        savedStore.isSaved(id: resource.id)
    }

    private var accessibilitySummary: String {
        var parts = [resource.title]
        if resource.isCitywide {
            parts.append("citywide resource, available to all Chicago residents")
        }
        parts.append(resource.address)
        if !resource.phone.isEmpty { parts.append(resource.phone) }
        if let milesAway = resource.milesAway {
            parts.append("\(String(format: "%.1f", milesAway)) miles away")
        }
        if isSaved { parts.append("saved") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(resource.category.color.opacity(0.2))
                    .frame(width: 34, height: 34)
                Image(systemName: resource.category.iconName)
                    .foregroundStyle(resource.category.color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(resource.title)
                        .font(.headline)
                    if resource.isCitywide {
                        Text("CITYWIDE")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.white.opacity(0.65)))
                            .foregroundColor(resource.category.color)
                            .accessibilityHidden(true)
                    }
                }
                if let subtitle = resource.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(resource.category.color) // resource.category.color
                }
                Text(resource.address)
                    .font(.subheadline)
                    .foregroundColor(.bluegreen) //.secondary
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let milesAway = resource.milesAway {
                    Text(String(format: "%.1f mi", milesAway))
                        .font(.caption)
                        .bold()
                        .foregroundColor(resource.category.color)
                }
                if isSaved {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundColor(resource.category.color)
                }
            }
        }
        .contentShape(Rectangle())
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.sagegreen)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityHint("Double tap to view details")
    }
}
