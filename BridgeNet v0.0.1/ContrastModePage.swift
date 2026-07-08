//
//  ContrastModePage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/8/26.
//

import SwiftUI

struct ContrastModePage: View {
    
    @Binding var ContrastMode: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Contrast Mode")
                    .font(.system(size: 20))
                    .foregroundStyle(.darkgray)
                    .fontWeight(.semibold)
                    .padding(.leading, 30)
                Spacer()
                Toggle("", isOn: $ContrastMode)
                    .labelsHidden()
                    .padding(.trailing, 20)
                    .padding(.vertical, 12)
            }
            Text("BridgeNet will adopt darker and more contrasting colors for easier reading.")
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .font(.system(size: 15))
        }
        Spacer()
    }
}

#Preview {
    ContrastModePage(ContrastMode: .constant(false))
}
