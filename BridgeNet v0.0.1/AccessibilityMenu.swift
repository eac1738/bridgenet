//
//  AccessibilityMenu.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/8/26.
//

import SwiftUI

struct AccessibilityMenu: View {
    
    @AppStorage("spanishMode") private var SpanishMode = false
    @AppStorage("voiceOverEnabled") private var VoiceOver = false
    @AppStorage("contrastEnabled") private var ContrastMode = false
    
    var body: some View {
        
        HStack {
            Text("VISION")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(.darkgray)
                .padding()
            Spacer()
        }

        // Group: Vision options
        VStack(spacing: 0) {
            // Row: VoiceOver
            NavigationLink {
                VoiceOverPage(VoiceOver: $VoiceOver)
            }
            label: {
                HStack {
                    Text("VoiceOver")
                        .font(.system(size: 17))
                        .foregroundStyle(.darkgray)
                        .padding(.leading, 20)
                    Spacer()
                    if (!VoiceOver) {
                        Text("Off >")
                            .font(.system(size: 17))
                            .foregroundStyle(.darkgray)
                            .padding(.trailing, 20)
                            .padding(.vertical, 12)
                    }
                    else {
                        Text("On >")
                            .font(.system(size: 17))
                            .foregroundStyle(.darkgray)
                            .padding(.trailing, 20)
                            .padding(.vertical, 12)
                    }
                }
            }
            // Single inset divider BETWEEN rows
            Divider()
            // Row: Contrast Mode
            NavigationLink {
                ContrastModePage(ContrastMode: $ContrastMode)
            }
            label: {
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
                    }
                    else {
                        Text("On >")
                            .font(.system(size: 17))
                            .foregroundStyle(.darkgray)
                            .padding(.trailing, 20)
                            .padding(.vertical, 12)
                    }
                }
            }
        }
        // Full-width separators at group edges
        .overlay(alignment: .top) { Divider() }
        .overlay(alignment: .bottom) { Divider() }

        HStack {
            Text("LANGUAGE")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(.darkgray)
                .padding()
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
            // Single inset divider BETWEEN rows
            Divider()
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
        }
        // Full-width separators at group edges
        .overlay(alignment: .top) { Divider() }
        .overlay(alignment: .bottom) { Divider() }

        Spacer()
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.offwhite, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    AccessibilityMenu()
}
