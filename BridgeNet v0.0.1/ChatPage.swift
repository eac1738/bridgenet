//
//  ChatPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI

struct ChatPage: View {
    //This is used to display what either the bot is talking or the user is talking
    @State private var messages: [ChatMessage] = [ChatMessage(text: "Hello, Welcome to BridgeNet. How my I assist you today?", isUser: false)]
    
    @State private var userInput : String = ""
    
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
                        //Chat History View
                        ScrollViewReader{proxy in ScrollView
                            {
                                LazyVStack(spacing:16)
                                {
                                    ForEach(messages){messages in ChatDialogBox(message: messages)}
                                }
                            }
                            .padding()
                            .onChange(of: messages.count)
                            {
                                _ in
                                // Automatically scroll to the bottom to incoming messages
                                if let lastMessage = messages.last
                                {
                                    withAnimation
                                    {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                }
                    HStack()
                    {
                        TextField("Type Here", text: $userInput)
                            .frame(width: 300, height: 30,alignment: .center)
                        .padding(.bottom)
                        .cornerRadius(1)
                        .background(Color.white)
                        .onSubmit {
                               
                            }
                        HStack
                        {
                            Button(action: sendMessage)
                            {
                                Image(systemName: "paperplane.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(userInput.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                            }
                            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)}
                        }
                    }
                    
                    
                
            }
         Spacer()
        }
    func sendMessage()
{
    //This takes the input text given and it's processed by the chatbox.
    let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedInput.isEmpty else { return }
    
    // 1. Append User Message
    let userMessage = ChatMessage(text: trimmedInput, isUser: true)
    messages.append(userMessage)
    
    // Clear input field immediately
    let query = trimmedInput
    userInput = ""
    
    // 2. Trigger Bot Response with a slight natural delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        let replyText = ChatBotResponseSystem.getResponse(for: query)
        let botMessage = ChatMessage(text: replyText, isUser: false)
        messages.append(botMessage)
    }
}
}
    

struct ChatMessage: Identifiable
{
    let id = UUID()
    let text : String
    let isUser : Bool
    let timeStamp = Date()
}

struct ChatBotResponseSystem
{
    //This allows the AI Chatbot to respond to user input.
    private static let responses: [String: String] = [
            "hello": "Hi there! How can I help you today?",
            "hi": "Hey! Hope you're having a great day.",
            "help": "I can assist you with basic navigation. Try saying 'hello' or 'bye'.",
            "bye": "Goodbye! Have a wonderful day!",
            "status": "All systems are operational."
        ]
        
        static func getResponse(for input: String) -> String {
            let cleanedInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for direct match or partial match
            if let directMatch = responses[cleanedInput] {
                return directMatch
            }
            
            // Fallback for unrecognized inputs
            return "I'm not sure I understand that. Type 'help' to see what I can do."
        }
}

struct ChatDialogBox : View
{
    let message: ChatMessage
        
        var body: some View {
            HStack {
                if message.isUser { Spacer() }
                
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color(.secondarySystemBackground))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(18)
                    // Prevents layout stretching across the screen
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
                
                if !message.isUser { Spacer() }
            }
        }
}



#Preview {
    ChatPage()
}
