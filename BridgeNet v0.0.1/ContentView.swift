//
//  ContentView.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/2/26.
//

import SwiftUI

enum Route: Hashable {
    case accessibility
    case foodFinder(zip: String)
    case housingFinder(zip: String)
    case internetFinder(zip: String)
}

struct ContentView: View {
    @StateObject private var savedStore = SavedItemsStore()
    @State private var selectedTab = AppTab.home
    @State private var navPath = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $navPath) {
                selectedPage
                    .id(selectedTab)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .accessibility:
                            AccessibilityMenu()
                        case .foodFinder(let zip):
                            FoodPantryFinderView(initialZip: zip)
                        case .housingFinder(let zip):
                            AffordableHousingFinderView(initialZip: zip)
                        case .internetFinder(let zip):
                            InternetResourceFinderView(initialZip: zip)
                        }
                    }
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(.offwhite, for: .navigationBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .accessibilityHidden(true)

            HStack {
                TabBarButton(tab: .home, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .chat, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .search, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .saved, selectedTab: $selectedTab) { navPath = NavigationPath() }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Main navigation tab bar")
            .padding(.top, 14)
            .padding(.bottom, 2)
            .background(.bluegreen)
        }
        .background(.offwhite)
        .environmentObject(savedStore)
    }

    // Routes a detected Chat intent + confirmed zip code to the matching
    // finder view, pushed onto whichever tab's NavigationStack is current.
    private func handleChatNavigation(intent: String, zipCode: String) {
        switch intent {
        case "Food":
            navPath.append(Route.foodFinder(zip: zipCode))
        case "Housing", "Shelter":
            // No separate shelter finder exists yet — CitywideHousingResources
            // already covers emergency shelter, so route there for now.
            navPath.append(Route.housingFinder(zip: zipCode))
        case "Internet":
            navPath.append(Route.internetFinder(zip: zipCode))
        default:
            // Legal and Employment don't have a finder view built yet —
            // send the person to Search rather than a dead end.
            navPath = NavigationPath()
            selectedTab = .search
        }
    }

    @ViewBuilder
    private var selectedPage: some View {
        switch selectedTab {
        case .home:
            HomePage()
        case .chat:
            ChatPage(onNavigate: handleChatNavigation)
        case .search:
            SearchPage()
        case .saved:
            SavedPage()
        }
    }
}

private enum AppTab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case search = "Search"
    case saved = "Saved"

    var iconName: String {
        switch self {
        case .home:
            "house"
        case .chat:
            "message"
        case .search:
            "magnifyingglass"
        case .saved:
            "bookmark"
        }
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab
    var onTap: (() -> Void)? = nil

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            selectedTab = tab
            onTap?()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 22))
                    .accessibilityHidden(true)

                Text(tab.rawValue)
                    .font(.system(size: 15))
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? .green : .white)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(tab.rawValue) Tab")
            .accessibilityHint("Double tap to switch to the \(tab.rawValue) page")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
