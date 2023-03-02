//
//  ContentView.swift
//  ChatGPT
//
//  Created by Quang Nguyen The on 3/2/23.
//

import SwiftUI
import OpenAISwift

//is conforming to the Identifiable protocol by implementing its only requirement, which is to provide an id property that uniquely identifies an instance of the struct. In this case, the id property is set to a new UUID instance each time a new QuestionAndAnswer object is created.
struct QuestionAndAnswers: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct ContentView: View {
    
    let openAI = OpenAISwift(authToken: "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")
    
    @State private var search = ""
    @State private var searching: Bool = false
    @State private var questionAndAnswers: [QuestionAndAnswers] = [] //The variable is an array of QuestionAndAnswers objects and is initialized to an empty array using the assignment operator =
    
    private func performOpenAISearch() {
        openAI.sendCompletion(with: search, maxTokens: 1000) { result in //model: .gpt3(.ada) 
            switch result {
            case .success(let success):
                let questionAndAnswer = QuestionAndAnswers(question: search, answer: success.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                //questionAndAnswer = QuestionAndAnswers(id: 83E12642-5626-4E3F-BAA5-9872107A5B3B, question: "When was SwiftUI created ?", answers: "SwiftUI was announced by Apple at their WWDC (Worldwide Developers Conference) in 2019 and officially released in June of that year.")
                
                questionAndAnswers.append(questionAndAnswer);
                
                search = "";
                searching = false
                
            case .failure(let failure):
                print(failure.localizedDescription)
                searching = false
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView(showsIndicators: true) {
                    ForEach(questionAndAnswers) { qa in
                        VStack(spacing: 10) {
                            Text(qa.question)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(qa.answer)
                                .padding([.bottom], 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }.padding()
                
                HStack {
                    TextField("Type Here...", text: $search)
                        .onSubmit {
                            if !search.isEmpty {
                                searching = true;
                                performOpenAISearch();
                            }
                        }
                }.padding()
                
                if searching {
                    ProgressView()
                        .padding()
                }
                
            }
            .navigationTitle("ChatGPT")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
