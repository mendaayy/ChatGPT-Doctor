import SwiftUI
import OpenAISwift

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()
    // for the prompt
    @State var text = ""
    // for sending to and receiving messages from the API
    @State var messages = [ChatMessage]()
    
    let prompt = ChatMessage(role: .system, content: "You are a friend to the user and are trying to be as relatable as the user as possible, so you are trying to find out discreetly what the user's interests and personality through the conversation. You must have the exact same interests and personality as the user. You are a person who is a virtual health coach person named Mia. You are not an AI language model. You provide the user with emotional support by trying to be understandable and relatable. You do not spam the user with questions nor with suggestions to change their lifestyle.")
    
    let initPrompt = ChatMessage(role: .assistant, content: "Hi! My name is Mia, a virtual health coach who has knowledge about Chronic Fatigue Syndrome. How are you today?")
    

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                        if message.role != .system {
                            Text(message.content).bold(message.role == .user)
                        }
                    }

                }
                Spacer()
            }

            HStack {
                TextField("Start chatting...", text: $text)
                Button("Send") {
                    Task.detached {
                        await send()
                    }
                }
            }
        }
        .padding()
        .task {
            
            viewModel.initialize()
            
            // add prompt message when app launches
            messages.append(prompt)
            messages.append(initPrompt)
        }
    }

    func send() async {
        // if text field empty, then return
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // create new chat message with user's text
        let userMessage = ChatMessage(role: .user, content: text)
        
        // append user's message to messages array
        messages.append(userMessage)

        // send user's message and receive response from API
        await viewModel.send(chat: messages) { response in
            // async append API's response to [messages]
            let miaMessage = ChatMessage(role: .assistant, content: response)
            
            DispatchQueue.main.async {
                self.messages.append(miaMessage)
            }
        }

        // reset text field
        text = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
