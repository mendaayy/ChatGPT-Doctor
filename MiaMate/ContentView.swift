import SwiftUI
import OpenAISwift

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()
    // for the prompt
    @State var text = ""
    // for sending to and receiving messages from the API
    @State var messages = [String]()    
    
    let prompt = "Mia:\nHello! I am Mia :) Your virtual health coach buddy. I have knowledge about unusual fatigue and I can perhaps help you cope. How can I assist you today?"

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { string in
                        Text(string)
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
            
            // add prompt message when app launches
            messages.append(prompt)

            viewModel.initialize()
        }
        .onAppear {
            Task.detached {
                await viewModel.initialize()
            }
        }
    }

    func send() async {
        // if text field empty, then return
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // create new chat message with user's text
        let userMessage = ChatMessage(role: .user, content: text)


        // send user's message and receive response from API
        await viewModel.send(chat: [userMessage]) { response in
            // async append API's response to [messages]
            let miaMessage = ChatMessage(role: .assistant, content: response)
            DispatchQueue.main.async {
                self.messages.append("Mia:\n" + miaMessage.content + "\n")
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
