import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    
    private var openAI: OpenAISwift?
    private let prompt: String = "Mia:\nHello! I am Mia :) Your virtual health coach buddy. I have knowledge about unusual fatigue and I can perhaps help you cope. How can I assist you today?"
        
    
    // initialization
    func initialize() {
        openAI = OpenAISwift(authToken: "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")
    }
    
    // function to send request to the API
    //  - argument: string
    //  - return: successful response or error msg in string
    
    func send(chat: [ChatMessage], completion: @escaping (String) -> Void ) async {     
        
        // method uses the text-davinci-003 model
        openAI?.sendChat(with: chat, model: .chat(.chatgpt), maxTokens: 100, completionHandler: { result in
            switch result {
                case .success(let success):
                let output = success.choices.first?.message.content ?? ""
                    completion(output)
                case .failure(let failure):
                    print(failure.localizedDescription)
            }
        })
    }
}
