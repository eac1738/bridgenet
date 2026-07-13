//
//  VoiceOverPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/8/26.
//

import SwiftUI

struct VoiceOverPage: View {
    
    @Binding var VoiceOver: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("VoiceOver")
                    .font(.system(size: 20))
                    .foregroundStyle(.darkgray)
                    .fontWeight(.semibold)
                    .padding(.leading, 30)
                Spacer()
                Toggle("", isOn: $VoiceOver)
                    .labelsHidden()
                    .padding(.trailing, 20)
                    .padding(.vertical, 12)
            }
            Text("An automated voice will read selected sections of the app aloud.")
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .font(.system(size: 15))
        }
        Spacer()
    }
}

#Preview {
    VoiceOverPage(VoiceOver: .constant(false))
}
