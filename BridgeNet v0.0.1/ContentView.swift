//
//  ContentView.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/2/26.
//

import SwiftUI

enum Route: Hashable {
    case accessibility
}

struct ContentView: View {
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
                        }
                    }
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(.offwhite, for: .navigationBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            HStack {
                TabBarButton(tab: .home, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .chat, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .search, selectedTab: $selectedTab) { navPath = NavigationPath() }
                TabBarButton(tab: .saved, selectedTab: $selectedTab) { navPath = NavigationPath() }
            }
            .padding(.top, 14)
            .padding(.bottom, 2)
            .background(.offwhite)
        }
        .background(.offwhite)
    }

    @ViewBuilder
    private var selectedPage: some View {
        switch selectedTab {
        case .home:
            HomePage()
        case .chat:
            ChatPage()
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

                Text(tab.rawValue)
                    .font(.system(size: 15))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? .bluegreen : .darkgray)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(tab.rawValue) Tab")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
