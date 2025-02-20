//
//  ContentView.swift
//  Word Scramble
//
//  Created by Student on 11/25/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var score = 0

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            Form{
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: both)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                VStack{
                    Text("Score: \(score)")
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(
                trailing: Button(action: {
                    startGame()
                }, label: { Text("Restart") })
            )
            .onAppear(perform: startGame)
                .alert(isPresented: $showingError){
                    Alert (title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
                }
        }
        }
    }
    func addNewWord(){
        let answer = newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else{
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        guard isShort(word: answer) else {
            wordError(title: "Word is too short", message:"Needs to be 3 or more letters")
            return
        }
        guard isSame(word: answer) else {
            wordError(title: "You can't use \(rootWord)", message: "")
            return
        }

        increaseScore()

        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try?
                String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"

                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord.lowercased()

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
            return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return mispelledRange.location == NSNotFound
    }
    func isSame(word: String) -> Bool{
        if word == rootWord {
        return false
        }
        return true
    }
    func isShort(word: String) -> Bool{

        let wordLength = word.count
        if wordLength < 3 {
        return false
        }
        return true
    }
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func increaseScore(){
        if usedWords.count <= 5 {
            score += 1
        } else {
            score += usedWords.count - 2
        }
}
    func both(){
        increaseScore()
        addNewWord()
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
