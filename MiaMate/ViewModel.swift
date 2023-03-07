import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    
    private var openAI: OpenAISwift?
    private var prompt: String = "Q: What are the common symptoms of CFS?\nA: The most common symptoms of CFS include severe fatigue, muscle pain, cognitive difficulties, and sleep disturbances.\nQ: How is CFS diagnosed?\nA: CFS is diagnosed based on a combination of clinical symptoms, medical history, and laboratory tests.\nQ: What are some treatment options for CFS?\nA: Treatment options for CFS include cognitive behavioral therapy, graded exercise therapy, and pharmacological interventions."
    
    // initialization
    func initialize(){
        openAI = OpenAISwift(authToken: "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")
    }
    
    // function to send request to the API
    //  - argument: string
    //  - return: successful response or error msg in string
    
    func send(text: String, completion: @escaping (String) -> Void ) {
        prompt += "\nQ: \(text)\nA:"
        
        // method uses the text-davinci-003 model
            openAI?.sendCompletion(with: prompt, maxTokens: 100, completionHandler: { result in
            switch result {
                case .success(let success):
                    let output = success.choices.first?.text ?? ""
                    completion(output)
                case .failure(let failure):
                    print(failure.localizedDescription)
            }
        })
    }
}
