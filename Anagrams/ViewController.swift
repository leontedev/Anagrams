//
//  ViewController.swift
//  Anagrams
//
//  Created by Mihai Leonte on 9/3/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords: [String] = []
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            //[weak self, weak ac] action in // action is not used in the close, so we can omit it
            [weak self, weak ac] _ in
            // to avoid a retain cycle we need to specify the reference is weak
            // however this means the objects are now Optional
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if hasAtLeastThreeLetters(word: lowerAnswer) {
            if isNotTheOriginalWord(word: lowerAnswer) {
                if isPossible(word: lowerAnswer) {
                    if isOriginal(word: lowerAnswer) {
                        if isReal(word: lowerAnswer) {
                            usedWords.insert(answer, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        } else {
                            errorTitle = "Word not recognized"
                            errorMessage = "You can't just make them up, you know?"
                        }
                    } else {
                        errorTitle = "Word already used"
                        errorMessage = "Try to be more original, will you?"
                    }
                } else {
                    errorTitle = "Word not possible"
                    errorMessage = "You can't spell that word from from \(title!.lowercased())"
                }
            } else {
                errorTitle = "That's the starting word"
                errorMessage = "Try, harder, to be more original."
            }
        } else {
            errorTitle = "Word too short"
            errorMessage = "The word needs to be at least three characters long."
        }
        
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Sorry", style: .default))
        present(ac, animated: true )
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        // to check if the word is real we can use UITextChecker() to check for miss-spellings. If no misspelling is found, it means the word is real.
        let checker = UITextChecker()
        
        // When using UIKit/SpriteKit or other Apple APIs methods use .utf16.count instead of .count
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        return misspelledRange.location == NSNotFound
    }
    
    func hasAtLeastThreeLetters(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isNotTheOriginalWord(word: String) -> Bool {
        guard let tempWord = title?.lowercased() else { return false }
        return word.lowercased() != tempWord
    }
    
}




