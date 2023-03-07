import SwiftUI

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
                Button("Send"){
                    send()
                }
            }
        }
        .padding()
        .task {
            // add prompt message when app launches
            messages.append(prompt)
            
            viewModel.initialize()
        }
    }
    
    func send(){
        // if text field empty, then return
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append("Me: \n\(text) \n")
        
        let textToSend = self.text
        self.text = ""
        viewModel.send(text: textToSend) {
            // async append API's response to [messages]
            response in
            DispatchQueue.main.async {
                self.messages.append("Mia:\n" + response + "\n")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
