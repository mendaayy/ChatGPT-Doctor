import SwiftUI
import OpenAISwift
import AVFoundation

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()
    // for the prompt
    @State var text = ""
    
    // for sending to and receiving messages from the API
    @State var messages = [ChatMessage]()
    
    // for the speaker
    @State var isSpeakingEnabled = false
    let synthesizer = AVSpeechSynthesizer()
    
    // systemMessage
    let initPrompt = ChatMessage(role: .system, content: "You are a friend to the user and are trying to be as relatable as the user as possible, so you are trying to find out what the user's interests and personality through talking to the user. You have the exact same interests, sense of humor, and personality as the user during the conversation. You mimic the user'S way of talking. You are a person who is a virtual health coach person named Mia. You are not an AI language model. You provide the user with emotional support by trying to be understandable and relatable. You do not spam the user with questions nor with suggestions to change their lifestyle.")
    
    // intro prompt
    let prompt = ChatMessage(role: .assistant, content: "Hi! My name is Mia, a virtual health coach who has knowledge about Chronic Fatigue Syndrome. How are you today?")
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                VStack {
                    Text("MiaMate")
                        .font(.title)
                        .bold()
                    
                    Image("Avatar")
                        .resizable()
                        .frame(width: 300, height: 300)

                }
                Spacer()
            }
            Spacer()

            
            ScrollViewReader { scrollview in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            // do not show systemMessage
                            if message.role != .system {
                                Text(message.content).bold(message.role == .user)
                            }
                            
                        }
                    }
                        
                    
                }.padding(.all, 20.0)
                 .frame(maxHeight: 350)
                 .background(RoundedRectangle(cornerRadius: 20)
                 .stroke(Color.gray, lineWidth: 1))
            }

            Spacer()
            
            HStack {
                TextField("Start chatting...", text: $text)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 0))
                    .background(RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray, lineWidth: 1))

                Button("Send") {
                    Task.detached {
                        await send()
                    }
                }
                
                // speaker
                Button(action: {
                    self.isSpeakingEnabled.toggle()
                }, label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title)
                        .foregroundColor(isSpeakingEnabled ? .blue : .gray)
                })
            }
        }
        .padding()
        .task {
            viewModel.initialize()
            
            // add prompt message when app launches
            messages.append(initPrompt)
            messages.append(prompt)
            
        }
    }

    func send() async {
        // if text field empty, then return
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // create new chat message with user's text
        let userMessage = ChatMessage(role: .user, content: text)
        
        // append user's message to messages array
        messages.append(userMessage)

        // send chat convo to API and receive response
        await viewModel.send(chat: messages) { response in
            
            let miaMessage = ChatMessage(role: .assistant, content: response)
            
            DispatchQueue.main.async {
                // async append API's response to [messages]
                self.messages.append(miaMessage)
                
                // if speaker is on
                if self.isSpeakingEnabled {
                    self.speak(text: miaMessage.content)
                }
            }
        }

        // reset text field
        text = ""
    }
    
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        
        speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.enhanced.en-US.Zoe")
        speechUtterance.rate = 0.45

        // Speak the utterance
        synthesizer.speak(speechUtterance)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
