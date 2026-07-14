//
//  HomePage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.offwhite)
            VStack {
                HStack {
                    Text("BridgeNet")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                    Spacer()
                    NavigationLink {
                        AccessibilityMenu()
                    }
                    label: {
                        Image(systemName: "accessibility")
                            .font(.system(size: 35))
                            .padding(.trailing, 20)
                            .foregroundStyle(.blue)
                    }
                }
                HStack {
                    Text("Chicago resource navigator")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .padding(.leading, 30)
                    Spacer()
                }
                HStack {
                    Text("Works offline - No Wi-Fi needed")
                        .font(.system(size: 17))
                        .foregroundStyle(.bluegreen)
                        .fontWeight(.semibold)
                        .padding(.leading, 18)
                        .padding(.trailing, 82)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.sagegreen)
                                .opacity(0.50)
                        }
                }
                HStack {
                    Text("BROWSE BY CATEGORY")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .padding(.leading, 30)
                        .foregroundStyle(.darkgray)
                        .padding(.top, 2)
                        .padding(.bottom, 1)
                    Spacer()
                }
                HStack {
                    CategoryCard(iconName: "cart.fill.badge.plus", category: "Food", resources: 12, iconColor: .olivegreen)
                        .padding(3)
                    CategoryCard(iconName: "ellipsis.circle.fill", category: "Utilities", resources: 10, iconColor: .brown)
                }
                HStack {
                    CategoryCard(iconName: "wifi", category: "Internet", resources: 12, iconColor: .blue)
                        .padding(3)
                    CategoryCard(iconName: "house.fill", category: "Housing", resources: 10, iconColor: .bluegreen)
                }
                HStack {
                    CategoryCard(iconName: "bandage.fill", category: "Health", resources: 12, iconColor: .red)
                        .padding(3)
                    CategoryCard(iconName: "map.fill", category: "Navigation", resources: 10, iconColor: .bluegray)
                }
                HStack {
                    CategoryCard(iconName: "bag.fill.badge.plus", category: "Jobs", resources: 12, iconColor: .purple)
                        .padding(3)
                    CategoryCard(iconName: "doc.text.fill", category: "Legal", resources: 10, iconColor: .redorange)
                }
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct CategoryCard: View {
    let iconName: String
    let category: String
    var resources: Int
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 35, height: 35)
                    .foregroundStyle(iconColor)
                    .opacity(0.25)
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
            }
            Text(category)
                .fontWeight(.bold)
                .font(.system(size: 20))
                .padding(.top, 5)

            Text("\(resources) resources")
                .fontWeight(.light)
                .font(.system(size: 15))
        }
        .frame(width: 150, height: 120, alignment: .leading)
        .padding(.leading, 18)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 5)
        }
    }
}

#Preview {
    HomePage()
}
