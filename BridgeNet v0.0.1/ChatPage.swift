//
//  ChatPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI

struct ChatPage: View {
    var body: some View {
        ZStack{
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(Color.offwhite)
            VStack()
            {
                HStack()
                {
                    Text("Ask BridgeNet")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                        .padding(.bottom, 3)
                        .padding(.leading, 30)
                    Spacer()
                }
                Divider()
                //Chat Interactions
                ZStack
                {
                    
                    VStack
                    {
                        
                        Rectangle()
                            .ignoresSafeArea()
                            .foregroundStyle(Color.gray)
                    }
                }
                HStack
                {
                    ChatBar(userInput: "")
                        .frame(width: 300, height: 3,alignment: .center)
                    .padding(.bottom)
                    .cornerRadius(1)
                    .background(Color.white)
                    HStack
                    {
                        Button("Send")
                        {}
                    }
                }
                    
                
            }
         Spacer()
        }
    }
}

struct ChatBar: View
{
    //This is supposed to hold the input area logic to talk to the chat bot.
    @State var userInput : String
    var body: some View
    {
        HStack()
        {
            TextField("Type Here", text: $userInput)
                .onSubmit {
                    sendInput(textInput: userInput)
                }
        }
        
        
        
    }
}

func sendInput(textInput: String)
{
    //Input Information that the user sends
}

struct ChatDialogBox : View
{
    //This is used to display what either the bot is talking or the user is talking
    
    var body: some View
    {
        Rectangle()
            .frame(width: 250, height: 250)
            .cornerRadius(30)
        foregroundStyle(Color.green)
    }
}



#Preview {
    ChatPage()
}
