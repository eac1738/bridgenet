//
//  ChatPage.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/3/26.
//

import SwiftUI
import CoreML

enum ChatState
{
    case idle
    case zipcodeSearch(intent: String)
}

struct ChatPage: View {
    //This is used to display what either the bot is talking or the user is talking
    @State private var messages: [ChatMessage] = [ChatMessage(text: "Hello, Welcome to BridgeNet. How my I assist you today?", isUser: false)]
    
    @State private var userInput : String = ""
    @State private var chatState = ChatState.idle
    var onNavigate: ((_ intent: String, _ zipCode: String) -> Void)? = nil
    
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
                        .accessibilityAddTraits(.isHeader)
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
                        .accessibilityLabel("Message input field")
                        .accessibilityHint("Type your question or message for BridgeNet")
                    HStack
                    {
                        Button(action: sendMessage)
                        {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(userInput.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                        }
                        .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        .accessibilityLabel("Send Message")
                        .accessibilityHint("Double tap to send your message to BridgeNet")
                    }
                }
                
                
            }
            Spacer()
        }
    }
    
    //Load Chicago Zip Codes
    private let validChicagoZips: Set<String> =
    {
        guard let url = Bundle.main.url(forResource: "chicago_zips", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let zips = try? JSONDecoder().decode([ZipCoordinate].self, from: data)
        else
        {
            return []
        }
        return Set(zips.map{$0.zipCode})
    }()
    
    func sendMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        let userMessage = ChatMessage(text: trimmedInput, isUser: true)
        messages.append(userMessage)

        let query = trimmedInput
        userInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            switch self.chatState {
            case .idle:
                let replyText = ChatBotResponseSystem.getResponse(for: query)
                let botMessage = ChatMessage(text: replyText, isUser: false)
                self.messages.append(botMessage)
                // Detect intent from model
                if let model = try? IntentClassifier(configuration: MLModelConfiguration()),
                   let prediction = try? model.prediction(text: query) {
                    self.chatState = .zipcodeSearch(intent: prediction.label)
                }
            case .zipcodeSearch(let intent):
                if self.validChicagoZips.contains(query) {
                    self.messages.append(
                        ChatMessage(text: "Great! Let me take you to the \(intent) resources near \(query).", isUser: false)
                    )
                    // Navigate after a brief delay so user sees the message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.onNavigate?(intent, query)
                        self.chatState = .idle
                    }
                } else {
                    self.messages.append(
                        ChatMessage(text: "Sorry, the zipcode you entered is not a valid Chicago zipcode. Please try again.", isUser: false)
                    )
                }
            }
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
    private static func response(for label: String) -> String
    {
        switch label
        {
        case "Food":
            return "Are you looking for emergency food resources? Let me find food pantries in your area.\nWhat's your Chicago zip code so I can find food resources near you?"
        case "Shelter":
            return "Are you looking for emergency shelter? Let me find resources for you.\nWhat's your Chicago zip code so I can find shelter resources near you?"
        case "Housing":
            return "For health-related needs, I can find nearby clinics and healthcare programs.\nWhat's your Chicago zip code so I can find housing resources near you?"
        case "Legal":
            return "If you need legal assistance, I can connect you with resources.\nWhat's your Chicago zip code so I can find legal resources near you?"
        case "Employment":
            return "Looking for employment support? I can help find job training programs.\nWhat's your Chicago zip code so I can find employment resources near you?"
        default:
            return "I'm not sure I understand. Could you tell me more about what you need?"
        }
    }
    
    static func getResponse(for input: String) -> String {
        //Insert Model
        guard let model = try? IntentClassifier(configuration: MLModelConfiguration()),
              let prediction = try? model.prediction(text: input)
        else
        {
            return "Sorry, I'm having trouble understanding. Could you rephrase?"
        }
        return response(for: prediction.label)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message.isUser ? "Your message: \(message.text)" : "BridgeNet says: \(message.text)")
    }
}



#Preview {
    ChatPage()
}
