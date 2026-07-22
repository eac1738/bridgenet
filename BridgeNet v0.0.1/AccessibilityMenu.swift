//
//  AccessibilityMenu.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/8/26.
//

import SwiftUI

enum AccessibilityRoute: Hashable {
    case contrastMode
}

struct AccessibilityMenu: View {

    @AppStorage("spanishMode") private var SpanishMode = false
    @AppStorage("contrastEnabled") private var ContrastMode = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("VISION")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.darkgray)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }

                // Group: Vision options
                VStack(spacing: 0) {
                    HStack {
                        Text("BridgeNet includes VoiceOver support!")
                            .padding(.bottom)
                            .padding(.leading)
                            .fontWeight(.light)
                            .opacity(0.65)
                            .accessibilityLabel("BridgeNet includes VoiceOver support!")
                        Spacer()
                    }
                    .accessibilityElement(children: .ignore)

                    Divider()
                        .accessibilityHidden(true)
                    // Row: Contrast Mode
                    NavigationLink(value: AccessibilityRoute.contrastMode) {
                        HStack {
                            Text("Contrast Mode")
                                .font(.system(size: 17))
                                .foregroundStyle(.darkgray)
                                .padding(.leading, 20)
                            Spacer()
                            if (!ContrastMode) {
                                Text("Off >")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.darkgray)
                                    .padding(.trailing, 20)
                                    .padding(.vertical, 12)
                                    .accessibilityHidden(true)
                            }
                            else {
                                Text("On >")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.darkgray)
                                    .padding(.trailing, 20)
                                    .padding(.vertical, 12)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityLabel("Contrast Mode settings")
                    .accessibilityValue(ContrastMode ? "On" : "Off")
                    .accessibilityHint("Double tap to adjust contrast settings")
                }
                // Full-width separators at group edges
                .overlay(alignment: .bottom) { Divider().accessibilityHidden(true) }

                HStack {
                    Text("LANGUAGE")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.darkgray)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }

                // Group: Language options with mutually exclusive toggles
                VStack(spacing: 0) {
                    // Row: English (on when SpanishMode is false)
                    HStack {
                        Text("English")
                            .font(.system(size: 17))
                            .foregroundStyle(.darkgray)
                            .padding(.leading, 20)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { !SpanishMode },
                            set: { newValue in
                                // English on means Spanish off
                                SpanishMode = !newValue
                            }
                        ))
                        .labelsHidden()
                        .padding(.trailing, 20)
                        .padding(.vertical, 12)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("English language toggle")
                    .accessibilityValue(SpanishMode ? "Off" : "On")
                    // Single inset divider BETWEEN rows
                    Divider()
                        .accessibilityHidden(true)
                    // Row: Spanish (on when SpanishMode is true)
                    HStack {
                        Text("Spanish")
                            .font(.system(size: 17))
                            .foregroundStyle(.darkgray)
                            .padding(.leading, 20)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { SpanishMode },
                            set: { newValue in
                                SpanishMode = newValue
                            }
                        ))
                        .labelsHidden()
                        .padding(.trailing, 20)
                        .padding(.vertical, 12)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Spanish language toggle")
                    .accessibilityValue(SpanishMode ? "On" : "Off")
                }
                // Full-width separators at group edges
                .overlay(alignment: .top) { Divider().accessibilityHidden(true) }
                .overlay(alignment: .bottom) { Divider().accessibilityHidden(true) }
            }
        }
        .navigationDestination(for: AccessibilityRoute.self) { route in
            switch route {
            case .contrastMode:
                ContrastModePage(ContrastMode: $ContrastMode)
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.offwhite, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        AccessibilityMenu()
    }
}
